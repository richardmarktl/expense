//
//  Action+Item.swift
//  InVoice
//
//  Created by Richard Marktl on 20.11.17.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

/// This action will start the "add item cycle"
/// This action has 3 child actions.
/// - ItemNotFoundVoiceAction
/// - ItemFoundVoiceAction
/// - MultipleItemFoundVoiceAction
class AddItemVoiceAction: VoiceAction {
    init(parent action: VoiceAction) {
        super.init(parent: action,
                   voiceOutput: R.string.localizable.addItemAction(),
                   visualOutput: R.reuseIdentifier.questionViewCell.identifier,
                   config: action.config)
        removeUntil.append(OrderVoiceAction.self)
        isRepeatable = true
    }

    override func process(voiceInput input: String) -> VoiceAction {
        if input.isEmpty {
            return ItemNotFoundVoiceAction(parent: self, name: input)
        }

        // look for the clients in the database
        let items = searchFor(itemName: input)

        if items.count == 0 {
            return ItemNotFoundVoiceAction(parent: self, name: input)
        }
        if items.count == 1 {
            return ItemFoundVoiceAction(parent: self, item: items[0])
        }
        return MultipleItemFoundVoiceAction(parent: self, items: items)
    }

    private func searchFor(itemName: String) -> [Item] {
        let predicate = NSPredicate(format: "title contains [cd] %@", itemName).and(NSPredicate.undeletedItem())
        return Item.allObjects(matchingPredicate: predicate, context: config.childContext)
    }
}

/// The item was found now ask the user how many we need.
/// This action has 1 child action.
/// - HowManyItemsVoiceAction
class ItemFoundVoiceAction: VoiceAction {
    let item: Item
    init(parent action: VoiceAction, item: Item) {
        self.item = item
        super.init(parent: action, voiceOutput: R.string.localizable.itemFoundAction(), visualOutput: R.reuseIdentifier.orderViewCell.identifier, config: action.config)
        needsVoiceInput = false
        removeUntil.append(ItemFoundVoiceAction.self)
        removeUntil.append(AddItemVoiceAction.self)
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        return HowManyItemsVoiceAction(parent: self, item: item)
    }
}

/// This action will convert the voice input into a number.
/// This action has 1 child action.
/// - OrderVoiceAction
class HowManyItemsVoiceAction: VoiceAction {
    let item: Item
    let converter: TextToNumberConverter
    init(parent action: VoiceAction, item: Item) {
        self.item = item
        converter = TextToNumberConverter()
        super.init(parent: action, voiceOutput: R.string.localizable.amountItem(), visualOutput: R.reuseIdentifier.questionViewCell.identifier, config: action.config)
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        let order = Order(inContext: config.childContext)
        order.template = item
        order.quantity = converter.convert(input)
        
        return OrderVoiceAction(parent: self, order: order)
    }
}

/// This action will add the order to the invoice.
/// This action has 1 child action.
/// - NewItemQuestionVoiceAction
class OrderVoiceAction: VoiceAction {
    let order: Order
    
    init(parent action: VoiceAction, order: Order) {
        self.order = order
        if let item = self.order.template {
            self.order.itemDescription = item.itemDescription
            self.order.price = item.price
            self.order.tax = item.tax
        }
        self.order.uuid = UUID().uuidString.lowercased()
        self.order.createdTimestamp = Date()
        self.order.createdTimestamp = Date()
    
        super.init(parent: action, voiceOutput: R.string.localizable.itemFoundAction(),
                  visualOutput: R.reuseIdentifier.orderViewCell.identifier, config: action.config)
        needsVoiceInput = false
        removeUntil.append(OrderVoiceAction.self)
        removeUntil.append(AddItemVoiceAction.self)
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        return NewItemQuestionVoiceAction(parent: self)
    }

}

/// This action will try to create a new item. It will ask the user the price of item
/// This action has 1 child action.
/// - ItemTaxableQuestionAction
class ItemNotFoundVoiceAction: VoiceAction {
    var item: Item
    var converter: TextToNumberConverter
    init(parent action: VoiceAction, name: String) {
        item = Item(inContext: action.config.childContext)
        item.title = name
        item.itemDescription = name
        converter = TextToNumberConverter()
        
        super.init(parent: action,
                  voiceOutput: R.string.localizable.itemNotFoundAction(),
                  visualOutput: R.reuseIdentifier.questionViewCell.identifier,
                  config: action.config)
    }

    override func process(voiceInput input: String) -> VoiceAction {
        item.price = converter.convert(input)
        return ItemTaxableQuestionAction(parent: self, item: item)
    }
    
    override func prepareDeletion() {
        config.childContext.delete(item)
    }
}

/// This action will try to create a new item (second part). It will ask the user if the items is taxable.
/// This action has 1 child action.
/// - ItemTaxableVoiceAction
class ItemTaxableQuestionAction: VoiceAction {
    var item: Item
    
