//
//  MyEqualHeightHStack.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 20/01/25.
//

import SwiftUI

struct MyEqualHeightHStack: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    )  -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let radius = min(bounds.size.width, bounds.size.height) / 3.0
        let angle = Angle.degrees(360.0 / Double(subviews.count)).radians

        let ranks = subviews.map { subview in
            subview[Rank.self]
        }
        let offset = getOffset(ranks)

        for (index, subview) in subviews.enumerated() {
            var point = CGPoint(x: 0, y: -radius)
                .applying(CGAffineTransform(
                    rotationAngle: angle * Double(index) + offset))
            point.x += bounds.midX
            point.y += bounds.midY
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
    }
    
    private func getOffset(_ ranks: [Int]) -> CGFloat {
        // Caso não existam ranks válidos, retorna 0
        guard !ranks.isEmpty else { return 0 }

        // Calcula a média dos ranks
        let averageRank = Double(ranks.reduce(0, +)) / Double(ranks.count)

        // Converte a média dos ranks em um ângulo (em radianos)
        return CGFloat(Angle.degrees(averageRank * (360.0 / Double(ranks.count))).radians)
    }


    private func maxSize(subviews: Subviews) -> CGSize {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return subviewSizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(
                width: max(currentMax.width, subviewSize.width),
                height: max(currentMax.height, subviewSize.height)
            )
        }
    }

    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            return subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .horizontal
            )
        }
    }
}

private struct Rank: LayoutValueKey {
    static let defaultValue: Int = 1
}

extension View {
    func rank(_ value: Int) -> some View {
        layoutValue(key: Rank.self, value: value)
    }
}
