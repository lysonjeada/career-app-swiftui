//
//  ResumeFeedbackIcon.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 23/07/26.
//

import SwiftUI

struct ResumeFeedbackIcon: View {
    let didExportResume: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    Color.persianBlue.opacity(0.12)
                )
                .frame(
                    width: 58,
                    height: 58
                )

            Image(
                systemName: didExportResume
                    ? "checkmark.circle.fill"
                    : "doc.text.fill"
            )
            .font(.system(size: 25))
            .foregroundColor(
                Color.persianBlue
            )
        }
    }
}
