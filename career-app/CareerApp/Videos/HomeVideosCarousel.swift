//
//  HomeVideosCarousel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 14/08/26.
//

import SwiftUI

struct HomeVideosCarousel: View {
    let videos: [TechVideo]

    let onSelect:
        (TechVideo) -> Void

    var body: some View {
        VStack(
            alignment: .center,
            spacing: 14
        ) {
            Text(
                "Vídeos"
            )
            .font(
                .title2.bold()
            )
            .foregroundStyle(
                Color.persianBlue
            )

            ScrollView(
                .horizontal,
                showsIndicators:
                    false
            ) {
                LazyHStack(
                    spacing: 14
                ) {
                    ForEach(
                        videos
                    ) { video in

                        Button {
                            onSelect(
                                video
                            )

                        } label: {
                            ZStack {
                                RoundedRectangle(
                                    cornerRadius: 18
                                )
                                .fill(
                                    Color.persianBlue
                                        .opacity(0.14)
                                )

                                if let thumbnailURL =
                                    video.thumbnailURL {

                                    AsyncImage(
                                        url: thumbnailURL
                                    ) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.clear
                                    }
                                    .frame(
                                        width: 220,
                                        height: 150
                                    )
                                    .clipped()

                                    LinearGradient(
                                        colors: [
                                            .black.opacity(0.55),
                                            .clear,
                                        ],
                                        startPoint: .bottom,
                                        endPoint: .center
                                    )
                                }

                                VStack(
                                    spacing: 12
                                ) {
                                    Image(
                                        systemName:
                                            "play.circle.fill"
                                    )
                                    .font(
                                        .system(
                                            size: 46
                                        )
                                    )

                                    Text(
                                        video.title
                                    )
                                    .font(
                                        .headline
                                    )
                                    .lineLimit(2)
                                }
                                .foregroundStyle(
                                    video.thumbnailURL == nil
                                        ? Color.persianBlue
                                        : Color.white
                                )
                                .padding()
                            }
                            .frame(
                                width: 220,
                                height: 150
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 18
                                )
                            )
                        }
                        .buttonStyle(
                            .plain
                        )
                    }
                }
            }
        }
    }
}
