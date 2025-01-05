//
//  Color.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 22/10/24.
//

import SwiftUI

extension Color {
    static var skeletonColor: Color {
        .init(red: 235, green: 234, blue: 231, opacity: 1)
    }
    
    static var indicatorColor: Color {
        .init(red: 6, green: 20, blue: 137, opacity: 0.1)
    }
    static var numberBlue: Color {
        .init(red: 6, green: 20, blue: 137, opacity: 1)
    }
    
    static var descriptionGray: Color {
        .init(red: 118, green: 113, blue: 137, opacity: 1)
    }
    
    static var persianBlueWithoutOpacity: Color {
        .init(red: 6, green: 50, blue: 137, opacity: 1)
    }
    
    static var persianBlue: Color {
        .init(red: 6, green: 71, blue: 137, opacity: 1)
    }
    
    static var secondaryBlue: Color {
        .init(red: 6, green: 68, blue: 127, opacity: 1)
    }
    
    static var thirdBlue: Color {
        .init(red: 6, green: 71, blue: 136, opacity: 1)
    }
    
    static var titleSectionColor: Color {
        .init(red: 6, green: 67, blue: 135, opacity: 1)
//        .init(red: 6, green: 71, blue: 137, opacity: 1)
//        .init(red: 6, green: 68, blue: 127, opacity: 1)
    }
    
    static var backgroundGray: Color {
        .init(red: 141, green: 153, blue: 174, opacity: 1)
    }
    static var backgroundLightGray: Color {
        .init(red: 245, green: 245, blue: 245, opacity: 1)
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
