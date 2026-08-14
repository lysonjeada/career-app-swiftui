//
//  FlowLayout.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/08/26.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    struct Cache {
        var sizes: [CGSize] = []
    }

    func makeCache(
        subviews: Subviews
    ) -> Cache {
        Cache(
            sizes: subviews.map {
                $0.sizeThatFits(
                    .unspecified
                )
            }
        )
    }

    func updateCache(
        _ cache: inout Cache,
        subviews: Subviews
    ) {
        cache.sizes = subviews.map {
            $0.sizeThatFits(
                .unspecified
            )
        }
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let maxWidth =
            proposal.width
            ?? .infinity

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var contentWidth: CGFloat = 0

        for size in cache.sizes {
            let nextWidth =
                currentX == 0
                ? size.width
                : currentX
                    + spacing
                    + size.width

            if nextWidth > maxWidth,
               currentX > 0 {

                currentX = 0
                currentY +=
                    rowHeight
                    + spacing

                rowHeight = 0
            }

            if currentX > 0 {
                currentX += spacing
            }

            currentX += size.width

            rowHeight = max(
                rowHeight,
                size.height
            )

            contentWidth = max(
                contentWidth,
                currentX
            )
        }

        return CGSize(
            width:
                proposal.width
                ?? contentWidth,
            height:
                currentY
                + rowHeight
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        var currentX =
            bounds.minX

        var currentY =
            bounds.minY

        var rowHeight:
            CGFloat = 0

        for (
            index,
            subview
        ) in subviews.enumerated() {

            let size =
                cache.sizes[index]

            let maxX =
                bounds.maxX

            let nextX =
                currentX == bounds.minX
                ? currentX + size.width
                : currentX
                    + spacing
                    + size.width

            if nextX > maxX,
               currentX > bounds.minX {

                currentX =
                    bounds.minX

                currentY +=
                    rowHeight
                    + spacing

                rowHeight = 0
            }

            if currentX > bounds.minX {
                currentX += spacing
            }

            subview.place(
                at: CGPoint(
                    x: currentX,
                    y: currentY
                ),
                anchor: .topLeading,
                proposal:
                    ProposedViewSize(
                        width:
                            size.width,
                        height:
                            size.height
                    )
            )

            currentX +=
                size.width

            rowHeight = max(
                rowHeight,
                size.height
            )
        }
    }
}
