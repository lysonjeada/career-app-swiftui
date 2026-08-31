//
//  FavoritesView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 26/08/26.
//

import SwiftUI

struct FavoritesView: View {
    enum FavoriteKind:
        String,
        CaseIterable,
        Identifiable {
        
        case videos = "Vídeos"
        case articles = "Artigos"
        
        var id: String {
            rawValue
        }
    }
    
    @State
    private var selectedKind:
        FavoriteKind = .videos
    
    @ObservedObject
    var coordinator: Coordinator
    
    var body: some View {
        VStack(spacing: 0) {
            Picker(
                "",
                selection: $selectedKind
            ) {
                ForEach(
                    FavoriteKind.allCases
                ) { kind in
                    Text(
                        kind.rawValue
                    )
                    .tag(kind)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Group {
                switch selectedKind {
                case .videos:
                    FavoriteVideosView(
                        coordinator:
                            coordinator.videos
                    )

                case .articles:
                    FavoriteArticlesView {
                        articleId in

                        coordinator.push(
                            .articleDetail(
                                id:
                                    articleId
                            )
                        )
                    }
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .navigationTitle(
            "Favoritos"
        )
    }
}
