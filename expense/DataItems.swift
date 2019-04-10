//
//  DataItems.swift
//  InVoice
//
//  Created by Georg Kitz on 15/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import ImageStorage


// MARK: RowItem stuff
class BasicItem<DataType> {
    var title: String
    fileprivate(set) var data: Variable<DataType>
    var value: DataType {
        return data.value
    }
    
    init(title: String = "", defaultData: DataType) {
        self.title = title
        self.data = Variable(defaultData)
    }
}

class BoolItem: BasicItem<Bool> {
    private let resetSubject = PublishSubject<Bool>()
    public var resetObservable: Observable<Bool> {
        return resetSubject.asObservable()
    }
    
    public var isProFeature: Bool = false
    
    func update(_ value: Bool) {
        data.value = value
    }
    
    /// This method is used to inform views and observers that the change
    /// of the data.value was not success full.
    ///
    /// - Parameter value: The old value
    func reset(_ value: Bool) {
        resetSubject.onNext(value)
    }
}

//class DateItem: BasicItem<Date> {
//    var isExpanded: Bool = false
//    var formattedDateObservable: Observable<String> {
//        return data.asObservable().map({ (date) -> String in
//            return date.asString(.medium, timeStyle: .none)
//        })
//    }
//
//    class func date(for job: Job?) -> DateItem {
//        let date = job?.date ?? moment().startOf(.Days).date
//        return DateItem(title: R.string.localizable.dateTitle(), defaultData: date)
//    }
//
//    class func dueDate(for invoice: Invoice?) -> DateItem {
//        let date = invoice?.dueTimestamp ?? moment().startOf(.Days).add(7, .Days).date
//        return DateItem(title: R.string.localizable.dueDateTitle(), defaultData: date)
//    }
//}

//class PickerItem<T: PickerItemInterface>: BasicItem<T> {
//
//    class DataSource<T: PickerItemInterface>: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
//
//        let items: [T]  = T.all;
//
//        func numberOfComponents(in pickerView: UIPickerView) -> Int {
//            return 1
//        }
//
//        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//            return items.count
//        }
//
//        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//            return items[row].displayName
//        }
//    }
//
//    let datasource = DataSource<T>()
//
//    var isExpanded: Bool = false
//    var selectedIndex: Int {
//        return datasource.items.index(of: data.value) ?? 0
//    }
//
//    convenience init(title: String, value: String) {
//        let data = T.create(from: value)
//        self.init(title: title, defaultData: data)
//    }
//}
//
//class LanguageItem: PickerItem<Language> {
//
//    convenience init(for job: Job) {
//        let languageCode = job.language ?? Locale.current.languageCode ?? ""
//        self.init(title: R.string.localizable.languageSelector(), value: languageCode)
//    }
//}
//
//class CurrencyItem: PickerItem<Currency> {
//    convenience init(for job: Job) {
//        let currency = job.currency ?? Locale.current.currencyCode ?? ""
//        self.init(title: R.string.localizable.currencySelector(), value: currency)
//    }
//}
//
//class DatePickerItem: BasicItem<Date> {
//    convenience init(data: Variable<Date>) {
//        self.init(defaultData: data.value)
//        self.data = data
//    }
//}

enum AddTestingType: String {
    case none
    case client
    case item
}

class AddItem: BasicItem<Void> {
    let image: UIImage?
    let automatedTestingType: AddTestingType
    init(title: String, image: UIImage? = nil, automatedTestingType: AddTestingType = .none) {
        self.image = image
        self.automatedTestingType = automatedTestingType
        super.init(title: title, defaultData: ())
    }
}

class ClientItem: BasicItem<Client> {
    
    private(set) var clientName: String = ""
    private(set) var clientInfo: String = ""
    
    init(defaultData: Client) {
        super.init(defaultData: defaultData)
        update(with: defaultData)
    }
    
    func update(with client: Client) {
        clientName = client.name ?? ""
        clientInfo = client.email ?? (client.phone ?? "")
        data.value = client
    }
}

//class OrderItem: BasicItem<Order> {
//
//    private(set) var itemName: String = ""
//    private(set) var itemDetails: String = ""
//    private(set) var itemTotal: String = ""
//
//    init(defaultData: Order) {
//        super.init(defaultData: defaultData)
//        update(with: defaultData)
//    }
//
//    func update(with order: Order) {
//
//        guard let title = order.title, let quantity = order.quantity, let price = order.price, let total = order.total else {
//            return
//        }
//
//        itemName = title
//        let currencyCode = order.item?.currency
//        itemDetails = String(quantity.intValue) + " x " + price.asCurrency(currencyCode: currencyCode)
//
//        if let discount = order.discount, discount != NSDecimalNumber.zero {
//            if order.isDiscountAbsolute {
//                itemDetails += " " + R.string.localizable.withDiscount(discount.asCurrency(currencyCode: currencyCode))
//            } else {
//                let discountString = String(discount.intValue) + "%"
//                itemDetails += " " + R.string.localizable.withDiscount(discountString)
//            }
//        }
//
//        itemTotal = total.asCurrency(currencyCode: currencyCode)
//        itemName = order.title ?? ""
//        data.value = order
//    }
//}
//
//class AttachmentItem: BasicItem<Attachment?> {
//
//    var thumbImage: Observable<UIImage> {
//        guard let filename = value?.uuid else {return Observable.empty()}
//
//        let obs: Observable<ImageStorageItem>
//        if let url = value?.file, ImageStorage.hasItemStoredOnFileSystem(filename: filename) == false {
//            obs = ImageStorage.download(fromURL: url, filename: filename)
//        } else {
//            obs = ImageStorage.loadImage(for: filename)
//        }
//
//        return obs.map { $0.thumbnail }
//    }
//
//    var imageURL: URL {
//        guard let internalFilename = value?.uuid, let item = ImageStorage.loadAlreadyLoadedItem(for: internalFilename) else {
//            return URL(fileURLWithPath: ".")
//        }
//        return item.imageURL
//    }
//
//    convenience init(attachment: Attachment) {
//        let title = attachment.fileName?.removeJPGFileExtension ?? ""
//        self.init(title: title, defaultData: attachment)
//    }
//
//    convenience init() {
//        let dateTitle = R.string.localizable.attachment() + Date().asString(.medium, timeStyle: .none)
//        self.init(title: dateTitle, defaultData: nil)
//    }
//
//    func update(title newTitle: String) {
//        title = newTitle
//        value?.fileName = newTitle.removeJPGFileExtension
//    }
//}

class ActionItem: BasicItem<Void> {
    let accessibilityIdentifier: String?
    let isEnabled: Bool
    init(title: String, accessibilityIdentifier: String? = nil, isEnabled: Bool = true) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.isEnabled = isEnabled
        super.init(title: title, defaultData: ())
    }
}

class RecipientItem: BasicItem<Recipient> {
    convenience init(recipient: Recipient) {
        let title = recipient.signatureName ?? (recipient.to ?? R.string.localizable.noName())
        self.init(title: title, defaultData: recipient)
    }
}
