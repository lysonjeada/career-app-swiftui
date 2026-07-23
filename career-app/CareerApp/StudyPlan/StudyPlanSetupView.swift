//
//  StudyPlanSetupView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 22/07/26.
//

import SwiftUI

struct StudyPlanSetupView: View {

    @ObservedObject var viewModel:
        StudyPlanViewModel

    @State private var jobTitle = ""
    @State private var seniority = "Senioridade"
    @State private var jobDescription = ""
    @State private var resumeFileURL: URL?

    private let seniorityOptions = [
        "Intern",
        "Junior",
        "Mid-level",
        "Senior",
        "Lead",
        "Manager"
    ]

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 20
            ) {
                header

                StudyPlanTextField(
                    title: "Cargo",
                    placeholder: "Ex.: iOS Developer",
                    text: $jobTitle
                )

                StudyPlanMenuField(
                    title: "Senioridade",
                    selectedItem: $seniority,
                    options: seniorityOptions
                )

                StudyPlanDescriptionField(
                    text: $jobDescription
                )

                OptionalResumePicker(
                    selectedFileURL: $resumeFileURL
                )

                Button {
                    Task {
                        await viewModel.generateStudyPlan(
                            jobTitle: jobTitle,
                            seniority: seniority,
                            description: jobDescription,
                            resumeURL: resumeFileURL
                        )
                    }
                } label: {
                    Label(
                        "Gerar plano de estudos",
                        systemImage: "sparkles"
                    )
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.persianBlue)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 12
                        )
                    )
                }
            }
            .padding()
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 44))
                .foregroundColor(.persianBlue)

            Text("Monte sua trilha")
                .font(.title2)
                .bold()
                .foregroundColor(.persianBlue)

            Text(
                """
                Informe o cargo e a senioridade. A descrição da vaga e o currículo são opcionais.
                """
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
}
