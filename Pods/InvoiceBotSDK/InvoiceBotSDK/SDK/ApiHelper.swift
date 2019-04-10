//
//  ApiHelper.swift
//  InVoice
//
//  Created by Richard Marktl on 16.02.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import Moya


func convert(parameters job: JobParameter) -> [MultipartFormData] {
    var parts: [MultipartFormData] = []
    
    if let phone = job.client?.phone.databaseValue {
        parts.append(MultipartFormData(provider: .data(phone.data(using: .utf8)!), name: "client_phone"))
    }
    if let name = job.client?.name.databaseValue {
        parts.append(MultipartFormData(provider: .data(name.data(using: .utf8)!), name: "client_name"))
    }
    if let address = job.client?.address.databaseValue {
        parts.append(MultipartFormData(provider: .data(address.data(using: .utf8)!), name: "client_address"))
    }
    if let taxId = job.client?.taxId.databaseValue {
        parts.append(MultipartFormData(provider: .data(taxId.data(using: .utf8)!), name: "client_tax_id"))
    }
    if let email = job.client?.email.databaseValue {
        parts.append(MultipartFormData(provider: .data(email.data(using: .utf8)!), name: "client_email"))
    }
    if let website = job.client?.website.databaseValue {
        parts.append(MultipartFormData(provider: .data(website.data(using: .utf8)!), name: "client_website"))
    }
    if let website = job.client?.number.databaseValue {
        parts.append(MultipartFormData(provider: .data(website.data(using: .utf8)!), name: "client_number"))
    }
    if let client = job.clientRemoteId, client > 0 {
        parts.append(MultipartFormData(provider: .data("\(client)".data(using: .utf8)!), name: "client"))
    }
    if let value = job.note.databaseValue {
        parts.append(MultipartFormData(provider: .data(value.data(using: .utf8)!), name: "note"))
    }
    if let value = job.paymentDetails.databaseValue {
        parts.append(MultipartFormData(provider: .data(value.data(using: .utf8)!), name: "payment_details"))
    }
    if let value = job.language.databaseValue {
        parts.append(MultipartFormData(provider: .data(value.data(using: .utf8)!), name: "language"))
    }
    if let value = job.currency.databaseValue {
        parts.append(MultipartFormData(provider: .data(value.data(using: .utf8)!), name: "currency"))
    }
    
    if let value = job.signedOn.databaseValue {
        parts.append(MultipartFormData(provider: .data(value.data(using: .utf8)!), name: "signed_on"))
    } else { // to clear an field use an empty string for null
        parts.append(MultipartFormData(provider: .data("".data(using: .utf8)!), name: "signed_on"))
    }
    
    if let value = job.signatureName.databaseValue {
        parts.append(MultipartFormData(provider: .data(value.data(using: .utf8)!), name: "signature_name"))
    } else { // to clear an field use an empty string for null
        parts.append(MultipartFormData(provider: .data("".data(using: .utf8)!), name: "signature_name"))
    }

    parts.append(MultipartFormData(provider: .data(job.uuid.data(using: .utf8)!), name: "uuid"))
    parts.append(MultipartFormData(provider: .data(job.discount.data(using: .utf8)!), name: "discount"))
    parts.append(MultipartFormData(provider: .data(job.date.data(using: .utf8)!), name: "date"))
    parts.append(MultipartFormData(provider: .data(job.total.data(using: .utf8)!), name: "total"))
    parts.append(MultipartFormData(provider: .data("\(job.isDiscountAbsolute)".data(using: .utf8)!), name: "discount_absolute"))
    parts.append(MultipartFormData(provider: .data(job.number.data(using: .utf8)!), name: "number"))
    parts.append(MultipartFormData(provider: .data(job.needsSignature.description.data(using: .utf8)!), name: "needs_signature"))
    
    if job.signatureUpdate == .update {
        if let data = job.signature {
            parts.append(MultipartFormData(provider: .data(data), name: "signature", fileName: "signature.png", mimeType: "image/png"))
        } else {
            parts.append(MultipartFormData(provider: .data("".data(using: .utf8)!), name: "signature"))
        }
    }
    
    return parts
}

func buildMailFormdata(_ mail: MailParameter) -> [MultipartFormData] {
    var parts: [MultipartFormData] = []
    parts.append(MultipartFormData(provider: .data(mail.data), name: "file", fileName: "file.pdf", mimeType: "application/pdf"))
    parts.append(MultipartFormData(provider: .data(mail.text.data(using: .utf8)!), name: "text"))
    parts.append(contentsOf: convertListOf(dictionaries: mail.recipients, field: "recipients"))
    return parts
}

/// This function will take a list of dictionaries and convert it to list of multipart form data elements.
/// The function needs the name of the field in the request. The dictionaries will then be pulled apart
/// into a list. By using following format: <field>[<index>]<dictionary key> = dictionary value
/// Example:
///     sender[0]email = richard.marktl@gmail.com
///     sender[0]name = Richard Marktl
///     sender[1]email = georg.kitz@gmail.com
///
/// - Parameters:
///   - dictionaries: a list of dictionaries
///   - field: the name of the field
/// - Returns: a array for multipart form data elements.
func convertListOf(dictionaries: [[String: String]], field: String) -> [MultipartFormData] {
    var parts: [MultipartFormData] = []
    for (index, dictionary) in dictionaries.enumerated() {
        let indexString = "[" + String(index) + "]"
        for (key, value) in dictionary {
            let mulitpartField = field + indexString + key
            parts.append(MultipartFormData(provider: .data(value.data(using: .utf8)!), name: mulitpartField))
        }
    }
    return parts
}
