//
//  Parser.swift
//  Pods
//
//  Created by gabmarfer on 13/06/16.
//
//

import Foundation

struct Parser {
    enum DateFormat: String {
        case bloombees = "YYYY-MM-dd HH:mm:ss"
        case atom = "YYYY-MM-dd'T'HH:mm:ssZZZ"
    }
    
    func parseDateFromString(_ string: String,
                          withDateFormat dateFormat: DateFormat = DateFormat.bloombees) -> NSDate? {
        
        var formatter = NSDateFormatter()
        switch dateFormat {
        case .bloombees:
            formatter.dateFormat = DateFormat.bloombees.rawValue
        case .atom:
            formatter.dateFormat = DateFormat.atom.rawValue
        }
        
        return formatter.dateFromString(string)
    }
}