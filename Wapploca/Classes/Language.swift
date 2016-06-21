//
//  Language.swift
//  Pods
//
//  Created by gabmarfer on 15/06/16.
//
//

import Foundation

public struct Language: CustomStringConvertible {
    struct Params {
        static let languageIdKey = "id_language"
        static let nameKey = "name"
        static let isoCodeKey = "iso_code"
    }
    
    var languageId: Int!
    var isoCode: String?
    var name: String?
    
    public var description: String {
        return "isoCode: \(isoCode) language: \(name)"
    }
    
    init(attributes: [String: String]) {
        self.isoCode = attributes[Params.isoCodeKey]
        self.name = attributes[Params.nameKey]
        self.languageId = Int(attributes[Params.languageIdKey]!)
    }
}