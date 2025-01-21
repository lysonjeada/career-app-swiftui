//
//  HomeStrings.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 15/10/24.
//

import Foundation

class HomeStrings {
    static let homeTitle = localized("homeTitle")
    static let interviewTitle = localized("interviewTitle")
    static let menuTitle = localized("menuTitle")
    static let resumeTitle = localized("resumeTitle")
    
    private static func localized(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "HomeStrings", bundle: .main, value: "", comment: "")
    }
}
