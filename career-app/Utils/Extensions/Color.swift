//
//  Color.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 22/10/24.
//

import SwiftUI

import SwiftUI

extension Color {
    // Helper function to adjust color for dark mode
    private static func adaptiveColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
    
    // Helper to create adaptive color from RGB values
    private static func adaptive(red: Int, green: Int, blue: Int, opacity: Double = 1.0) -> Color {
        let lightColor = Color(red: red, green: green, blue: blue, opacity: opacity)
        
        // Adjust color for dark mode by increasing brightness (simple approach)
        let darkRed = min(255, red + 40)
        let darkGreen = min(255, green + 40)
        let darkBlue = min(255, blue + 40)
        let darkColor = Color(red: darkRed, green: darkGreen, blue: darkBlue, opacity: opacity)
        
        return adaptiveColor(light: lightColor, dark: darkColor)
    }
    
    // Helper to create adaptive color from Double RGB values
    private static func adaptive(red: Double, green: Double, blue: Double) -> Color {
        let lightColor = Color(red: red, green: green, blue: blue)
        
        // Adjust color for dark mode by increasing brightness
        let darkRed = min(1.0, red + 0.15)
        let darkGreen = min(1.0, green + 0.15)
        let darkBlue = min(1.0, blue + 0.15)
        let darkColor = Color(red: darkRed, green: darkGreen, blue: darkBlue)
        
        return adaptiveColor(light: lightColor, dark: darkColor)
    }
    
    static var persianLightBlue: Color {
        adaptive(red: 100, green: 160, blue: 220)
    }
    
    static var skeletonColor: Color {
        adaptive(red: 141, green: 153, blue: 174)
//        adaptive(red: 235, green: 234, blue: 231)
    }
    
    static var indicatorColor: Color {
        adaptive(red: 6, green: 20, blue: 137, opacity: 0.1)
    }
    
    static var redColor: Color {
        adaptive(red: 189, green: 71, blue: 78)
    }
    
    static var numberBlue: Color {
        adaptive(red: 6, green: 20, blue: 137)
    }
    
    static var descriptionGray: Color {
        adaptive(red: 118, green: 113, blue: 137)
    }
    
    static var persianBlueWithoutOpacity: Color {
        adaptive(red: 6, green: 50, blue: 137)
    }
    
    static var persianBlue: Color {
        adaptive(red: 6, green: 71, blue: 137)
    }
    
    static var persianPaleBlue: Color {
        adaptive(red: 140/255, green: 180/255, blue: 220/255)
    }
    
    static var lighterBlue: Color {
        adaptive(red: 180/255, green: 210/255, blue: 230/255)
    }
    
    static var secondaryBlue: Color {
        adaptive(red: 6, green: 68, blue: 127)
    }
    
    static var thirdBlue: Color {
        adaptive(red: 6, green: 71, blue: 136)
    }
    
    static var fourthBlue: Color {
        adaptive(red: 6, green: 94, blue: 137)
    }
    
    static var fivethBlue: Color {
        adaptive(red: 6, green: 53, blue: 77)
    }
    
    static var titleSectionColor: Color {
        adaptive(red: 6, green: 67, blue: 135)
    }
    
    static var backgroundGray: Color {
        adaptive(red: 141, green: 153, blue: 174)
    }
    
    static var backgroundLightGray: Color {
        adaptive(red: 245, green: 245, blue: 245)
    }
    
    static var greenButton: Color {
        adaptive(red: 0, green: 94, blue: 66)
    }
    
    static var adaptiveBlack: Color {
        return adaptiveColor(light: .black, dark: Color(white: 0.3)) // Dark mode version is 30% gray
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
