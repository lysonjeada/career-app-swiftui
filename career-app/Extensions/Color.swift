//
//  Color.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 22/10/24.
//

import SwiftUI

extension Color {
    static var persianBlue: Color {
        .init(red: 6, green: 71, blue: 137, opacity: 1)
    }
    
    static var secondaryBlue: Color {
        .init(red: 66, green: 122, blue: 161, opacity: 1)
    }
    
    static var backgroundGray: Color {
        .init(red: 141, green: 153, blue: 174, opacity: 1)
    }
    static var backgroundLightGray: Color {
        .init(red: 236, green: 236, blue: 236, opacity: 1)
    }
    
    init(red: Int, green: Int, blue: Int) {
        self.init(
            .sRGB,
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0,
            opacity: 1.0
        )
    }
    
    init(red: Int, green: Int, blue: Int, opacity: Double) {
        self.init(
            .sRGB,
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0,
            opacity: opacity
        )
    }
}