    init(parent action: VoiceAction, item: Item) {
        self.item = item
        super.init(parent: action,
                   voiceOutput: R.string.localizable.itemTaxable(),
                   visualOutput: R.reuseIdentifier.questionViewCell.identifier, config: action.config)
        needsVoiceInput = false
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        return ItemTaxableVoiceAction(parent: self, item: item)
    }
}

/// This action will convert the user input from the is taxable question into machine readable value
/// This action has 1 child action.
/// - NewItemVoiceAction
class ItemTaxableVoiceAction: DecisionVoiceAction {
    var order: Order
    init(parent action: VoiceAction, item: Item) {
        order = Order(inContext: action.config.childContext)
        order.template = item
        order.itemDescription = item.itemDescription
        order.price = item.price
        order.tax = item.tax
        
        super.init(parent: action)
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        if confirmed(voice: input) {
            order.tax = Account.current().tax
        } else {
            order.tax = 0
        }
        return NewItemVoiceAction(parent: self, order: order)
    }
    
    override func prepareDeletion() {
        config.childContext.delete(order)
    }
}

/// This action will ask the user want item he wants to add.
/// This action has 1 child action.
/// - MultipleItemSelectionVoiceAction
class MultipleItemFoundVoiceAction: VoiceAction {
    var items: [Item]
    
    init(parent action: VoiceAction, items: [Item]) {
        self.items = items
        super.init(parent: action,
                   voiceOutput: R.string.localizable.itemMultipleFoundAction(),
                   visualOutput: R.reuseIdentifier.questionViewCell.identifier,
                   config: action.config)
        needsVoiceInput = false
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        return MultipleItemSelectionVoiceAction(parent: self, items: items)
    }
}

/// This action will select the item according to the user.
/// This action has 1 child action.
/// - ItemFoundVoiceAction
class MultipleItemSelectionVoiceAction: VoiceAction {
    var items: [Item]
    var item: Item
    
    init(parent action: VoiceAction, items: [Item]) {
        self.items = items
        self.item = items[0]
        super.init(parent: action,
                   visualOutput: R.reuseIdentifier.multipleSelectionViewCell.identifier,
                   config: action.config)
        touchInputSubject = PublishSubject<Void>()
        needsVoiceInput = false
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        return ItemFoundVoiceAction(parent: self, item: item)
    }
}

/// This action will finish the order item if the user agrees.
/// This action has 2 child actions.
/// - AddItemVoiceAction (restart)
/// - OrderVoiceAction
class NewItemVoiceAction: VoiceAction {
    var order: Order?
    
    override lazy var controller: UIViewController? = {
        
        guard let order = order else {
            return nil
        }
        
        let completionBlock = { [unowned self] (item: Order) in
            self.order = item
            self.touchInputSubject?.onNext(())
        }
        
        let cancelBlock = {
            self.order = nil
            self.touchInputSubject?.onNext(())
        }
        
        // set the language for the order view controller.
        Locale.current.currencyCode.map(Currency.create).map(CurrencyLoader.update)
        return OrderViewController.show(item: order, in: order.managedObjectContext!, completionBlock: completionBlock, cancelBlock: cancelBlock)
    }()
    
    init(parent action: VoiceAction, order: Order) {
        self.order = order
        super.init(parent: action,
                   visualOutput: R.reuseIdentifier.answerViewCell.identifier,
                   config: action.config)
        touchInputSubject = PublishSubject<Void>()
        needsVoiceInput = false
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        if let order = order {
            return OrderVoiceAction(parent: self, order: order)
        }
        let action = AddItemVoiceAction(parent: self)
        action.removeUntil.append(ClientFoundVoiceAction.self)
        return action
    }
}

/// This action will state the add another item qeustion.
/// This action has 1 child action.
/// - NewItemDecisionVoiceAction
class NewItemQuestionVoiceAction: VoiceAction {
    init(parent action: VoiceAction) {
        super.init(parent: action, voiceOutput: R.string.localizable.repeatItem(), visualOutput: R.reuseIdentifier.questionViewCell.identifier, config: action.config)
        needsVoiceInput = false
    }
    
    override func process(voiceInput input: String) -> VoiceAction {
        return NewItemDecisionVoiceAction(parent: self)
    }
}

/// This is the repeat item action, in the case the user agrees we restart the add item process, or we end it.
/// This action has 2 child actions.
/// - AddItemVoiceAction
/// - EndVoiceAction
class NewItemDecisionVoiceAction: DecisionVoiceAction {
    override func process(voiceInput input: String) -> VoiceAction {
        if confirmed(voice: input) == true {
            return AddItemVoiceAction(parent: self)
        }
        return EndVoiceAction(parent: self)
    }
}

/// This is the last action to handle, after that the invoice is finished.
/// This action has no child actions.
class EndVoiceAction: VoiceAction {
    override var repeatableParent: VoiceAction? {
        return nil
    }
    
    init(parent action: VoiceAction) {
        super.init(parent: action, visualOutput: R.reuseIdentifier.saveViewCell.identifier, config: action.config)
        needsVoiceInput = false
        
        removeUntil.append(OrderVoiceAction.self)
        removeUntil.append(AddItemVoiceAction.self)
    }
}
