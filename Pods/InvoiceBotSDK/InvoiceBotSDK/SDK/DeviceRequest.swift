//
//  DeviceRequest.swift
//  InVoice
//
//  Created by Georg Kitz on 02/02/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import CoreTelephony
import UIKit
import RxSwift

public struct DeviceRequest {
    
    public static func upload(token: String, appVersion: String, context: NSManagedObjectContext) -> Observable<Void> {
        
        let item = Device.current(in: context)
        guard let uuid = item.uuid else {
            return Observable.error(ApiError.parameter)
        }
        
        let device = UIDevice.current.model
        let osVersion = UIDevice.current.systemVersion
        let locale = Locale.current.identifier
        let carrier: String
        if #available(iOS 12, *) {
            carrier = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value.carrierName ?? "no-carrier-name"
        } else {
            carrier = CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName ?? "no-carrier-name"
        }
        
        
        let parameters = (uuid: uuid, token: token, device: device, appVersion: appVersion, osVersion: osVersion, locale: locale, carrier: carrier)
        let obs = item.hasRemoteId ? ApiProvider.request(Api.updateDevice(id: item.remoteId, parameters: parameters)) : ApiProvider.request(Api.createDevice(parameters: parameters))
        
        return obs.mapJSON().map(updateObjectWithJSON(item)).do(onNext: { _ in
            try? item.managedObjectContext?.save()
            UserDefaults.appGroup.store(deviceIdentifier: item.remoteId)
        }).mapToVoid()
    }
}
