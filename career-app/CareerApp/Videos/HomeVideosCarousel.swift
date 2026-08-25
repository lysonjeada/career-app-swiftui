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
                                    Color.persianBlue
                                )
                                .padding()
                            }
                            .frame(
                                width: 220,
                                height: 150
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
