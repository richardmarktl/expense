//
//  ApiProvider.swift
//  InVoice
//
//  Created by Georg Kitz on 16/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift
import Moya

// MARK: - APIType
public enum ApiType {
    case `default`
    case stubSuccess
    case stubSuccessDelayed
}

public enum ApiError: Error {
    case invalidJSON
    case parameter
    case singleErrorMessage(message: String)
    case noneField(message: String)
    case fields(message: String)
}

extension ApiError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return NSLocalizedString("invalidJSON", comment: "")
        case .parameter:
            return NSLocalizedString("parameter", comment: "")
        case .noneField(let message), .fields(let message), .singleErrorMessage(let message):
            return message
        }
    }
}

extension Data {
    func asString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

public typealias JSONDictionary = [String: Any]

public protocol ErrorLogger {
    func recordError(_ error: String, withAdditionalUserInfo: [String: Any]?)
}

public struct DefaultErrorLogger: ErrorLogger {
    public init() {}
    public func recordError(_ error: String, withAdditionalUserInfo userInfo: [String: Any]? = nil) {
        logger.error("ApiError: \(error) UserInfo: \(userInfo ?? [:])")
    }
}

// MARK: - API
public struct ApiProvider {
    
    fileprivate static var online: Observable<Bool> = reachabilityColsure()
    
    public static func setupDefaultProvider(_ type: ApiType, online: Observable<Bool> = reachabilityColsure(), errorLogger: ErrorLogger = DefaultErrorLogger()) {
        self.errorLogger = errorLogger
        
        switch type {
        case .default:
            provider = defaultProvider()
        case .stubSuccess:
            provider = stubbedSuccessProvider()
        case .stubSuccessDelayed:
            provider = stubbedDelayedSuccessProvider()
        }
        
        self.online = online
    }
    
    //swiftlint:disable function_body_length
    static func request(_ target: Api) -> Observable<Moya.Response> {
        return online
            .do(onNext: { isOnline in
                if !isOnline {
                    #if !IS_EXTENSION
                    errorLogger.recordError("Device Offline", withAdditionalUserInfo: nil)
                    #endif
                }
            })
            .filter { $0 == true }
            .take(1)
            .flatMap({ (_) -> Observable<Void> in
                if target.needsAuthentication && UserDefaults.appGroup.token() == nil {
                    logger.verbose("No user token found to load data")
                    return Observable.empty()
                }
                logger.verbose("User token found, loading request now")
                return Observable.just(())
            })
            .flatMap { _ -> Single<Response> in
        
                return provider.rx.request(target).do(onError: { (error) in
                    //we assume that an error could happen here, like a timeout or something
                    logger.error("Request failed for: \(target.path) with error \(error)")
                    
                    #if !IS_EXTENSION
                    let httpBody: String
                    if case .requestParameters(let params, _) = target.task {
                        let json = try? JSONSerialization.data(withJSONObject: params, options: [])
                        httpBody = json?.asString() ?? "no json body"
                    } else {
                        httpBody = "no body"
                    }
                    
                    let userInfo: [String: String] = [
                        "type": "error-with-request-itself",
                        "message": error.localizedDescription,
                        "url": target.path,
                        "body": httpBody
                    ]
                    errorLogger.recordError("Device Offline", withAdditionalUserInfo: userInfo)
                    #endif
                })
            
            }.map({ (response: Moya.Response) -> Moya.Response in
            
                if [200, 201, 204].contains(response.statusCode) {
                    
                    if target.needsAuthentication && (target.method == Moya.Method.put || target.method == Moya.Method.patch) {
                        UserDefaults.store(lastUpload: Date())
                    }
                    
                    return response
                }
                
                do {
                    guard let mappedJSON = try? response.mapJSON(failsOnEmptyData: false) else {
                        throw ApiError.invalidJSON
                    }
                    
                    if let jsonKeyValueDictionary = mappedJSON as? [String: String], let value = jsonKeyValueDictionary["detail"] {
                        throw ApiError.singleErrorMessage(message: value)
                    }
                    
                    guard let jsonData = mappedJSON as? [String: [String]] else {
                        throw ApiError.invalidJSON
                    }

                    if let noneFieldErrorMessages = jsonData["non_field_errors"] {
                        throw ApiError.noneField(message: noneFieldErrorMessages.reduceToOneString())
                    }
                    
                    let message = jsonData.reduce("", { (current, keyValuePair) -> String in
                        return current + keyValuePair.value.reduceToOneString() + "\n"
                    }).trimmingCharacters(in: CharacterSet.newlines)
                    
                    throw ApiError.fields(message: message)
                } catch let error {
                    #if !IS_EXTENSION
                    let userInfo: [String: Any] = [
                        "type": "error-with-data-response",
                        "message": error.localizedDescription,
                        "url": response.request?.url?.absoluteURL.absoluteString ?? "no-url",
                        "body": String(data: response.request?.httpBody ?? Data(), encoding: .utf8) ?? "no-body"
                    ]
                    errorLogger.recordError("Device Offline", withAdditionalUserInfo: userInfo)
                    #endif
                    throw error
                }
            })
    }
    //swiftlint:enable function_body_length
}

extension Sequence where Iterator.Element == String {
    func reduceToOneString() -> String {
        return reduce("", { (current, value) -> String in
            return current + value + "\n"
        }).trimmingCharacters(in: CharacterSet.newlines)
    }
}

public extension ApiProvider {
    
    fileprivate static var provider: MoyaProvider<Api> = ApiProvider.defaultProvider()
    fileprivate static var errorLogger: ErrorLogger = DefaultErrorLogger()
    
    fileprivate static func defaultProvider() -> MoyaProvider<Api> {
        #if IS_EXTENSION
            return MoyaProvider(manager: ApiProvider.backgroundManager(), plugins: [ApiLogger()])
        #else
            return MoyaProvider(manager: ApiProvider.backgroundManager(), plugins: [ApiLogger(), ApiProgressIndicator()])
        #endif
    }
    
    fileprivate static func stubbedSuccessProvider() -> MoyaProvider<Api> {
        return MoyaProvider(stubClosure: MoyaProvider.immediatelyStub, plugins: [ApiLogger()])
    }
    
    fileprivate static func stubbedDelayedSuccessProvider() -> MoyaProvider<Api> {
        return MoyaProvider(stubClosure: MoyaProvider.delayedStub(5), plugins: [ApiLogger()])
    }
    
    fileprivate static func backgroundManager() -> Manager {
        
        let configuration = URLSessionConfiguration.background(withIdentifier: Bundle.main.bundleIdentifier! + "session")
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        
        let appGroup = Bundle.main.infoDictionary!["APP_GROUP"] as! String
        configuration.sharedContainerIdentifier = appGroup
        
        let manager = Manager(configuration: configuration)
        manager.startRequestsImmediately = false
        return manager
    }
}
