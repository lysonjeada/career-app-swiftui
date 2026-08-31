//
//  ProfileView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 20/01/25.
//

import SwiftUI

// Adicione no topo do seu arquivo, fora da ProfileView
struct DynamicTextField: Identifiable {
    let id = UUID()
    var text: String = ""
}

struct ProfileView: View {
    // MARK: - Properties
    let userId: String?
    let coordinator: ProfileCoordinator
    @StateObject var viewModel: ProfileViewModel

    // States
    @State private var profileImage: Image?
    @State private var imageData: Data?
    @State private var showImagePicker = false
    @State private var showDeleteConfirmation = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileImageSection
                personalInfoSection
                linksSection
                actionButtons
            }
            .padding(.vertical)
        }
        .background(Color.backgroundLightGray)
        .navigationConfig(
            title: "Profile",
            backAction: {
                coordinator.pop()
            }
        )
        .sheet(
            isPresented: $showImagePicker
        ) {
            ImagePicker(
                image: $profileImage,
                imageData: $imageData
            )
        }
        .confirmationDialog(
            "Excluir sua conta?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                "Excluir permanentemente",
                role: .destructive
            ) {
                deleteAccount()
            }

            Button(
                "Cancelar",
                role: .cancel
            ) {}
        } message: {
            Text(
                "Esta ação é permanente e não poderá ser desfeita."
            )
        }
        .errorAlert(
            isPresented: $showErrorAlert,
            message: errorMessage
        )
        .onChange(
            of: viewModel.didDeleteUser
        ) { _, didDeleteUser in
            guard didDeleteUser else {
                return
            }

            handleDeletedAccount()
        }
        .onChange(
            of: viewModel.deletionErrorMessage
        ) { _, message in
            guard let message,
                  !message.isEmpty
            else {
                return
            }

            errorMessage = message
            showErrorAlert = true

            viewModel.clearDeletionError()
        }
        .onChange(
            of: viewModel.localProfileErrorMessage
        ) { _, message in
            guard let message,
                  !message.isEmpty
            else {
                return
            }

            errorMessage = message
            showErrorAlert = true

            viewModel.clearLocalProfileError()
        }
        .onAppear(
            perform: loadProfile
        )
    }
    
    // MARK: - Subviews
    
    private var profileImageSection: some View {
        ZStack(alignment: .bottomLeading) {  // Alterado para .bottomLeading
            Button(action: { showImagePicker.toggle() }) {
                if let profileImage = profileImage {
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(cameraIcon)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.persianBlue, lineWidth: 2)
                        )
                        .overlay(cameraIcon)
                        .foregroundColor(.persianBlue)
                }
            }
            
            // Botão de excluir (aparece apenas quando há imagem)
            if profileImage != nil {
                Button(action: deleteProfileImage) {
                    Image(systemName: "trash.fill")
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Circle())
                        .offset(x: -10, y: 4)  // Ajuste do offset para posicionar corretamente
                }
            }
        }
        .onAppear {
            if let userId {
                viewModel.fetchProfile(userId: userId)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 32)
    }
    
    private var cameraIcon: some View {
        Image(systemName: "camera.fill")
            .frame(width: 24, height: 24)
            .foregroundColor(.white)
            .padding(6)
            .background(Color.persianBlue.opacity(0.8))
            .clipShape(Circle())
            .offset(x: 45, y: 35)
    }
    
    private var personalInfoSection: some View {
        SectionView(title: "Informações pessoais") {
            CustomTextField("Username", text: $viewModel.username)
            CustomTextField("Email", text: $viewModel.email)
            CustomTextField("Experiência Profissional", text: $viewModel.experience)
            CustomTextField("Instituição de Ensino", text: $viewModel.institution)
        }
    }

    private var linksSection: some View {
        SectionView(title: "Links") {
            CustomTextField("GitHub", text: $viewModel.githubLink, keyboard: .URL)
            CustomTextField("Portfólio", text: $viewModel.portfolioLink, keyboard: .URL)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            ActionButton(
                title: viewModel.isSavingLocalProfile ? "Salvando..." : "Salvar",
                isLoading: viewModel.isSavingLocalProfile,
                color: .persianBlue,
                action: { viewModel.saveLocalProfile(imageData: imageData) }
            )
            .frame(maxWidth: .infinity)  // Ocupa metade do espaço
            
            ActionButton(
                title: viewModel.isDeletingUser
                    ? "Excluindo..."
                    : "Excluir",
                icon: "trash.fill",
                isLoading: viewModel.isDeletingUser,
                color: .red
            ) {
                showDeleteConfirmation = true
            }
            .disabled(
                viewModel.isDeletingUser
                || userId == nil
            )
            .frame(maxWidth: .infinity)  // Ocupa metade do espaço
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Perfil local

    private func loadProfile() {
        viewModel.loadLocalProfile()

        guard let savedImageData = viewModel.profileImageData,
              let uiImage = UIImage(data: savedImageData)
        else {
            return
        }

        profileImage = Image(uiImage: uiImage)
        imageData = savedImageData
    }

    private func deleteProfileImage() {
        profileImage = nil
        imageData = nil

        viewModel.deleteProfileImage()
    }
    
    @ViewBuilder
    private func buildNotes() -> some View {
        ProfileNotesView()
    }
    
    private func deleteAccount() {
        guard let userId,
              !userId.isEmpty
        else {
            errorMessage =
                "Não foi possível identificar o usuário."

            showErrorAlert = true
            return
        }

        viewModel.deleteUser(
            userId: userId
        )
    }
    
    private func handleDeletedAccount() {
        deleteLocalProfile()

        viewModel.consumeDeletionSuccess()

        coordinator.performLogout()
    }
    
    private func deleteLocalProfile() {
        viewModel.deleteLocalProfile()

        profileImage = nil
        imageData = nil
    }
}

extension View {
    
    func navigationConfig(title: String, backAction: @escaping () -> Void) -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.persianBlue, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .bold()
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: backAction) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                    }
                }
            }
    }
    
    func errorAlert(isPresented: Binding<Bool>, message: String) -> some View {
        self.alert("Erro ao salvar", isPresented: isPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(message)
        }
    }
}

