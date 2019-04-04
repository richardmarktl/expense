//
//  MailchimpAuthPlugin.swift
//  InVoice
//
//  Created by Georg Kitz on 22/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import Moya
import Result

struct MailchimpAuthPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.addValue("apikey 8774aef7371937fe8d7030a16c5d4039-us17", forHTTPHeaderField: "Authorization")
        return request
    }
}
