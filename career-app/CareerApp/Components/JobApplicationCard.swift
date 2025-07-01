//
//  JobApplicationCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 13/01/25.
//

import SwiftUI

struct JobApplicationCard: View {
    var job: JobApplication
    var isEditingMode: Bool
    var editAction: () -> Void
    var deleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            buildHeaderSection()
            buildSkillsSection()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.descriptionGray.opacity(0.9), lineWidth: 1)
        )
        .cornerRadius(10)
    }

    // MARK: - Header (Company, Role, Level, Edit Button, Dates/Trash)
    @ViewBuilder
    private func buildHeaderSection() -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 4) {
                    Text(job.role)
                        .font(.system(size: 20))
                        .foregroundColor(.fivethBlue)
                        .bold()

                    Text(job.level)
                        .font(.system(size: 20))
                        .foregroundColor(.fivethBlue)
                        .bold()
                }
                
                Text(job.company)
                    .font(.system(size: 22))
                    .foregroundColor(.fivethBlue)

                Text("Skills")
                    .italic()
                    .font(.system(size: 18))
                    .foregroundColor(.fivethBlue)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                if !isEditingMode {
                    buildEditButton()
                }

                if isEditingMode {
                    buildTrashButton()
                } else if let last = job.lastInterview, let next = job.nextInterview {
                    buildDateInfo(lastInterview: last, nextInterview: next)
                }
            }
        }
    }

    // MARK: - Edit Button
    private func buildEditButton() -> some View {
        Button(action: editAction) {
            HStack {
                Image(systemName: "pencil")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .foregroundColor(.persianBlue)
        }
        .shadow(radius: 0.7)
    }

    // MARK: - Trash Button
    private func buildTrashButton() -> some View {
        Button(action: deleteAction) {
            Image(systemName: "trash")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.red)
        }
    }

    // MARK: - Date Info
    private func buildDateInfo(lastInterview: String, nextInterview: String) -> some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack {
                Image(systemName: "arrowshape.turn.up.backward.2")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.fivethBlue.opacity(0.7))
                Text(lastInterview)
                    .font(.system(size: 14))
                    .foregroundColor(.fivethBlue.opacity(0.7))
            }

            HStack {
                Image(systemName: "arrow.forward.circle.dotted")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color(red: 0, green: 94/255, blue: 66/255))
                Text(nextInterview)
                    .font(.system(size: 14))
                    .bold()
                    .foregroundColor(Color(red: 0, green: 94/255, blue: 66/255))
            }
        }
    }

    // MARK: - Skills Section
    private func buildSkillsSection() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(job.technicalSkills, id: \.self) { skill in
                    Text(skill)
                        .bold()
                        .font(.system(size: 16))
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(Color.persianBlue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Image(systemName: "pencil")
                    .padding(12)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
        }
    }
}
