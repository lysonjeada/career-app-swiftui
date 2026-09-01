//
//  JobApplicationTrackerView.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 28/10/24.
//

import SwiftUI

struct JobApplicationTrackerView: View {
    @StateObject var listViewModel: JobApplicationTrackerListViewModel
    @State private var isEditingMode = false
    let coordinator: TrackCoordinator

    var body: some View {
        NavigationStack {
            switch listViewModel.viewState {
            case .loading:
                ZStack {
                    VStack(spacing: 16) {
                        MinimalSpinner()
                            .frame(width: 60, height: 60)
                    }
                }
            case .loaded:
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack {
                            if listViewModel.jobApplications.isEmpty {
                                EmptyStateView()
                            } else {
                                ApplicationsListView(
                                    applications: listViewModel.jobApplications,
                                    isEditingMode: $isEditingMode,
                                    onEdit: editJob,
                                    onTrash: { job in listViewModel.deleteInterview(interviewId: job.id) }
                                )
                            }
                        }
                        .padding(.bottom, 80) // Espaço para os botões flutuantes
                    }

                    FloatingActionButtons(
                        isEditingMode: $isEditingMode,
                        coordinator: coordinator
                    )
                }

            }
        }
        .onAppear { listViewModel.fetchJobApplications() }
        .navigationTitle("Candidaturas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        // MARK: - SnackBar (Toast) Implementation
        .overlay(alignment: .top) { // Alinha a snack bar ao topo
            if listViewModel.showSnackBar {
                SnackBarView(message: listViewModel.snackBarMessage)
                    .transition(.move(edge: .top).combined(with: .opacity)) // Transição suave
                    .animation(.easeInOut, value: listViewModel.showSnackBar) // Animação
                    .padding(.top, 50) // Ajusta a posição abaixo da barra de navegação
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text("Candidaturas")
                .bold()
                .font(.system(size: 28))
                .foregroundColor(.persianBlue)
        }
    }

    func editJob(_ job: JobApplication) {
        coordinator.push(.editJob(job))
    }
}


// MARK: - SnackBarView (Novo Componente)

struct SnackBarView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "info.circle.fill") // Ícone para indicação visual
                .foregroundColor(.white)
            Text(message)
                .foregroundColor(.white)
                .font(.subheadline)
                .bold()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(Color.black.opacity(0.75)) // Fundo escuro semitransparente
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

// MARK: - Subviews

private struct EmptyStateView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text("Nada foi encontrado :(")
                .bold()
                .font(.title)
                .foregroundColor(.persianBlue)
                .padding(.top, 49)
            
            Text("Parece que você ainda não adicionou\nnenhuma candidatura.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.bottom, 160)
            
            AnimatedPrompt()
        }
        .padding()
    }
}

private struct AnimatedPrompt: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Text("Clique para adicionar")
                .bold()
                .foregroundColor(.persianBlue)
                .shadow(radius: 0.3)
                .offset(y: isAnimating ? -10 : 10)
            
            Image(systemName: "arrow.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
                .foregroundColor(.persianBlue)
                .offset(y: isAnimating ? -10 : 10)
        }
        .animation(
            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onAppear { isAnimating = true }
        .padding(.bottom, 100)
    }
}

private struct ApplicationsListView: View {
    let applications: [JobApplication]
    @Binding var isEditingMode: Bool
    let onEdit: (JobApplication) -> Void
    let onTrash: (JobApplication) -> Void
    
    var body: some View {
        ForEach(applications) { job in
            JobApplicationCard(
                job: job,
                isEditingMode: isEditingMode,
                editAction: { onEdit(job) },
                deleteAction: { onTrash(job) }
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

private struct FloatingActionButtons: View {
    @Binding var isEditingMode: Bool
    let coordinator: TrackCoordinator

    var body: some View {
        HStack(spacing: 48) {
            SecondaryButtonWithIcon(title: isEditingMode ? "checkmark" : "trash", action: { isEditingMode.toggle() })

            PrimaryButtonWithIcon(title: "plus", action: { coordinator.push(.addJob) })
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
    }
}


struct JobApplicationTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView()
    }
}
