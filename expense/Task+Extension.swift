//
//  Task+Extension.swift
//  InVoice
//
//  Created by Richard Marktl on 04.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import Moya

extension Task {
    static let NotLoggedKeys: [String] = ["signature", "file"]

    /// This method will take the task and clean its parameters for the logging, based on the NotLoggedKeys values.
    ///
    /// - Parameter task: The task object
    /// - Returns: a clean string representation of the task object.
    func clean() -> String {
        switch self {
        case .requestParameters(let parameters, _):
            var cleanedParameters = parameters
            for key in Task.NotLoggedKeys {
                if let value = cleanedParameters[key] {
                    if let value = value as? CustomStringConvertible {
                        cleanedParameters[key] = "<Hidden Data(length: \(value.description.count))>"
                    } else {
                        cleanedParameters[key] = "<Cleaned Data>"
                    }
                }
            }
            return cleanedParameters.description
        default:
            return "<Data not cleaned>"
        }
    }
}

extension Moya.Method {
    var isWrite: Bool {
        switch self {
        case .patch, .post, .put:
            return true
        default:
            return false
        }
    }
}
