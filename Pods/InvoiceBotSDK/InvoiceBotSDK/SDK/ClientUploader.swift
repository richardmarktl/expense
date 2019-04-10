//
//  ClientUploader.swift
//  InVoice
//
//  Created by Georg Kitz on 22/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

public struct ClientUploader {
    public static func upload(for job: Job) -> Observable<Job> {
        if let client = job.client {
            return ClientRequest.upload(client).take(1).map({ (client) -> Job in
                job.client = client
                return job
            })
        } else {
            return Observable.just(job)
        }
    }
}
