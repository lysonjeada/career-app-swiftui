//
//  ProfileNotesView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 22/01/25.
//

import SwiftUI

struct ProfileNotesView: View {
    @State private var isDescriptionExpanded: Bool = false
    @State private var selectedNoteIndex: Int? = nil
    @State private var notes: [String] = ["Primeira anotação", "Segunda anotação", "Terceira anotação"]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Notas")
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation {
                        isDescriptionExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isDescriptionExpanded ? 180 : 0))
                        .foregroundColor(.persianBlue)
                }
            }

            if isDescriptionExpanded {
                Text("Anote dificuldades, dúvidas, assuntos a serem estudados. Você também pode navegar até o menu de notas para criar, editar e apagar suas próprias notas!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
            }

            if selectedNoteIndex == nil {
                HStack(spacing: 8) {
                    ForEach(0..<min(3, notes.count), id: \.\self) { index in
                        Text(notes[index])
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .onTapGesture {
                                withAnimation {
                                    selectedNoteIndex = index
                                }
                            }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(0..<notes.count, id: \.\self) { index in
                        if index == selectedNoteIndex {
                            TextEditor(text: $notes[index])
                                .frame(height: 100)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedNoteIndex = nil
                                }
                        } else {
                            Text(notes[index])
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedNoteIndex = index
                                }
                        }
                    }
                }
            }

            Button {
                // Navegar para o fluxo de notas
            } label: {
                HStack {
                    Image("notes")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)

                    Text("Ir para notas")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.persianBlue)
                .cornerRadius(8)
            }
            .padding(.top, 16)
        }
        .padding()
    }
}

struct ProfileNotesView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileNotesView()
    }
}
