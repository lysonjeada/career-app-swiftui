//
//  TagCloudView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 28/03/25.
//

import SwiftUI

struct TagCloudView: View {
    let tags: [String]
    var fontSize: CGFloat = 14
    var padding: CGFloat = 8
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 1
    
    // Cores derivadas do Persian Blue
    private var tagBackground: Color {
        Color.white
    }
    
    private var tagForeground: Color {
        Color.persianBlue
    }
    
    private var borderColor: Color {
        Color.persianBlue
    }
    
    var body: some View {
        WrapStack(alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: fontSize, weight: .medium))
                    .padding(.horizontal, padding)
                    .padding(.vertical, padding/2)
                    .background(tagBackground)
                    .foregroundColor(tagForeground)
                    .cornerRadius(cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: shadowRadius, x: 0, y: shadowRadius)
            }
        }
    }
}

// Extensão com variações do Persian Blue
extension Color {
    static let persianLightBlue = Color(red: 100/255, green: 160/255, blue: 220/255)
    static let persianLighterBlue = Color(red: 150/255, green: 190/255, blue: 235/255)
}

// Componente auxiliar WrapStack (mantido igual)
struct WrapStack: Layout {
    var alignment: Alignment = .center
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? 0
        var totalHeight: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            
            if lineWidth + size.width + spacing > containerWidth {
                totalHeight += lineHeight + spacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }
        
        totalHeight += lineHeight
        return CGSize(width: containerWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let containerWidth = bounds.width
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            
            if lineX + size.width > containerWidth {
                lineY += lineHeight + spacing
                lineHeight = 0
                lineX = bounds.minX
            }
            
            view.place(
                at: CGPoint(x: lineX, y: lineY),
                anchor: .topLeading,
                proposal: ProposedViewSize(size)
            )
            
            lineX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
