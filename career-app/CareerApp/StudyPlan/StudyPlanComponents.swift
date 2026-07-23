//
//  StudyPlanComponents.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 22/07/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct StudyPlanTextField: View {
    let title: String
    let placeholder: String

    @Binding var text: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            Text(title)
                .font(.headline)
                .foregroundColor(.persianBlue)

            TextField(
                placeholder,
                text: $text
            )
            .textInputAutocapitalization(.words)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color.persianBlue,
                        lineWidth: 1
                    )
            }
        }
    }
}

struct StudyPlanMenuField: View {
    let title: String

    @Binding var selectedItem: String

    let options: [String]

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            Text(title)
                .font(.headline)
                .foregroundColor(.persianBlue)

            Menu {
                ForEach(
                    options,
                    id: \.self
                ) { option in
                    Button(option) {
                        selectedItem = option
                    }
                }
            } label: {
                HStack {
                    Text(selectedItem)

                    Spacer()

                    Image(systemName: "chevron.down")
                }
                .foregroundColor(.persianBlue)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color.persianBlue,
                            lineWidth: 1
                        )
                }
            }
        }
    }
}

struct StudyPlanDescriptionField: View {
    @Binding var text: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            HStack {
                Text("Descrição da vaga")
                    .font(.headline)
                    .foregroundColor(.persianBlue)

                Spacer()

                Text("Opcional")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            TextEditor(text: $text)
                .frame(minHeight: 130)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color.persianBlue,
                            lineWidth: 1
                        )
                }
        }
    }
}

struct OptionalResumePicker: View {

    @Binding var selectedFileURL: URL?

    @State private var importing = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            HStack {
                Text("Currículo")
                    .font(.headline)
                    .foregroundColor(.persianBlue)

                Spacer()

                Text("Opcional")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let selectedFileURL {
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.persianBlue)

                    Text(selectedFileURL.lastPathComponent)
                        .font(.subheadline)
                        .lineLimit(1)

                    Spacer()

                    Button {
                        self.selectedFileURL = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(
                    Color.persianBlue.opacity(0.08)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
            }

            Button {
                importing = true
            } label: {
                Label(
                    selectedFileURL == nil
                        ? "Selecionar currículo"
                        : "Trocar currículo",
                    systemImage: "square.and.arrow.up"
                )
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.persianBlue)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color.persianBlue,
                            lineWidth: 1
                        )
                }
            }
        }
        .fileImporter(
            isPresented: $importing,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                selectedFileURL = urls.first

            case let .failure(error):
                errorMessage =
                    error.localizedDescription
            }
        }
        .alert(
            "Erro ao importar currículo",
            isPresented: Binding(
                get: {
                    errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}
