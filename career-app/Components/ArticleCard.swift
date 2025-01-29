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
                        .frame(height: 80)
                        .frame(maxWidth: 180)
                        .clipped()
                        .cornerRadius(10)
                        .padding(.top, 4)
                        .padding(.horizontal, 16)
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
                    .frame(width: 180, height: 80, alignment: .center)
                    .clipped()
                    .cornerRadius(10)
            }
            
            Text(article.title)
                .bold()
                .font(.system(size: 16))
                .lineLimit(2)
                .foregroundColor(Color.secondaryBlue)
                .padding(.horizontal, 16)
            
            Text(article.description)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineLimit(3)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            
            HStack {
                Text(article.readable_publish_date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("by \(article.user.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
        }
//        .padding()
//        .frame(width: 200, height: 240)
        .background(Color.backgroundLightGray)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    let article = Article(id: 1, title: "Titutlo", description: "LoremIpsumLoremIpsum LoremIpsumLoremIpsum LoremIpsumLoremIpsum LoremIpsumLoremIpsum", readable_publish_date: "", url: "", cover_image: nil, user: .init(name: "lys", profile_image: ""))
    ArticleCard(article: article)
}
