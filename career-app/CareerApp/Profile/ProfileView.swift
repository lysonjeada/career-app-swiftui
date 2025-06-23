//
//  ProfileView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 20/01/25.
//

import SwiftUI
import CoreData

// Adicione no topo do seu arquivo, fora da ProfileView
struct DynamicTextField: Identifiable {
    let id = UUID()
    var text: String = ""
}

struct ProfileView: View {
    // MARK: - Properties
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: UserProfile.entity(), sortDescriptors: [])
    private var profiles: FetchedResults<UserProfile>
    @StateObject var coordinator: Coordinator
    
    // States
    @State private var profileImage: Image?
    @State private var imageData: Data?
    @State private var showImagePicker = false
    @State private var name = ""
    @State private var experience = ""
    @State private var institution = ""
    @State private var githubLink = ""
    @State private var portfolioLink = ""
    @State private var isSaving = false
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
        .navigationConfig(title: "Profile", backAction: { coordinator.pop() })
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $profileImage, imageData: $imageData)
        }
        .errorAlert(isPresented: $showErrorAlert, message: errorMessage)
        .onAppear(perform: loadProfile)
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
                        .foregroundColor(.persianBlue)
                }
            }
            
            // Botão de excluir (aparece apenas quando há imagem)
            if profileImage != nil {
                Button(action: deleteProfileImage) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: -10, y: 0)  // Ajuste do offset para posicionar corretamente
                }
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 32)
    }
    
    private var cameraIcon: some View {
        Image(systemName: "camera.fill")
            .foregroundColor(.white)
            .padding(6)
            .background(Color.persianBlue.opacity(0.8))
            .clipShape(Circle())
            .offset(x: 35, y: 35)
    }
    
    private var personalInfoSection: some View {
        SectionView(title: "Informações pessoais") {
            customTextField("Nome", text: $name)
            customTextField("Experiência Profissional", text: $experience)
            customTextField("Instituição de Ensino", text: $institution)
        }
    }
    
    private var linksSection: some View {
        SectionView(title: "Links") {
            customTextField("GitHub", text: $githubLink, keyboard: .URL)
            customTextField("Portfólio", text: $portfolioLink, keyboard: .URL)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            ActionButton(
                title: isSaving ? "Salvando..." : "Salvar",
                isLoading: isSaving,
                color: .persianBlue,
                action: { saveProfile() }
            )
            .frame(maxWidth: .infinity)  // Ocupa metade do espaço
            
            ActionButton(
                title: "Excluir",
                isLoading: false,
                color: .red,
                action: { /* Implementar exclusão */ }
            )
            .frame(maxWidth: .infinity)  // Ocupa metade do espaço
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Helper Components
    
    private func SectionView(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 20))
                .bold()
                .foregroundColor(.persianBlue)
            
            Group(content: content)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 2)
    }
    
    private func customTextField(_ placeholder: String,
                                 text: Binding<String>,
                                 keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading) {
            Text(placeholder)
                .font(.system(size: 18))
                .foregroundColor(.persianBlue)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textFieldStyle(PersianBlueTextFieldStyle())
        }
    }
    
    // MARK: - Core Data Operations
    
    private func saveProfile() {
        isSaving = true
        
        let profile: UserProfile
        
        if let existing = profiles.first {
            profile = existing
        } else {
            guard let entity = NSEntityDescription.entity(forEntityName: "UserProfile", in: viewContext) else {
                print("Erro: Entidade não encontrada")
                isSaving = false
                return
            }
            profile = UserProfile(entity: entity, insertInto: viewContext)
            profile.id = UUID()
        }
        
        profile.name = name.isEmpty ? nil : name
        profile.experience = experience.isEmpty ? nil : experience
        profile.institution = institution.isEmpty ? nil : institution
        profile.githubLink = githubLink.isEmpty ? nil : githubLink
        profile.portfolioLink = portfolioLink.isEmpty ? nil : portfolioLink
        profile.profileImage = imageData
        // ... outros campos ...
        
        do {
            try viewContext.save()
            isSaving = false
            //            coordinator.pop()
        } catch {
            print("Erro ao salvar: \(error)")
            isSaving = false
        }
    }
    
    private func loadProfile() {
        guard let profile = profiles.first else { return }
        
        name = profile.name ?? ""
        experience = profile.experience ?? ""
        institution = profile.institution ?? ""
        githubLink = profile.githubLink ?? ""
        portfolioLink = profile.portfolioLink ?? ""
        
        if let savedImageData = profile.profileImage,
           let uiImage = UIImage(data: savedImageData) {
            profileImage = Image(uiImage: uiImage)
            imageData = savedImageData
        }
    }
    
    private func deleteProfileImage() {
        // Remove da visualização
        profileImage = nil
        imageData = nil
        
        // Remove do Core Data
        if let profile = profiles.first {
            profile.profileImage = nil
            do {
                try viewContext.save()
                print("Imagem removida com sucesso")
            } catch {
                print("Erro ao remover imagem: \(error.localizedDescription)")
                errorMessage = "Erro ao remover imagem"
                showErrorAlert = true
            }
        }
    }
    
    @ViewBuilder
    private func buildNotes() -> some View {
        ProfileNotesView()
    }
    
    private func customTextField(_ placeholder: String,
                                 text: Binding<String>,
                                 keyboard: UIKeyboardType = .default,
                                 hasIncludeButton: Bool = false,
                                 hasExcludeButton: Bool = false) -> some View {
        VStack {
            HStack {
                Text(placeholder)
                    .foregroundColor(.persianBlue)
                
                Spacer()
                
                if hasIncludeButton || hasExcludeButton {
                    HStack(spacing: 8) {
                        if hasExcludeButton {
                            Button(action: {}) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 20))
                            }
                        }
                        
                        if hasIncludeButton {
                            Button(action: {}) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20))
                            }
                        }
                    }
                }
            }
            
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .padding(12)
                .background(Color.persianBlue.opacity(0.1))
                .foregroundColor(.persianBlue)
                .cornerRadius(8)
                .accentColor(.persianBlue)
        }
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
                            Text("Voltar")
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

struct ActionButton: View {
    let title: String
    let isLoading: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .frame(maxWidth: .infinity)  // Garante que o texto também expanda
            }
            .padding()
            .foregroundStyle(.white)
            .background(color)
            .font(.headline)
            .cornerRadius(12)
            .frame(maxWidth: .infinity, minHeight: 50)  // Altura mínima consistente
            .animation(.easeInOut, value: isLoading)
        }
        .disabled(isLoading)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileView(coordinator: Coordinator())
}
