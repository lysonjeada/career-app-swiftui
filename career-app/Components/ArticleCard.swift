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
            HStack {
                if let url = URL(string: coverImageUrl), !coverImageUrl.isEmpty {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60, alignment: .leading)
                            .clipped()
                            .cornerRadius(10)
                            
                    } placeholder: {
                        Image("no-image-available")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 80, alignment: .leading)
                            .clipped()
                            .cornerRadius(10)
                    }
                } else {
                    Image("no-image-available")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60, alignment: .leading)
                        .clipped()
                        .cornerRadius(2)


                }
                
               
                    
                
                Text(article.title)
                    .bold()
                    .font(.system(size: 12))
                    .lineLimit(3)
                    .foregroundColor(Color.secondaryBlue)
            }
            .padding(.top, 4)
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
        .background(Color.backgroundLightGray)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    let article = Article(id: 1, title: "Titutlo", description: "LoremIpsumLoremIpsum LoremIpsumLoremIpsum LoremIpsumLoremIpsum LoremIpsumLoremIpsum", readable_publish_date: "", url: "", cover_image: nil, user: .init(name: "lys", profile_image: ""))
    ArticleCard(article: article)
}
