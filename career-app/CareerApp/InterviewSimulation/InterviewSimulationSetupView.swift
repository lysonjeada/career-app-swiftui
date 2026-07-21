//
//  Untitled.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 21/07/26.
//

import SwiftUI

struct InterviewSimulationSetupView: View {
    @ObservedObject var viewModel:
        InterviewSimulationViewModel

    @State private var jobTitle = ""
    @State private var seniority = "Senioridade"
    @State private var description = ""

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
            VStack(alignment: .leading, spacing: 20) {
                setupHeader

                SimulationTextField(
                    title: "Cargo",
                    placeholder: "Ex.: iOS Developer",
                    text: $jobTitle
                )

                SimulationMenuField(
                    title: "Senioridade",
                    selectedItem: $seniority,
                    options: seniorityOptions
                )

                SimulationDescriptionField(
                    text: $description
                )

                Button {
                    Task {
                        await viewModel.startSimulation(
                            jobTitle: jobTitle,
                            seniority: seniority,
                            description: description
                        )
                    }
                } label: {
                    Label(
                        "Começar simulação",
                        systemImage: "play.fill"
                    )
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.persianBlue)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                }
            }
            .padding()
        }
    }

    private var setupHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.wave.2.fill")
                .font(.system(size: 42))
                .foregroundColor(.persianBlue)

            Text("Prepare sua entrevista")
                .font(.title2)
                .bold()
                .foregroundColor(.persianBlue)

            Text(
                "Informe o cargo e a senioridade para gerar perguntas personalizadas."
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
}
