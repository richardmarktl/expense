//
//  Api.swift
//  InVoice
//
//  Created by Georg Kitz on 16/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import Moya
import ImageStorage

//swiftlint:disable file_length
typealias RegisterCompanyParameter = (email: String, name: String, language: String, locale: String, currency: String, password: String?)
typealias ValidationParameter = (uid: String, token: String)

typealias DeviceParameter = (uuid: String, token: String, device: String, appVersion: String, osVersion: String, locale: String, carrier: String)

typealias ClientParameter = (uuid: String, number: String?, name: String?, phone: String?, taxId: String?, email: String?, website: String?, address: String?, isActive: Bool?)
typealias JobParameter = (uuid: String, number: String, date: String, discount: String, isDiscountAbsolute: Bool, total: String, state: Int32,
    paymentDetails: String?, note: String?, currency: String?, language: String?, clientRemoteId: Int64?, client: ClientParameter?, 
    signature: Data?, signedOn: String?, signatureName: String?, signatureUpdate: FileUpdate, needsSignature: Bool)
typealias ItemParameter = (uuid: String, number: String?, title: String, description: String, price: String, tax: Double)
typealias OrderParameter = (uuid: String, number: String?, title: String, description: String, price: String, tax: Double, discount: Double, isDiscountAbsolute: Bool,
    total: String, quantity: Double, job: Int64, sort: Int16, template: TemplateParameter)
typealias InvoiceParameter = (jobParameter: JobParameter, due: String, paid: String?, paypal: Bool?, stripe: Bool?)
typealias AttachmentParameter = (uuid: String, fileName: String, mimeType: String, sort: Int16, data: Data, job: Int64)
typealias PaymentParameter = (uuid: String, amount: String, type: String, date: String, note: String?, job: Int64)
typealias AccountParameter = (uuid: String, name: String?, phone: String?, taxId: String?, email: String?,
    website: String?, address: String?, tax: Double?, paymentDetails: String?, note: String?, language: String,
    locale: String, currency: String, paypalId: String?, stripe: Bool?)
public typealias MailParameter = (data: Data, text: String, recipients: [[String: String]])
typealias TemplateParameter = (remoteId: Int64?, parameter: ItemParameter?)

typealias DesignParameters = (template: String, color: String, attachmentHideTitle: Bool, attachmentFullWidth: Bool, showArticleNumber: Bool, showArticleTitle: Bool, showArticleDescription: Bool, pageSize: String)
typealias LocalizationParameters = (uuid: String, paymentDetailsTitle: String?, headerArticle: String?, invoiceNumberTitle: String?, headerPrice: String?, offerNumberTitle: String?,
    offerTitle: String?, vatsTitle: String?, invoiceTitle: String?, language: String, discountTitle: String?, dateTitle: String?, headerTotal: String?,
    balanceTitle: String?, subtotalTitle: String?, headerQuantity: String?, dueDateTitle: String?, paidTitle: String?, headerDescription: String?, headerArticleNumber: String?)
typealias SendParameters = (to: String, text: String, name: String, uuid: String)
typealias DefaultsParameters = (note: String, paymentDetails: String, message: String, prefix: String, start: Int32, minimumLength: Int16, due: Int16)

/// This enum is used to determine if need to upload or reupload an file file in an api call.
///
/// - none: the file did not change, exclude the file from the api call
/// - update: the file did change add the file data for a upload or null to remove the file
public enum FileUpdate {
    case none
    case update
}

public enum Path: String {
    case offer
    case invoice
    
    var pluralized: String {
        return self.rawValue + "s"
    }
}

extension Path {
    init(with job: Job) {
        self = job is Offer ? .offer : .invoice
    }
}

enum Api {
    
    case login(email: String)
    case loginNormal(name: String, email: String, password: String)
    case register(parameters: RegisterCompanyParameter)
    case registerActive(parameters: RegisterCompanyParameter)
    case validate(parameters: ValidationParameter)
    
