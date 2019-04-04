//
//  SignatureSection.swift
//  InVoice
//
//  Created by Richard Marktl on 28.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

/// The class SignatureSections, contains the controls to add or remove a signature from the customer and
/// the user to the job.
class SignatureSection: TableSection {
    let customerSignature: CustomerSignature
    let userSignature: UserSignature
    var job: Job

    private let customerSignatureSubject: PublishSubject<Void> = PublishSubject()
    private let userSignatureSubject: PublishSubject<Bool> = PublishSubject()

    public var customerSignatureObservable: Observable<Void> {
        return customerSignatureSubject.asObservable()
    }
    public var userSignatureObservable: Observable<Bool> {
        return userSignatureSubject.asObservable()
    }

    private let bag = DisposeBag()

    init(job: Job, in context: NSManagedObjectContext) {
        self.job = job

        var rows: [ConfigurableRow] = []
        let shouldShowProBadge = !StoreService.instance.hasValidReceipt

        customerSignature = CustomerSignature(job: job, isProFeature: shouldShowProBadge)
        userSignature = UserSignature(job: job, isProFeature: shouldShowProBadge)

        // in the case no country was found on the server during the address geocoding, we will show no stripe
        // payment action.
        rows.append(TableRow<SwitchCell, NoOperationBoolAction>(item: userSignature, action: NoOperationBoolAction()))
        rows.append(TableRow<SwitchCell, NoOperationBoolAction>(item: customerSignature, action: NoOperationBoolAction()))

        super.init(rows: rows, headerTitle: R.string.localizable.signatureSection(), footerTitle: R.string.localizable.signatureFooter())

        customerSignature.data.asObservable().skip(1).subscribe(onNext: { [weak self] (value) in
            job.needsSignature = value
            self?.customerSignatureSubject.onNext(())
        }).disposed(by: bag)

        userSignature.data.asObservable().skip(1).subscribe(onNext: { [weak self] (value) in
            if (value) {
                self?.addSignature()
            } else {
                self?.removeSignature()
            }

            self?.userSignatureSubject.onNext(value)
        }).disposed(by: bag)
    }

    func addSignature() {
        guard let filename =  job.signatureImageName else {
            return
        }
        
        if ImageStorage.duplicate(for: SignatureViewController.defaultSignatureFileName, newFilename: filename) != ("-1", "-1") {
            logger.verbose("did copy the default signature.")
        }
        job.signatureName = Account.current().signatureName
        job.signedOn = Date()
        userSignature.signed(on: job.signedOn)
    }

    func removeSignature() {
        if let filename = job.signatureImageName {
            ImageStorage.deleteImage(for: filename)
        }
        job.signatureName = nil
        job.signature = nil
        job.signedOn = nil
        userSignature.signed(on: nil)
    }
}
