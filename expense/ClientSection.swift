//
//  ClientSection.swift
//  InVoice
//
//  Created by Georg Kitz on 27/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

class ClientSection: Section {
    
    private let job: Job
    private var clientItem: ClientItem?
    
    var client: Client? {
        return clientItem?.value
    }
    
    private let changeSubject: PublishSubject<Void> = PublishSubject()
    override var changedObservable: Observable<Void> {
        return changeSubject.asObservable().skip(1)
    }
    
    init(job: Job) {
        
        self.job = job
        
        super.init(rows: [], headerTitle: R.string.localizable.billTo())
        
        if let client = job.client {
            client.update(from: job)
            update(with: client)
        } else {
            removeClient()
        }
    }
    
    func removeClient() {
        let addItem = AddItem(title: R.string.localizable.addClient(), image: R.image.add_client()!, automatedTestingType: .client)
        rows = [TableRow<AddCell, AddClientAction>(item: addItem, action: AddClientAction())]
        
        job.client = nil
        job.update(from: nil)
        
        changeSubject.onNext(())
    }
    
    func update(with client: Client) {
        let clientItem = ClientItem(defaultData: client)
        rows = [TableRow<ClientCell, ClientAction>(item: clientItem, action: ClientAction())]
        
        job.client = client
        job.update(from: client)
        
        self.clientItem = clientItem
        changeSubject.onNext(())
    }
}
