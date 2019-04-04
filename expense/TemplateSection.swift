//
//  TemplateSection.swift
//  InVoice
//
//  Created by Georg Kitz on 09/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit

struct SelectItem {
    let template: InvoiceTemplate
    var isSelected: Bool
}

class SelectTemplateAction: TapActionable {
    typealias RowActionType = SelectItem
    
    func performTap(with rowItem: SelectItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        Analytics.themeSelection.logEvent()
        
        if rowItem.isSelected {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        guard let model = model as? ThemeModel else { return }
        model.templateSection.select(item: rowItem)
        
        tableView.reloadData()
    }
    
    func rewindAction(with rowItem: SelectItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
    }
}

class TemplateSection: TableSection {
    
    private let design: JobDesign
    
    init(design: JobDesign) {
        
        let currentTemplate = design.template ?? ""
        self.design = design
        
        super.init(rows: [], headerTitle: R.string.localizable.selectATemplate())
        setupRows(with: currentTemplate)
    }
    
    private func setupRows(with currentTemplate: String) {
        
        let row1 = SelectItem(template: InvoiceTemplate.clean, isSelected: InvoiceTemplate.clean.rawValue == currentTemplate)
        let row2 = SelectItem(template: InvoiceTemplate.bold, isSelected: InvoiceTemplate.bold.rawValue == currentTemplate)
        let row3 = SelectItem(template: InvoiceTemplate.plain, isSelected: InvoiceTemplate.plain.rawValue == currentTemplate)
        let row4 = SelectItem(template: InvoiceTemplate.modern, isSelected: InvoiceTemplate.modern.rawValue == currentTemplate)
        
        let action1 = SelectTemplateAction()
        
        let rows: [ConfigurableRow] = [
            TableRow<TemplateSelectCell, SelectTemplateAction>(item: row1, action: action1),
            TableRow<TemplateSelectCell, SelectTemplateAction>(item: row2, action: action1),
            TableRow<TemplateSelectCell, SelectTemplateAction>(item: row3, action: action1),
            TableRow<TemplateSelectCell, SelectTemplateAction>(item: row4, action: action1)
        ]
        
        self.rows = rows
    }
    
    func select(item: SelectItem) {
        setupRows(with: item.template.rawValue)
        
        DispatchQueue.main.async { [weak self] in
            self?.design.template = item.template.rawValue
            try? self?.design.managedObjectContext?.save()
        }
    }
}
