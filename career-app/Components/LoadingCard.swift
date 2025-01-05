//
//  LoadingCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/01/25.
//

import SwiftUI

struct LoadingCard: View {
    
    let style: CardStyle
    let title: String
    
    enum CardStyle {
        case article
        case job
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(Color.titleSectionColor)
            
            switch style {
            case .article:
                buildArticle()
            case .job:
                buildJob()
            }
        }
    }
    
    @ViewBuilder
    private func buildJob() -> some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0...2, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.skeletonColor)
                                .frame(height: 20)
                                .clipped()
                            
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.skeletonColor)
                                .frame(height: 16)
                                .clipped()
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.skeletonColor)
                                .frame(width: 48, height: 16)
                                .clipped()
                        }
                        .padding(.horizontal, 16)
                        .frame(width: 160, height: 120)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
                .padding(.vertical, 10)
            }
    }
    
    @ViewBuilder
    private func buildArticle() -> some View {
        ScrollView {
            HStack(spacing: 16) {
                ForEach(1...2, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.skeletonColor)
                            .frame(height: 100)
                            .clipped()
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.skeletonColor)
                            .frame(height: 16)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.skeletonColor)
                            .frame(height: 24)
                        
                        HStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.skeletonColor)
                                .frame(width: 40, height: 14, alignment: .leading)
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.skeletonColor)
                                .frame(width: 40, height: 14, alignment: .trailing)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    VStack {
        LoadingCard(style: .job, title: "Próximas Entrevistas")
        Spacer()
        Divider()
        LoadingCard(style: .article, title: "Artigos")
    }
    
}
