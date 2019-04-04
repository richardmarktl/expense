//
//  UpdateRunner.swift
//  InVoice
//
//  Created by Georg Kitz on 07.03.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

protocol Versionable {
    var version: String {get}
}

extension Bundle: Versionable {
    var version: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
}

enum MigrationState {
    case notRun
    case running
    case done
}

typealias Migration = () -> Observable<Void>

class UpdateRunner {
    
   private struct Static {
        static var instance: UpdateRunner?
    }
    
    class var updateRunner: UpdateRunner? {
        return UpdateRunner.Static.instance
    }
    
    class func create(userDefaults: UserDefaults = UserDefaults.standard, currentVersion: Versionable = Bundle.main) -> UpdateRunner{
        let runner = UpdateRunner(userDefaults: userDefaults, currentVersion: currentVersion)
        UpdateRunner.Static.instance = runner
        return runner
    }
    
    private let migrationSubject: Variable<MigrationState> = Variable(.notRun)
    private let storage: UserDefaults
    private let currentVersion: Versionable
    private var migrations: [String: Migration] = [:]
    
    var migrationObservable: Observable<MigrationState> {
        return migrationSubject.asObservable()
    }
    
    private init(userDefaults: UserDefaults, currentVersion: Versionable) {
        storage = userDefaults
        self.currentVersion = currentVersion
    }
    
    func registerMigration(for version: String, migration: @escaping Migration) {
        migrations[version] = migration
    }
    
    func markMigrationsAsDone() {
        migrations.forEach { (element) in
            self.storage.set(true, forKey: element.key)
            self.storage.synchronize()
            logger.verbose("Migration for \(element.key) done")
        }
        logger.verbose("All migrations marked as done")
        migrationSubject.value = .done
    }
    
    func runMigrations() {
        
        if (migrationSubject.value != .notRun) {
            logger.error("Migrations already triggered")
            return
        }
        
        migrationSubject.value = .running
        
        let sortedMigrations = migrations.filter { (element) -> Bool in
            return storage.bool(forKey: element.key) == false
        }.sorted { (el1, el2) -> Bool in
            return el1.key < el2.key
        }
        
        var obs: Observable<Void> = Observable.just(())
        
        sortedMigrations.forEach { (element) in
            let nextMigration: Migration = element.value
            let nextObservable = nextMigration().take(1).do(onNext: { [weak self] (_) in
                self?.storage.set(true, forKey: element.key)
                self?.storage.synchronize()
                logger.verbose("Migration for \(element.key) done")
            })
            obs = obs.concat(nextObservable)
        }
        
        _ = obs.takeLast(1).bind { [weak self] in
            self?.migrationSubject.value = .done
        }
    }
}
