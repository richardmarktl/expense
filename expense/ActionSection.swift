//
//  ActionSection.swift
//  InVoice
//
//  Created by Georg Kitz on 27/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

class ActionSection: Section {
    
    private let job: Job
    
    init(job: Job) {
        self.job = job
        super.init(rows: [], headerTitle: R.string.localizable.actions())
        
        reloadData()
    }
    
    func reloadData() {
        let enabled = (job.remoteId != DefaultData.TestRemoteID)
        let cantSend = (!enabled) ? R.string.localizable.cantSent() : ""
        let sendStr = R.string.localizable.send(job.localizedTypeInMiddleOfSentence) + cantSend
        let shareStr = R.string.localizable.share(job.localizedTypeInMiddleOfSentence)
        let duplicate = R.string.localizable.duplicate(job.localizedType)
        
        var rows: [ConfigurableRow] = [
            TableRow<ActionCell, PreviewAction>(item: ActionItem(title: R.string.localizable.showPreview(),
                                                                 accessibilityIdentifier: "show_preview_action"), action: PreviewAction()),
            TableRow<ActionCell, SendAction>(item: ActionItem(title: sendStr,
                                                              accessibilityIdentifier: "send_action", isEnabled: enabled), action: SendAction()),
            TableRow<ActionCell, ShareJobAction>(item: ActionItem(title: shareStr,
                                                                  accessibilityIdentifier: "share_action"), action: ShareJobAction()),
            TableRow<ActionCell, DuplicateAction>(item: ActionItem(title: duplicate,
                                                                  accessibilityIdentifier: "duplicate"), action: DuplicateAction())
        ]
        
        if let offer = job as? Offer, offer.invoice == nil {
            let row: ConfigurableRow = TableRow<ActionCell, ConvertToInvoiceAction>(item: ActionItem(title: R.string.localizable.convertToInvoice()), action: ConvertToInvoiceAction())
            rows.append(row)
        }
        
        self.rows = rows
    }
}