    case account(updatedAfter: String?)
    case updateAccount(parameters: AccountParameter)
    case updateAccountTrail(trailStart: Date, trailEnded: Date)
    case updateLogoForAccount(data: Data?, filename: String?)
    case updatePro(isPro: Bool)
    
    case updateDesign(parameters: DesignParameters)
    case design(updatedAfter: String?)
    
    case updateDefaults(path: Path, parameter: DefaultsParameters)
    case defaults(path: Path, updatedAfter: String?)
    
    case createLocalization(parameters: LocalizationParameters)
    case updateLocalization(id: Int64, parameters: LocalizationParameters)
    case deleteLocalization(id: Int64)
    case listLocalization(cursor: String?, updateAfter: String?)
    
    case createDevice(parameters: DeviceParameter)
    case updateDevice(id: Int64, parameters: DeviceParameter)
    
    case createOffer(parameters: JobParameter)
    case updateOffer(id: Int64, parameters: JobParameter)
    case deleteOffer(id: Int64)
    case listOffers(cursor: String?, updatedAfter: String?)
    case offer(id: Int64)
    case nextOfferId
    
    case createClient(parameters: ClientParameter)
    case updateClient(id: Int64, parameters: ClientParameter)
    case deleteClient(id: Int64)
    case listClients(cursor: String?, updatedAfter: String?)
    
    case createInvoice(parameters: InvoiceParameter)
    case updateInvoice(id: Int64, parameters: InvoiceParameter)
    case deleteInvoice(id: Int64)
    case listInvoices(cursor: String?, updatedAfter: String?)
    case invoice(id: Int64)
    case nextInvoiceId
    
    case createItem(parameters: ItemParameter)
    case updateItem(id: Int64, parameters: ItemParameter)
    case deleteItem(id: Int64)
    case listItems(cursor: String?, updatedAfter: String?)
    
    case createOrder(path: Path, parameters: OrderParameter)
    case updateOrder(path: Path, id: Int64, parameters: OrderParameter)
    case deleteOrder(path: Path, id: Int64)
    case listOrders(path: Path, cursor: String?, updatedAfter: String?)
    
    case createAttachment(path: Path, parameters: AttachmentParameter)
    case updateAttachmentData(path: Path, id: Int64, parameters: AttachmentParameter)
    case updateAttachment(path: Path, id: Int64, filename: String, sort: Int16)
    case deleteAttachment(path: Path, id: Int64)
    case listAttachments(path: Path, cursor: String?, updatedAfter: String?)
    
    case deleteRecipient(path: Path, id: Int64)
    case listRecipients(path: Path, cursor: String?, jobId: Int64?, updatedAfter: String?)
    case updateRecipientSignature(path: Path, id: Int64, data: Data, filename: String)
    
    case createPayment(parameters: PaymentParameter)
    case updatePayment(id: Int64, parameters: PaymentParameter)
    case deletePayment(id: Int64)
    case listPayments(cursor: String?, invoiceId: Int64?, updatedAfter: String?)
    
    case sendNewJob(path: Path, parameters: InvoiceParameter, mail: MailParameter)
    case sendJob(path: Path, id: Int64, parameters: InvoiceParameter, mail: MailParameter)
    case send(path: Path, id: Int64, parameters: SendParameters)
    
    case updateSignatureData(path: Path, id: Int64, data: Data)
}

extension Api: TargetType {
    
    var baseURL: URL {
        //swiftlint:disable force_cast
        let urlString = Bundle.main.infoDictionary!["API_ENDPOINT"] as! String
        return URL(string: urlString)!
        //swiftlint:enable force_cast
    }
    
