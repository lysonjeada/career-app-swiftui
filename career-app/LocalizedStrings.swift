//
//  LocalizedStrings.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 16/10/24.
//

import Foundation

struct LocalizedStrings {
    
    
    private static func localized(_ key: String, tableName: String) -> String {
        return NSLocalizedString(key, tableName: tableName, bundle: .main, value: "", comment: "")
    }
}
