//
//  LoginRequest.swift
//  InVoice
//
//  Created by Georg Kitz on 17/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import CoreDataExtensio

struct AccountRequest {
    
    static func login(with email: String) -> Observable<Void> {
        return ApiProvider.request(Api.login(email: email)).mapToVoid()
    }
    
    static func loginNormal(with email: String, name: String, password: String) -> Observable<String> {
        return ApiProvider.request(Api.loginNormal(name: name, email: email, password: password)).mapJSON().map({ (data) -> String in
            return AccountRequest.token(from: data)
        })
    }
    
    static func register(with email: String, name: String) -> Observable<Void> {
        let parameters = accountParamters(from: email, name: name)
        return ApiProvider.request(Api.register(parameters: parameters)).mapToVoid()
    }
    
    static func registerActive(with email: String, name: String, password: String) -> Observable<Void> {
        let parameters = accountParamters(from: email, name: name, password: password)
        return ApiProvider.request(Api.registerActive(parameters: parameters)).mapToVoid()
    }
    
    static func validate(uid: String, token: String) -> Observable<String> {
        let parameters: ValidationParameter = (uid: uid, token: token)
        return ApiProvider.request(Api.validate(parameters: parameters)).mapJSON().map({ (data) -> String in
            return AccountRequest.token(from: data)
        })
    }
    
    static func uploadProState() -> Observable<Void> {
        let validReceipt = StoreService.instance.hasValidReceipt
        return ApiProvider.request(Api.updatePro(isPro: validReceipt)).mapToVoid()
    }
    
    static func load(_ account: Account, updatedAfter: String?, useDefaultMapper: Bool = false) -> Observable<Account> {
        
        let mapper = useDefaultMapper ? updateObjectWithJSON(account) : {
            (data) -> Account in
            
            guard let JSON = data as? JSONDictionary,
                let remoteId = JSON["id"] as? Int64 else {
                    throw ApiError.invalidJSON
            }
            
            account.remoteId = remoteId
            
            func update(account: Account, key: ReferenceWritableKeyPath<Account, String?>, json JSON: JSONDictionary, jsonKey: String) {
                if let jsonValue = JSON[jsonKey] as? String, jsonValue.count != 0 {
                    
                    if let value = account[keyPath: key], value.count != 0 {
                        return
                    }
                    account[keyPath: key] = jsonValue
                }
            }
            
            update(account: account, key: \Account.name, json: JSON, jsonKey: "name")
            update(account: account, key: \Account.email, json: JSON, jsonKey: "email")
            update(account: account, key: \Account.phone, json: JSON, jsonKey: "phone")
            update(account: account, key: \Account.website, json: JSON, jsonKey: "website")
            update(account: account, key: \Account.address, json: JSON, jsonKey: "address")
            update(account: account, key: \Account.paymentDetails, json: JSON, jsonKey: "payment_details")
            update(account: account, key: \Account.note, json: JSON, jsonKey: "note")
            update(account: account, key: \Account.logoFile, json: JSON, jsonKey: "logo")
            update(account: account, key: \Account.paypalId, json: JSON, jsonKey: "paypal_id")
            update(account: account, key: \Account.country, json: JSON, jsonKey: "country")
            
            if let jsonValue = JSON["stripe"] as? Bool {
                account.isStripeActivated = jsonValue
            }
            
            if let jsonTax = JSON["tax"] as? Float, jsonTax != 0 {
                if let tax = account.tax, tax != NSDecimalNumber.zero {
                    account.tax = NSDecimalNumber.zero
                } else {
                    account.tax = NSDecimalNumber(value: jsonTax)
                }
            }
            
            if let jsonTimestamp = JSON["created"] as? String, let timestamp = StringToISO8601DateTransfomer().typedTransformedValue(jsonTimestamp) {
                account.createdTimestamp = timestamp
            }
            
            if let jsonTimestamp = JSON["trail_started"] as? String, let timestamp = StringToISO8601DateTransfomer().typedTransformedValue(jsonTimestamp) {
                account.trailStartedTimestamp = timestamp
            }
            
            if let jsonTimestamp = JSON["trail_ended"] as? String, let timestamp = StringToISO8601DateTransfomer().typedTransformedValue(jsonTimestamp) {
                account.trailEndedTimestamp = timestamp
            }
            
            return account
        }
        
        return ApiProvider.request(Api.account(updatedAfter: nil)).mapJSON().map(mapper)
    }
    
    static func upload(_ item: Account) -> Observable<Account> {
        guard let uuid = item.uuid else {
            return Observable.error(ApiError.parameter)
        }
        
        let locale = Locale.current.identifier
        let language = Locale.preferredLanguages.first ?? "en"
        let currency = Locale.current.currencyCode ?? "USD"
        
        let parameter: AccountParameter = (
            uuid: uuid,
            name: item.name,
            phone: item.phone,
            taxId: item.taxId,
            email: item.email,
            website: item.website,
            address: item.address,
            tax: item.tax?.doubleValue,
            paymentDetails: item.paymentDetails,
            note: item.note,
            language: language,
            locale: locale,
            currency: currency,
            paypalId: item.paypalId,
            stripe: item.isStripeActivated
        )
        
        return ApiProvider.request(Api.updateAccount(parameters: parameter)).mapJSON().map(updateObjectWithJSON(item))
    }
    
    static func uploadTrail(for account: Account, started: Date, ended: Date) -> Observable<Account> {
        return ApiProvider.request(Api.updateAccountTrail(trailStart: started, trailEnded: ended)).map(updateObjectWithJSON(account))
    }
    
    static func uploadLogo(for account: Account) -> Observable<Account> {
        
        guard let filename = account.logoFileName else {
            return Observable.error(ApiError.parameter)
        }
        
        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        return ImageStorage.loadImage(for: filename).observeOn(background).map({ (storageItem) -> Data? in
            return UIImageJPEGRepresentation(storageItem.image, 1.0)
        })
        .filterNil()
        .flatMap({ (data) -> Observable<Moya.Response> in
            return ApiProvider.request(Api.updateLogoForAccount(data: data, filename: filename))
        })
        .mapJSON().map(updateObjectWithJSON(account))
    }
    
    static func deleteLogo(for account: Account) -> Observable<Account> {
        return ApiProvider.request(Api.updateLogoForAccount(data: nil, filename: nil)).mapJSON().map(updateObjectWithJSON(account))
    }
    
    private static func accountParamters(from email: String, name: String, password: String? = nil) -> RegisterCompanyParameter{
        let locale = Locale.current.identifier
        let language = Locale.preferredLanguages.first ?? "en"
        let currency = Locale.current.currencyCode ?? "USD"
        
        return (email: email, name: name, language: language, locale: locale, currency: currency, password: password)
    }
    
    private static func token(from data: Any) -> String {
        guard let JSON = data as? JSONDictionary else {
            return ""
        }
        
        if let token = JSON["token"] as? String {
            return token
        }
        
        if let key = JSON["key"] as? String {
            return key
        }
        
        return "no"
    }
}