    var path: String {
        switch self {
        case .login:
            return "/account/device/login/"
        case .loginNormal:
            return "/account/login/"
        case .register:
            return "/account/register/"
        case .registerActive:
            return "/account/register/active/"
        case .validate:
            return "/account/device/token/"
        case .account, .updateAccount, .updateAccountTrail, .updateLogoForAccount, .updatePro:
            return "/account/account/"
        case .updateDesign, .design:
            return "/account/design/"
            
        case .updateDefaults(let path, _), .defaults(let path, _):
            return "/\(path.rawValue)/defaults/"
            
        case .createLocalization, .listLocalization:
            return "/account/localizations/"
        case .updateLocalization(let id, _), .deleteLocalization(let id):
            return "/account/localizations/\(id)/"
            
        case .createDevice:
            return "/devices/"
        case .updateDevice(let identifier, _):
            return "/devices/\(identifier)/"
            
        case .listOffers, .createOffer:
            return "/offers/"
        case .updateOffer(let identifier, _), .deleteOffer(let identifier), .offer(let identifier):
            return "/offers/\(identifier)/"
        case .nextOfferId:
            return "/offer/next/"
            
        case .listInvoices, .createInvoice:
            return "/invoices/"
        case .updateInvoice(let identifier, _), .deleteInvoice(let identifier), .invoice(let identifier):
            return "/invoices/\(identifier)/"
        case .nextInvoiceId:
            return "/invoice/next/"
            
        case .listClients, .createClient:
            return "/clients/"
        case .updateClient(let identifier, _), .deleteClient(let identifier):
            return "/clients/\(identifier)/"
            
        case .listItems, .createItem:
            return "/items/"
        case .updateItem(let identifier, _), .deleteItem(let identifier):
            return "/items/\(identifier)/"
            
        case .listOrders(let path, _, _), .createOrder(let path, _):
            return "/\(path.rawValue)/orders/"
        case .updateOrder(let path, let identifier, _), .deleteOrder(let path, let identifier):
            return "/\(path.rawValue)/orders/\(identifier)/"
            
        case .listAttachments(let path, _, _), .createAttachment(let path, _):
            return "/\(path.rawValue)/attachments/"
        case .updateAttachment(let path, let identifier, _, _), .updateAttachmentData(let path, let identifier, _), .deleteAttachment(let path, let identifier):
            return "/\(path.rawValue)/attachments/\(identifier)/"
            
        case .listRecipients(let path, _, _, _):
            return "/\(path.rawValue)/recipients/"
        case .deleteRecipient(let path, let identifier), .updateRecipientSignature(let path, let identifier, _, _):
            return "/\(path.rawValue)/recipients/\(identifier)/"
            
        case .listPayments, .createPayment:
            return "/invoice/payments/"
        case .updatePayment(let identifier, _), .deletePayment(let identifier):
            return "/invoice/payments/\(identifier)/"
            
        case .sendNewJob(let path, _, _):
            return "\(path.rawValue)/mail/"
        case .sendJob(let path, let identifier, _, _):
            return "\(path.rawValue)/mail/\(identifier)/"
        case .send(let path, let identifier, _):
            return "\(path.rawValue)s/\(identifier)/send/"
            
        case .updateSignatureData(let path, let id, _):
            return "\(path.pluralized)/\(id)/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login,
             .loginNormal,
             .register,
             .registerActive,
             .validate,
             .createItem,
             .createOffer,
             .createOrder,
             .createClient,
             .createInvoice,
             .createAttachment,
             .createPayment,
             .createDevice,
             .sendNewJob,
             .send,
             .createLocalization:
            return Moya.Method.post
        case .updateAccount,
             .updateAccountTrail,
             .updatePro,
             .updateLogoForAccount,
             .updateItem,
             .updateOffer,
             .updateOrder,
             .updateClient,
             .updateInvoice,
             .updateAttachment,
             .sendJob,
             .updateDevice,
             .updatePayment,
             .updateDesign,
             .updateLocalization,
             .updateDefaults,
             .updateRecipientSignature,
             .updateAttachmentData,
             .updateSignatureData:
            return Moya.Method.patch
        case .account,
             .listItems,
             .listOffers,
             .offer,
             .listOrders,
             .listClients,
             .listInvoices,
             .invoice,
             .listAttachments,
             .listPayments,
             .design,
             .listLocalization,
             .listRecipients,
             .nextOfferId,
             .nextInvoiceId,
             .defaults:
            return Moya.Method.get
        case .deleteItem,
             .deleteOffer,
             .deleteOrder,
             .deleteClient,
             .deleteInvoice,
             .deleteAttachment,
             .deletePayment,
             .deleteLocalization,
             .deleteRecipient:
            return Moya.Method.delete
        }
    }
    
