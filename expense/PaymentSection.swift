//
//  PaymentSection.swift
//  InVoice
//
//  Created by Richard Marktl on 30.03.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

typealias PaymentRegisterBlock = () -> Void

/// The class PaymentSection, contains the all the possible payment provider.
class PaymentSection: TableSection {
    let stripe: StripeEntry
    let paypal: PayPalEntry

    private let paypalSubject: PublishSubject<Void> = PublishSubject()
    private let stripeSubject: PublishSubject<Void> = PublishSubject()
    
    public var paypalObservable: Observable<Void> {
        return paypalSubject.asObservable()
    }
    public var stripeObservable: Observable<Void> {
        return stripeSubject.asObservable()
    }

    private let bag = DisposeBag()
    
    init(job: Invoice, in context: NSManagedObjectContext) {
        var rows: [ConfigurableRow] = []
        let shouldShowProBadge = !StoreService.instance.hasValidReceipt
        
        stripe = StripeEntry(invoice: job, isProFeature: shouldShowProBadge)
        paypal = PayPalEntry(invoice: job, isProFeature: shouldShowProBadge)
        
        // in the case no country was found on the server during the address geocoding, we will show no stripe
        // payment action.
        if Account.current().hasCountry {
            rows.append(TableRow<SwitchCell, NoOperationBoolAction>(item: stripe, action: NoOperationBoolAction()))
        }
        rows.append(TableRow<SwitchCell, NoOperationBoolAction>(item: paypal, action: NoOperationBoolAction()))
        
        super.init(rows: rows, headerTitle: R.string.localizable.paymentSection())
        
        stripe.data.asObservable().skip(1).subscribe(onNext: { [weak self] (value) in
            if Account.current().isStripeActivated {
                job.isStripeActivated = value
            } else {
                self?.stripeSubject.onNext(())
            }
        }).disposed(by: bag)
        
        paypal.data.asObservable().skip(1).subscribe(onNext: {  [weak self] (value) in
            if Account.current().paypalId != nil {
                job.isPayPalActivated = value
            } else {
                self?.paypalSubject.onNext(())
            }
        }).disposed(by: bag)
    }
}
