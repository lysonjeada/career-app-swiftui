//
//  ProfileView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 20/01/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var profileImage: Image? = nil
    @State private var showImagePicker = false
    @State private var name: String = ""
    @State private var experience: String = ""
    @State private var institution: String = ""
    @State private var githubLink: String = ""
    @State private var portfolioLink: String = ""

    var body: some View {
        VStack {
            Button(action: {
                showImagePicker.toggle()
            }) {
                if let profileImage = profileImage {
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.persianBlue)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 32)
            .frame(alignment: .center)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
            
            
            
            VStack {
                Text("Informações pessoais")
                
                VStack(alignment: .leading) {
                    TextField("Nome", text: $name)
                    TextField("Experiência Profissional", text: $experience)
                    TextField("Instituição de Ensino", text: $institution)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
            }
            .padding(.horizontal, 16)
            
            VStack {
                Text("Links")
                
                VStack(alignment: .leading) {
                    TextField("GitHub", text: $githubLink)
                        .keyboardType(.URL)
                    TextField("Portfólio", text: $portfolioLink)
                        .keyboardType(.URL)
                        
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                    
            }
            .padding(.horizontal, 16)
            Spacer()
            buildNotes()
            Spacer()
            Button(action: {
                saveProfile()
            }) {
                    Text("Salvar")
                        .padding()
                        .foregroundStyle(.white)
                        .background(Color.persianBlue)
                        
                .font(.headline)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(Color.persianBlue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            
        }
        .frame(maxHeight: .infinity)
        .background(Color.backgroundLightGray)
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveProfile() {
        //TODO: Criar açao
        print("Perfil salvo!")
    }
    
    @ViewBuilder
    private func buildNotes() -> some View {
        VStack(alignment: .leading) {
            HStack {
                
                Text("Notas")
                
                Spacer()
                
                Button {
                    //TODO: Exibir texto
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.persianBlue)
                }
            }
            
            Text("Anote dificuldades, dúvidas, assuntos a serem estudadas. Você também pode navegar até o menu de notas para criar, editar e apagar suas próprias notas!")
            
            
        }
    }
}

#Preview {
    ProfileView()
}
