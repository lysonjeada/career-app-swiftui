//
//  ArticleCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/01/25.
//

import SwiftUI

struct ArticleCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let coverImageUrl = article.cover_image ?? ""
            if let url = URL(string: coverImageUrl), !coverImageUrl.isEmpty {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 100)
                        .clipped()
                        .cornerRadius(10)
                } placeholder: {
                    Image("no-image-available")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 100)
                        .clipped()
                        .cornerRadius(10)
                }
            } else {
                Image("no-image-available")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 180, height: 100)
                    .clipped()
                    .cornerRadius(10)
            }
            
            Text(article.title)
                .bold()
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(Color.secondaryBlue)
            
            Text(article.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(article.readable_publish_date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("by \(article.user.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 200, height: 240)
        .background(Color.backgroundLightGray)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