    var sampleData: Data {
        switch self {
        case .login(let email), .loginNormal(_, let email, _):
            return email.contains("fail") ? stubbedResponse("login_failed") : stubbedResponse("login")
        case .register, .registerActive:
            return stubbedResponse("register")
        case .validate:
            return stubbedResponse("validate")
        case .account:
            return stubbedResponse("account")
        case .updateAccount, .updateAccountTrail, .updatePro:
            return stubbedResponse("account_update")
        case .createDevice:
            return stubbedResponse("device")
        case .updateDevice:
            return stubbedResponse("device_updated")
        case .listClients(let values):
            return values.cursor == nil ? stubbedResponse("clients") : stubbedResponse("clients_abc")
        case .createClient:
            return stubbedResponse("client")
        case .updateClient:
            return stubbedResponse("client_updated")
        case .listItems(let values):
            return values.cursor == nil ? stubbedResponse("items") : stubbedResponse("items_abc")
        case .createItem:
            return stubbedResponse("item")
        case .updateItem:
            return stubbedResponse("item_updated")
        case .listOrders(_, let cursor, _):
            return cursor == nil ? stubbedResponse("orders") : stubbedResponse("orders_abc")
        case .createOrder(let path, let parameters):
            if path == .invoice && (parameters.template.parameter != nil || parameters.template.remoteId != nil) {
                return stubbedResponse("invoice_order_template_id")
            }
            return stubbedResponse("\(path)_order")
        case .updateOrder(let path, _, _):
            return stubbedResponse("\(path)_order_updated")
        case .listOffers:
            return stubbedResponse("invoices")
        case .offer:
            return stubbedResponse("invoice_single")
        case .createOffer:
            return stubbedResponse("offer")
        case .updateOffer:
            return stubbedResponse("offer_updated")
        case .listInvoices:
            return stubbedResponse("invoices")
        case .invoice(let remoteId):
            return remoteId == 0 || remoteId == 1 ? stubbedResponse("invoice_single") : stubbedResponse("invoice_\(remoteId)")
        case .createInvoice:
            return stubbedResponse("invoice")
        case .updateInvoice:
            return stubbedResponse("invoice_updated")
        case .listPayments(let cursor, _, _):
            return cursor == nil ? stubbedResponse("payments") : stubbedResponse("payments_abc")
        case .createPayment:
            return stubbedResponse("payment")
        case .updatePayment:
            return stubbedResponse("payment_updated")
        case .listAttachments:
            return stubbedResponse("attachments")
        case .listRecipients:
            return stubbedResponse("attachments")
        case .sendNewJob(let path, _, _):
            return stubbedResponse("send_\(path)")
        case .sendJob(let path, _, _, _):
            return stubbedResponse("send_\(path)_update")
        case .deleteItem, .deleteOrder, .deleteOffer, .deleteInvoice, .deleteClient, .deleteAttachment, .deletePayment, .deleteRecipient:
            return stubbedResponse("delete")
        default:
            let name = String(describing: self)
            return stubbedResponse(name)
        }
    }
    
