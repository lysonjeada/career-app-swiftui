//
//  TutorsView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/08/26.
//

import SwiftUI

struct TutorsView: View {
    @StateObject
    private var viewModel =
        TutorsViewModel()

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView(
                    "Buscando tutores..."
                )

            case .loaded:
                content

            case .error:
                errorView
            }
        }
        .navigationTitle(
            "Tutores"
        )
        .task {
            if viewModel.tutors.isEmpty {
                viewModel.fetchTutors()
            }
        }
    }

    private var content:
        some View {

        ScrollView {
            LazyVStack(
                spacing: 16
            ) {
                ForEach(
                    viewModel.tutors
                ) { tutor in

                    NavigationLink {
                        TutorDetailView(
                            tutorId:
                                tutor.id
                        )

                    } label: {
                        TutorCard(
                            tutor: tutor
                        )
                    }
                    .buttonStyle(
                        .plain
                    )
                    .onAppear {
                        viewModel
                            .loadMoreIfNeeded(
                                currentTutor:
                                    tutor
                            )
                    }
                }

                if viewModel
                    .isLoadingMore {

                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.fetchTutors()
        }
    }

    private var errorView:
        some View {

        ContentUnavailableView {
            Label(
                "Não foi possível carregar os tutores",
                systemImage:
                    "person.2.slash"
            )

        } description: {
            Text(
                """
                Verifique sua conexão
                e tente novamente.
                """
            )

        } actions: {
            Button(
                "Tentar novamente"
            ) {
                viewModel.fetchTutors()
            }
        }
    }
}
