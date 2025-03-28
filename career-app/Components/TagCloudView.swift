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
    var shadowRadius: CGFloat = 2
    var color: Color = .blue
    
    var body: some View {
        // Usamos um WrapStack para tags que quebram linha automaticamente
        WrapStack(alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: fontSize))
                    .padding(.horizontal, padding)
                    .padding(.vertical, padding/2)
                    .background(color.opacity(0.2))
                    .foregroundColor(color)
                    .cornerRadius(cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(color, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: shadowRadius)
            }
        }
    }
}

// Componente auxiliar para quebrar linhas automaticamente
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
