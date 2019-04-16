//
//  PageSizeSection.swift
//  InVoice
//
//  Created by Richard Marktl on 10.01.19.
//  Copyright © 2019 meisterwork GmbH. All rights reserved.
//

import Foundation
import UIKit

struct PageSelectItem {
    let size: JobPageSize
    var isSelected: Bool
}

class SelectPageSizeAction: TapActionable {
    typealias RowActionType = PageSelectItem
    
    func performTap(with rowItem: PageSelectItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
        Analytics.themeSelection.logEvent()
        
        if rowItem.isSelected {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        guard let model = model as? ThemeModel else { return }
        model.pageSizeSection.select(item: rowItem)
        
        tableView.reloadData()
    }
    
    func rewindAction(with rowItem: PageSelectItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: Model) {
        
    }
}

class PageSizeSection: Section {
    
    private let design: JobDesign
    
    init(design: JobDesign) {
        
        let currenSize = design.pageSize ?? JobPageSize.A4.rawValue
        self.design = design
        
        super.init(rows: [], headerTitle: R.string.localizable.selectAPageSize())
        setupRows(with: currenSize)
    }
    
    private func setupRows(with currenSize: String) {
        
        let row1 = PageSelectItem(size: JobPageSize.A4, isSelected: JobPageSize.A4.rawValue == currenSize)
        let row2 = PageSelectItem(size: JobPageSize.letter, isSelected: JobPageSize.letter.rawValue == currenSize)
        
        let action1 = SelectPageSizeAction()
        
        let rows: [ConfigurableRow] = [
            TableRow<PageSizeSelectCell, SelectPageSizeAction>(item: row1, action: action1),
            TableRow<PageSizeSelectCell, SelectPageSizeAction>(item: row2, action: action1),
        ]
        
        self.rows = rows
    }
    
    func select(item: PageSelectItem) {
        setupRows(with: item.size.rawValue)
        
        DispatchQueue.main.async { [weak self] in
            self?.design.pageSize = item.size.rawValue
            try? self?.design.managedObjectContext?.save()
        }
    }
}