    var task: Task {
        switch self {
        case .login(let email):
            return Task.requestParameters(parameters: ["email": email], encoding: JSONEncoding.default)
        
        case .loginNormal(let name, let email, let password):
            return Task.requestParameters(parameters: ["email": email, "name": name, "password": password], encoding: JSONEncoding.default)
            
        case .register(let parameter), .registerActive(let parameter):
            var json: [String: String] = [
                "email": parameter.email,
                "name": parameter.name,
                "language": parameter.language,
                "locale": parameter.locale,
                "currency": parameter.currency
            ]
            if let password = parameter.password {
                json["password"] = password
            }
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
        
        case .validate(let parameters):
            let json = ["uid": parameters.uid, "token": parameters.token]
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
            
        case .updateAccount(let parameter):
            var json: [String: Any] = [
                "uuid": parameter.uuid,
                "phone": parameter.phone.apiValue,
                "name": parameter.name.apiValue,
                "address": parameter.address.apiValue,
                "tax_id": parameter.taxId.apiValue,
                "email": parameter.email.apiValue,
                "website": parameter.website.apiValue,
                "note": parameter.note.apiValue,
                "payment_details": parameter.paymentDetails.apiValue,
                "tax": parameter.tax.apiValue,
                "locale": parameter.locale,
                "language": parameter.language,
                "currency": parameter.currency,
                "paypal_id": parameter.paypalId.apiValue
            ]
            // thew .apiValue always returns false if the value is empty, but the api also ignores the field
            // if the value is not determined
            if let stripe = parameter.stripe {
                json["stripe"] = stripe
            }
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
        
        case .updateAccountTrail(let start, let end):
            let json: [String: String] = [
                "trail_started": start.ISO8601DateTimeString,
                "trail_ended": end.ISO8601DateTimeString
            ]
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
        
        case .updatePro(let isPro):
            let json: [String: Any] = [
                "is_pro": isPro
            ]
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
            
        case .updateLogoForAccount(let data, let filename):
            guard let data = data else {
                return Task.requestParameters(parameters: ["logo": NSNull()], encoding: JSONEncoding.default)
            }
            let logo = MultipartFormData(provider: .data(data), name: "logo", fileName: filename?.withJPGFileExtension, mimeType: AttachmentMimeType.jpeg.rawValue)
            return Task.uploadMultipart([logo])
            
        case .updateRecipientSignature( _, _,let data, let filename):
            let file = MultipartFormData(provider: .data(data), name: "signature", fileName: filename.withJPGFileExtension, mimeType: AttachmentMimeType.jpeg.rawValue)
            return Task.uploadMultipart([file])
    
        case .createDevice(let parameter), .updateDevice(_, let parameter):
            let json: [String: Any] = [
                "uuid": parameter.uuid,
                "locale": parameter.locale,
                "device": 1,  // 0 = Android, 1 = iOS
                "app_version": parameter.appVersion,
                "token": parameter.token,
                "network_operator": parameter.carrier,
                "brand": parameter.device,
                "os_version": parameter.osVersion
            ]
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
            
        case .createOffer(let parameter), .updateOffer(_, let parameter):
            var json: [String: Any] = [
                "client_phone": parameter.client?.phone.apiValue ?? NSNull(),
                "client_name": parameter.client?.name.apiValue ?? NSNull(),
                "client_address": parameter.client?.address.apiValue ?? NSNull(),
                "client": parameter.clientRemoteId ?? NSNull(),
                "client_tax_id": parameter.client?.taxId.apiValue ?? NSNull(),
                "client_email": parameter.client?.email.apiValue ?? NSNull(),
                "client_website": parameter.client?.website.apiValue ?? NSNull(),
                "client_number": parameter.client?.number.apiValue ?? NSNull(),
                "signed_on": parameter.signedOn.apiValue,
                "signature_name": parameter.signatureName.apiValue,
                "needs_signature": parameter.needsSignature,
                "uuid": parameter.uuid,
                "discount": parameter.discount,
                "note": parameter.note.apiValue,
                "payment_details": parameter.paymentDetails.apiValue,
                "language": parameter.language.apiValue,
                "currency": parameter.currency.apiValue,
                "date": parameter.date,
                "total": parameter.total,
                "discount_absolute": parameter.isDiscountAbsolute,
                "number": parameter.number
            ]
            if parameter.signatureUpdate == .update {
                if let data = parameter.signature {
                    json["signature"] = [
                        "file_data": data.base64EncodedString(),
                        "file_name": "signature.png"
                    ]
                } else {
                    json["signature"] = NSNull()
                }
            }
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
            
        case .createInvoice(let allParameters), .updateInvoice(_, let allParameters):
            let parameter = allParameters.jobParameter
            var json: [String: Any] = [
                "client_phone": parameter.client?.phone.apiValue ?? NSNull(),
                "client_name": parameter.client?.name.apiValue ?? NSNull(),
                "client_address": parameter.client?.address.apiValue ?? NSNull(),
                "client": parameter.clientRemoteId ?? NSNull(),
                "client_tax_id": parameter.client?.taxId.apiValue ?? NSNull(),
                "client_email": parameter.client?.email.apiValue ?? NSNull(),
                "client_website": parameter.client?.website.apiValue ?? NSNull(),
                "client_number": parameter.client?.number.apiValue ?? NSNull(),
                "signed_on": parameter.signedOn.apiValue,
                "signature_name": parameter.signatureName.apiValue,
                "needs_signature": parameter.needsSignature,
                "uuid": parameter.uuid,
                "discount": parameter.discount,
                "note": parameter.note.apiValue,
                "payment_details": parameter.paymentDetails.apiValue,
                "language": parameter.language.apiValue,
                "currency": parameter.currency.apiValue,
                "date": parameter.date,
                "total": parameter.total,
                "discount_absolute": parameter.isDiscountAbsolute,
                "number": parameter.number,
                "due": allParameters.due,
                "paid": allParameters.paid.apiValue,
                "stripe": allParameters.stripe.apiValue,
                "paypal": allParameters.paypal.apiValue
            ]
            if parameter.signatureUpdate == .update {
                if let data = parameter.signature {
                    json["signature"] = [
                        "file_data": data.base64EncodedString(),
                        "file_name": "signature.png"
                    ]
                } else {
                    json["signature"] = NSNull()
                }
            }
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
            
        case .updateSignatureData( _, _, let data):
            var json: [String: Any] = [:];
            json["signature"] = [
                "file_data": data.base64EncodedString(),
                "file_name": "signature.png"
            ]
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
            
        case .createClient(let parameter), .updateClient(_, let parameter):
            let json: [String: Any] = [
                "uuid": parameter.uuid,
                "number": parameter.number.apiValue,
                "phone": parameter.phone.apiValue,
                "name": parameter.name.apiValue,
                "address": parameter.address.apiValue,
                "tax_id": parameter.taxId.apiValue,
                "email": parameter.email.apiValue,
                "website": parameter.website.apiValue,
                "is_active": parameter.isActive.apiValue
            ]
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
            
        case .createItem(let parameter), .updateItem(_, let parameter):
            let json: [String: Any] = [
                "uuid": parameter.uuid,
                "number": parameter.number.apiValue,
                "title": parameter.title,
                "description": parameter.description,
                "price": parameter.price,
                "tax": parameter.tax
            ]
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
            
        case .createOrder(_, let parameter), .updateOrder(_, _, let parameter):
            var json: [String: Any] = [
                "uuid": parameter.uuid,
                "number": parameter.number.apiValue,
                "title": parameter.title,
                "description": parameter.description,
                "price": parameter.price,
                "tax": parameter.tax,
                "discount": parameter.discount,
                "discount_absolute": parameter.isDiscountAbsolute,
                "total": parameter.total,
                "quantity": parameter.quantity,
                "job": parameter.job,
                "sort": parameter.sort,
            ]
            
            if let templateRemoteId = parameter.template.remoteId {
               json["template"] = templateRemoteId
            } else if let templateParameter = parameter.template.parameter {
                let templateJson: [String: Any] = [
                    "uuid": templateParameter.uuid,
                    "number": templateParameter.number.apiValue,
                    "title": templateParameter.title,
                    "description": templateParameter.description,
                    "price": templateParameter.price,
                    "tax": templateParameter.tax
                ]
                json["template"] = templateJson
            }
            
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
            
        case .createAttachment(_, let parameters):
            let data = MultipartFormData(provider: .data(parameters.data), name: "file", fileName: parameters.fileName, mimeType: parameters.mimeType)
            let uuid = MultipartFormData(provider: .data(parameters.uuid.data(using: .utf8)!), name: "uuid")
            let fileName = MultipartFormData(provider: .data(parameters.fileName.withJPGFileExtension.data(using: .utf8)!), name: "file_name")
            let mimeType = MultipartFormData(provider: .data(parameters.mimeType.data(using: .utf8)!), name: "mime_type")
            let identifier = MultipartFormData(provider: .data(String(parameters.job).data(using: .utf8)!), name: "job")
            let sort = MultipartFormData(provider: .data(String(parameters.sort).data(using: .utf8)!), name: "sort")
            return Task.uploadMultipart([data, uuid, mimeType, fileName, identifier, sort])
            
        case .updateAttachmentData(_, _, let parameters):
            let data = MultipartFormData(provider: .data(parameters.data), name: "file", fileName: parameters.fileName, mimeType: parameters.mimeType)
            let fileName = MultipartFormData(provider: .data(parameters.fileName.withJPGFileExtension.data(using: .utf8)!), name: "file_name")
            let mimeType = MultipartFormData(provider: .data(parameters.mimeType.data(using: .utf8)!), name: "mime_type")
            return Task.uploadMultipart([data, mimeType, fileName])
            
        case .updateAttachment(_, _, let filename, let sort):
            return Task.requestParameters(parameters: ["file_name": filename.withJPGFileExtension, "sort": sort], encoding: JSONEncoding.default)
            
        case .createPayment(let parameter), .updatePayment(_, let parameter):
            let json: [String: Any] = [
                "uuid": parameter.uuid,
                "amount": parameter.amount,
                "date": parameter.date,
                "type": parameter.type,
                "note": parameter.note.apiValue,
                "invoice": parameter.job
            ]
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
        
        case .listOffers(let cursor, let updatedAfter),
             .listInvoices(let cursor, let updatedAfter),
             .listClients(let cursor, let updatedAfter),
             .listItems(let cursor, let updatedAfter),
             .listOrders(_, let cursor, let updatedAfter),
             .listAttachments(_, let cursor, let updatedAfter),
             .listLocalization(let cursor, let updatedAfter):
            
            if cursor == nil && updatedAfter == nil {
                return Task.requestPlain;
            }
            
            var parameters: [String: Any] = [:]
            if let cursor = cursor {
                parameters["cursor"] = cursor
                
            }
            
            if let updatedAfter = updatedAfter {
                parameters["updated__gte"] = updatedAfter
            }
            return Task.requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
        case .account(let updatedAfter),
             .design(let updatedAfter),
             .defaults( _, let updatedAfter):
            if updatedAfter == nil {
                return Task.requestPlain;
            }
            
            var parameters: [String: Any] = [:]
            
            if let updatedAfter = updatedAfter {
                parameters["updated__gte"] = updatedAfter
            }
            return Task.requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
            
        case .listPayments(let cursor, let invoiceId, let updatedAfter),
             .listRecipients(_, let cursor, let invoiceId, let updatedAfter):
            
            if cursor == nil && invoiceId == nil && updatedAfter == nil {
                return Task.requestPlain
            }
            
            var parameters: [String: Any] = [:]
            if let cursor = cursor {
                parameters["cursor"] = cursor
            }
            
            if let invoiceId = invoiceId {
                parameters["invoice"] = invoiceId
            }
            
            if let updatedAfter = updatedAfter {
                parameters["updated__gte"] = updatedAfter
            }
            return Task.requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
        case .sendNewJob(let path, let parameters, let mail), .sendJob(let path, _, let parameters, let mail):
            var parts: [MultipartFormData] = convert(parameters: parameters.jobParameter)
            parts.append(contentsOf: buildMailFormdata(mail))
        
            if path == .invoice { // add the invoice specific fields
                parts.append(MultipartFormData(provider: .data(parameters.due.data(using: .utf8)!), name: "due"))
                if let paid = parameters.paid {
                    parts.append(MultipartFormData(provider: .data(paid.data(using: .utf8)!), name: "paid"))
                }
                
                let paypal = (parameters.paypal ?? false) ? "true" : "false"
                let stripe = (parameters.stripe ?? false) ? "true" : "false"
                
                parts.append(MultipartFormData(provider: .data(paypal.data(using: .utf8)!), name: "paypal"))
                parts.append(MultipartFormData(provider: .data(stripe.data(using: .utf8)!), name: "stripe"))
            }
            return Task.uploadMultipart(parts)
            
        case .updateDesign(let parameters):
            let json: [String: Any] = [
                "template": parameters.template,
                "color": parameters.color,
                "attachment_full_width": parameters.attachmentFullWidth,
                "attachment_hide_title": parameters.attachmentHideTitle,
                "pageSize": parameters.pageSize,
                "show_article_number": parameters.showArticleNumber,
                "show_article_title": parameters.showArticleTitle,
                "show_article_description": parameters.showArticleDescription
            ]
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
            
        case .updateDefaults(_, let parameters):
            let json: [String: Any] = [
                "note": parameters.note,
                "payment_details": parameters.paymentDetails,
                "message": parameters.message,
                "prefix": parameters.prefix,
                "due": parameters.due,
                "minimum_length": parameters.minimumLength,
                "start": parameters.start
            ]
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
            
        case .createLocalization(let parameters), .updateLocalization( _, let parameters):
        let json: [String: Any] = [
            "uuid": parameters.uuid,
            "payment_details_title": parameters.paymentDetailsTitle.apiValue,
            "header_article": parameters.headerArticle.apiValue,
            "invoice_number_title": parameters.invoiceNumberTitle.apiValue,
            "header_price": parameters.headerPrice.apiValue,
            "offer_number_title": parameters.offerNumberTitle.apiValue,
            "offer_title": parameters.offerTitle.apiValue,
            "vats_title": parameters.vatsTitle.apiValue,
            "invoice_title": parameters.invoiceTitle.apiValue,
            "language": parameters.language,
            "discount_title": parameters.discountTitle.apiValue,
            "date_title": parameters.dateTitle.apiValue,
            "header_total": parameters.headerTotal.apiValue,
            "balance_title": parameters.balanceTitle.apiValue,
            "subtotal_title": parameters.subtotalTitle.apiValue,
            "header_quantity": parameters.headerQuantity.apiValue,
            "due_date_title": parameters.dueDateTitle.apiValue,
            "paid_title": parameters.paidTitle.apiValue,
            "header_description": parameters.headerDescription.apiValue,
            "header_article_number": parameters.headerArticleNumber.apiValue
            ]
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
            
        case .send(_, _, let parameters):
            let json: [String: Any] = [
                "to": parameters.to,
                "text": parameters.text,
                "name": parameters.name,
                "uuid": parameters.uuid
            ]
            return Task.requestParameters(parameters: json, encoding: JSONEncoding.default)
        default:
            return Task.requestPlain
        }
    }
    
    var needsAuthentication: Bool {
        switch self {
        case .login, .loginNormal, .register, .registerActive, .validate:
            return false
        default:
            return true
        }
    }
    
    var headers: [String: String]? {
        
        var headerFields = [
            "Cookie": "",
            "Content-Type": "application/json",
            "t": UUID().uuidString
        ]
        
        switch self {
        case .login, .loginNormal, .register, .registerActive, .validate:
            return headerFields
        default:
            guard let token = UserDefaults.appGroup.token() else {
                // fatalError("token expected but none was found")
                return headerFields
            }
            headerFields["Authorization"] = "Token " + token
            
            if let deviceIdentifier = UserDefaults.appGroup.deviceIdentifier(), deviceIdentifier != 0 {
                headerFields["X-InvoiceBot-Id"] = "\(deviceIdentifier)"
            }
            
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                headerFields["X-Client-Version"] = appVersion
            }
            
            return headerFields
        }
    }
}
//swiftlint:enable file_length
