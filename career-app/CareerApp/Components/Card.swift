//
//  Card.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/12/24.
//

import SwiftUI

public enum CardStyle: String, CaseIterable, Codable {
    case stantard
    
    var strokeWidth: CGFloat {
        switch self {
        case .stantard:
                .zero
        }
    }
}

public struct Card<T: View>: View {
    let someView: T
    var alignment: Alignment
    var style: CardStyle = .stantard
    
    public init(alignment: Alignment = .init(horizontal: .leading, vertical: .top),
                @ViewBuilder someView: @escaping () -> T) {
        self.someView = someView()
        self.alignment = alignment
    }
    
    public var body: some View {
        ZStack(alignment: alignment) {
            someView
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(Color(.init(gray: 0.8, alpha: 1)), lineWidth: style.strokeWidth))
        .background(RoundedRectangle(cornerRadius: .zero)
            .foregroundColor(Color.clear)
            .shadow(radius: 4, x: 0, y: 3))
    }
}
