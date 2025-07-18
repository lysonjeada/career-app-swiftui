//
//  EmptyListView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/07/25.
//

import SwiftUI

struct EmptyInterviewListView: View {
    let action: () -> Void
    let actionTitle: String
    let actionDescription: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.magnifyingglass")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.persianLightBlue)

            Text("Nenhuma entrevista próxima cadastrada")
                .font(.system(size: 16))
                .foregroundColor(Color.adaptiveBlack)

            Text(actionDescription)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.descriptionGray)

            Button(action: {
                action()
//                if let url = URL(string: "https://dev.to/") {
//                    UIApplication.shared.open(url)
//                }
            }) {
                Text(actionTitle)
                    .font(.system(size: 18))
                    .foregroundColor(Color.persianBlue)
                    .shadow(radius: 0.5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
    }
}
