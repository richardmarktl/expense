//
//  DesignRequest.swift
//  InVoice
//
//  Created by Georg Kitz on 19.10.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

public struct JobDesignRequest {
    public static func upload(_ design: JobDesign) -> Observable<JobDesign> {
        guard let color = design.color, let template = design.template else {
            return Observable.error(ApiError.parameter)
        }
        let parameters: DesignParameters = (
            template: template,
            color: color,
            attachmentHideTitle: design.attachmentHideTitle,
            attachmentFullWidth: design.attachmentFullWidth,
            pageSize: design.pageSize ?? JobPageSize.A4.rawValue,
            showArticleNumber: design.showArticleNumber,
            showArticleTitle: design.showArticleTitle,
            showArticleDescription: design.showArticleDescription
        )
        return ApiProvider.request(Api.updateDesign(parameters: parameters)).mapJSON().map(updateObjectWithJSON(design))
    }
    
    public static func load(_ design: JobDesign, updatedAfter: String?) -> Observable<JobDesign> {
        return ApiProvider.request(Api.design(updatedAfter: updatedAfter)).mapJSON().map(updateObjectWithJSON(design))
    }
}
