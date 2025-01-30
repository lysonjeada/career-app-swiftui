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
    @State private var notes: [String] = ["Primeira anotação Primeira anotação Primeira anotação Primeira anotação", "Segunda anotação", "Terceira anotação"]
    
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
                    ForEach(0..<min(3, notes.count), id: \.self) { index in
                        Text(notes[index])
                            .lineLimit(nil)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, maxHeight: 80)
                        
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .font(.system(size: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.persianBlue, lineWidth: 1)
                            )
                            .foregroundColor(.black)
                            .onTapGesture {
                                withAnimation {
                                    selectedNoteIndex = index
                                }
                            }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(0..<notes.count, id: \.self) { index in
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
                // TODO: Navegar para o fluxo de notas
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "applepencil.and.scribble")
                        .resizable()
                        .foregroundStyle(.white)
                    //                        .frame(width: 44, height: 44)
                        .scaledToFit()
                        .fixedSize()
                        .clipped()
                        .padding(.leading, 4)
                        .frame(alignment: .center)
                    Text("Ir para notas")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.persianBlue)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 8)
    }
}

struct ProfileNotesView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileNotesView()
    }
}
