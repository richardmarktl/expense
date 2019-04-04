//
//  JobDesign+Fetchable.swift
//  InVoice
//
//  Created by Georg Kitz on 11.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreDataExtensio
import RxSwift


enum JobPageSize: String {
    case A4
    case letter
    
    var localizedString: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

enum InvoiceTemplate: String {
    case clean
    case bold
    case plain
    case modern
    
    var localizedString: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

extension JobDesign: Fetchable {
    
    public typealias FetchableType = JobDesign
    public typealias I = String
    
    public static func idName() -> String {
        return "uuid"
    }
    
    public static func defaultSortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "createdTimestamp", ascending: true)]
    }
    
    static func create(in context: NSManagedObjectContext) -> JobDesign {
        let design = JobDesign(inContext: context)
        
        design.uuid = UUID().uuidString.lowercased()
        design.createdTimestamp = Date()
        design.updatedTimestamp = Date()
        design.localUpdateTimestamp = Date()
        design.color = "#319FF9FF"
        design.template = InvoiceTemplate.clean.rawValue
        design.pageSize = JobPageSize.A4.rawValue
        design.showArticleNumber = false
        design.showArticleTitle = true
        design.showArticleDescription = true
        
        return design
    }
    
    static func current(in context: NSManagedObjectContext) -> JobDesign {
        return JobDesign.allObjects(fetchLimit: 1, context: context).first!
    }
    
    static func migrateFromAccountIfNeeded(account: Account, in context: NSManagedObjectContext) -> Observable<JobDesign> {
        
        if account.remoteId == 0 {
            return Observable.empty()
        }
        
        if let jobDesign = JobDesign.allObjects(fetchLimit: 1, context: context).first, jobDesign.hasRemoteId {
            return Observable.just(jobDesign)
        }
        
        let design = JobDesign.create(in: context)
        return JobDesignRequest.load(design, updatedAfter: nil).do(onNext: { (design) in
            design.account = account
            try? design.managedObjectContext?.save()
        })
    }
}