// MARK: - Custom Styles

struct PersianBlueTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.persianBlue.opacity(0.1))
            .foregroundColor(.persianBlue)
            .cornerRadius(8)
            .accentColor(.persianBlue)
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: () -> Content
    
    init(title: String,
         alignment: HorizontalAlignment = .center,
         spacing: CGFloat = 8,
         @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            Text(title)
                .font(.system(size: 20))
                .bold()
                .foregroundColor(.persianBlue)
            
            Group(content: content)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 2)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String?       // Novo parâmetro opcional
    let isLoading: Bool     // Novo parâmetro com default
    let color: Color
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,           // Default = nil
        isLoading: Bool = false,       // Default = false
        color: Color,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else if let iconName = icon {
                    Image(systemName: iconName)
                        .foregroundStyle(.white)
                }
                
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .foregroundStyle(.white)
            .background(color)
            .font(.headline)
            .cornerRadius(12)
            .frame(maxWidth: .infinity, minHeight: 50)
            .animation(.easeInOut, value: isLoading)
        }
        .disabled(isLoading)
        .frame(maxWidth: .infinity)
    }
}


struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    
    init(_ placeholder: String,
         text: Binding<String>,
         keyboard: UIKeyboardType = .default) {
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboard
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(placeholder)
                .font(.system(size: 18))
                .foregroundColor(.persianBlue)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(PersianBlueTextFieldStyle())
        }
    }
}

#Preview {
    ProfileView(userId: nil, coordinator: ProfileCoordinator(), viewModel: ProfileViewModel())
}
