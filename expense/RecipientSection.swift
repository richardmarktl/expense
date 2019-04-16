//
// Created by Richard Marktl on 17.09.18.
// Copyright (c) 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

/// The class SignatureSections, contains the controls to add or remove a signature from the customer and
/// the user to the job.
class RecipientSection: Section {
    var job: Job

    private let bag = DisposeBag()

    init(job: Job, in context: NSManagedObjectContext) {
        self.job = job

        var rows: [ConfigurableRow] = []

        // get all thr recipients and checkout if the received the job and signed it.
        self.job.recipientsTyped.forEach({ (recipient) in
            let item = RecipientItem(recipient: recipient)
            rows.append(TableRow<RecipientCell, RecipientAction>(item: item, action: RecipientAction()))
        })

        super.init(rows: rows, headerTitle: R.string.localizable.recipientSection(), footerTitle: R.string.localizable.recipientFooter())
    }
}
