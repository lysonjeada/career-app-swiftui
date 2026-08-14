//
//  TutorDetailView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/08/26.
//

import SwiftUI

struct TutorDetailView: View {
    let tutorId: String

    @StateObject
    private var viewModel =
        TutorDetailViewModel()

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()

            case .loaded:
                if let tutor =
                    viewModel.tutor {

                    content(
                        tutor: tutor
                    )
                }

            case .error:
                ContentUnavailableView(
                    "Tutor indisponível",
                    systemImage:
                        "person.crop.circle.badge.exclamationmark"
                )
            }
        }
        .navigationTitle(
            "Tutor"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
        .task {
            viewModel.fetchTutor(
                id: tutorId
            )
        }
    }

    private func content(
        tutor: Tutor
    ) -> some View {

        ScrollView {
            VStack(
                spacing: 24
            ) {
                AsyncImage(
                    url: URL(
                        string:
                            tutor.profileImageUrl
                            ?? ""
                    )
                ) { image in
                    image
                        .resizable()
                        .scaledToFill()

                } placeholder: {
                    Image(
                        systemName:
                            "person.crop.circle.fill"
                    )
                    .resizable()
                    .foregroundStyle(
                        Color.persianBlue
                            .opacity(0.7)
                    )
                }
                .frame(
                    width: 130,
                    height: 130
                )
                .clipShape(
                    Circle()
                )

                VStack(
                    spacing: 5
                ) {
                    Text(
                        tutor.name
                    )
                    .font(
                        .title2.bold()
                    )

                    Text(
                        tutor.profession
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }

                HStack(
                    spacing: 12
                ) {
                    detailCard(
                        title:
                            "Experiência",
                        value:
                            """
                            \(tutor.yearsOfExperience) anos
                            """,
                        icon:
                            "briefcase.fill"
                    )

                    detailCard(
                        title:
                            "Preço/hora",
                        value:
                            String(
                                format:
                                    "R$ %.2f",
                                tutor.hourlyRate
                            ),
                        icon:
                            "dollarsign.circle.fill"
                    )
                }

                HStack(
                    spacing: 12
                ) {
                    Image(
                        systemName:
                            "globe"
                    )
                    .foregroundStyle(
                        Color.persianBlue
                    )

                    Text(
                        tutor.language
                    )

                    Spacer()
                }
                .padding()
                .background(
                    Color(
                        .secondarySystemBackground
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16
                    )
                )

                VStack(
                    alignment: .leading,
                    spacing: 12
                ) {
                    Text(
                        "Níveis atendidos"
                    )
                    .font(
                        .headline
                    )

                    FlowLayout(
                        spacing: 8
                    ) {
                        ForEach(
                            tutor.levels,
                            id: \.self
                        ) { level in
                            Text(level)
                                .padding(
                                    .horizontal,
                                    12
                                )
                                .padding(
                                    .vertical,
                                    8
                                )
                                .background(
                                    Color.persianBlue
                                        .opacity(0.15)
                                )
                                .foregroundStyle(
                                    Color.persianBlue
                                )
                                .clipShape(
                                    Capsule()
                                )
                        }
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                if let bio = tutor.bio,
                   !bio.isEmpty {

                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {
                        Text(
                            "Sobre"
                        )
                        .font(
                            .headline
                        )

                        Text(bio)
                            .foregroundStyle(
                                .secondary
                            )
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }

                Button {
                    // Próxima feature:
                    // contratação/agendamento
                } label: {
                    Text(
                        "Solicitar mentoria"
                    )
                    .bold()
                    .frame(
                        maxWidth: .infinity
                    )
                    .padding()
                    .background(
                        Color.persianBlue
                    )
                    .foregroundStyle(
                        .white
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 14
                        )
                    )
                }
            }
            .padding()
        }
    }

    private func detailCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {

        VStack(
            spacing: 8
        ) {
            Image(
                systemName: icon
            )
            .font(.title2)
            .foregroundStyle(
                Color.persianBlue
            )

            Text(value)
                .font(
                    .headline
                )

            Text(title)
                .font(
                    .caption
                )
                .foregroundStyle(
                    .secondary
                )
        }
        .frame(
            maxWidth: .infinity
        )
        .padding()
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }
}
