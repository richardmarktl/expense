//
//  ClientsModel.swift
//  InVoice
//
//  Created by Georg Kitz on 15/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation

import Foundation
import RxSwift
import CoreData

extension String {
    var cellFormattedAddress: String {
        return replacingOccurrences(of: "\n", with: ", ")
    }
}

/// MARK: -
/// Item to display the data in the cell
class ClientOverviewItem: ViewItem<Client>, Filterable {
    let client: String
    let address: String
    let identifier: String
    
    private let searchAddress: String
    private let searchId: String

    var hasEmail: Bool {
        if let email = item.email {
            return email.isEmpty == false
        }
        return false
    }

    override init(item: Client) {
        
        client = item.name ?? R.string.localizable.noName()
        identifier = item.uuid?.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true).first.map(String.init) ?? ""
        address = item.address?.cellFormattedAddress ?? R.string.localizable.noAddress()

        searchAddress = item.address ?? ""
        searchId = item.uuid ?? ""

        super.init(item: item)
    }
    
    func isFoundWithSearchString(searchString: String) -> Bool {
        return client.lowercased().contains(searchString) || searchAddress.lowercased().contains(searchString) || searchId.lowercased().contains(searchString)
    }
}

/// MARK: -
/// Select Client Action
fileprivate class SelectClientAction: ProTapAction<ClientOverviewItem> {
    override func performTap(with rowItem: ClientOverviewItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        if isProExpired {
            super.performTap(with: rowItem, indexPath: indexPath, tableView: tableView, ctr: ctr, model: model)
            return
        }
        
        //this ensures that the client is loaded in a childcontext to allow changes
        let nCtr =  ClientViewController.show(item: rowItem.item)
        Analytics.clientSelect.logEvent()
        ctr.present(nCtr, animated: true)
    }
}

class NoOperationClientAction: TapActionable {
    typealias RowActionType = ClientOverviewItem
    func performTap(with rowItem: ClientOverviewItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
    }
    
    func rewindAction(with rowItem: ClientOverviewItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
    }
}

/// MARK: -
/// Helper to abstract the different variants off how we load the data from the database
struct ClientOverviewItemHelper {
    
    /// Loads all available offers
    ///
    /// - Parameter context: ctx we load from
    /// - Returns: ViewItems we generate
    static func offerObservable(in context: NSManagedObjectContext) -> Observable<[ClientOverviewItem]> {
        
        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        return Observable.just(()).observeOn(background).flatMap { () -> Observable<[Client]> in 
            let predicate = NSPredicate.activeClients().and(.undeletedItem())
            return Client.rxAllObjects(matchingPredicate: predicate, context: context)
        }.map { clients in
            return clients.map { ClientOverviewItem(item: $0) }
        }.observeOn(MainScheduler.instance)
    }
    
    static func mapper(_ items: [ClientOverviewItem]) -> TableSection {
        
        let rows: [ConfigurableRow] = items.map({ (item) -> ConfigurableRow in
            let configRow: ConfigurableRow = TableRow<ClientsCell, SelectClientAction>(item: item, action: SelectClientAction())
            return configRow
        })
        return TableSection(rows: rows)
    }

    static func mailMapper(_ items: [ClientOverviewItem]) -> TableSection {
        let rows: [ConfigurableRow] = items.map({ (item) -> ConfigurableRow in
            let configRow: ConfigurableRow = TableRow<MailInvoiceClientCell, NoOperationClientAction>(item: item, action: NoOperationClientAction())
            return configRow
        })
        return TableSection(rows: rows)
    }
}

///// MARK: -
///// Model that combines the data loading + searching
class ClientsModel: SearchableTableModel<ClientOverviewItem> {
    convenience init(searchObservable: Observable<String>, with context: NSManagedObjectContext) {
        self.init(searchObservable: searchObservable, loadObservable: ClientOverviewItemHelper.offerObservable(in: context),
                  itemMapper: ClientOverviewItemHelper.mapper, defaultSections: [], with: context)
    }
}

class MailClientsModel: SearchableTableModel<ClientOverviewItem> {
    convenience init(searchObservable: Observable<String>, with context: NSManagedObjectContext) {
        self.init(searchObservable: searchObservable, loadObservable: ClientOverviewItemHelper.offerObservable(in: context),
                itemMapper: ClientOverviewItemHelper.mailMapper, defaultSections: [], with: context)
    }

}
