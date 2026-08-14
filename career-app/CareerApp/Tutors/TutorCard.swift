//
//  TutorCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/08/26.
//

import SwiftUI

struct TutorCard: View {
    let tutor: Tutor

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            HStack(
                alignment: .top,
                spacing: 16
            ) {
                profileImage

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {
                    Text(tutor.name)
                        .font(.title3)
                        .bold()

                    Text(tutor.profession)
                        .font(.subheadline)
                        .foregroundStyle(
                            .secondary
                        )

                    Label(
                        experienceText,
                        systemImage:
                            "briefcase.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                }

                Spacer()

                Image(
                    systemName:
                        "chevron.right"
                )
                .foregroundStyle(
                    .secondary
                )
            }

            Divider()

            levels

            HStack {
                informationItem(
                    icon:
                        "dollarsign.circle.fill",
                    title:
                        "Preço/hora",
                    value:
                        hourlyRateText
                )

                Spacer()

                informationItem(
                    icon:
                        "globe",
                    title:
                        "Idioma",
                    value:
                        tutor.language
                )
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(
                cornerRadius: 22
            )
            .fill(
                Color(
                    .secondarySystemBackground
                )
            )
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 22
            )
            .stroke(
                Color.persianBlue
                    .opacity(0.25),
                lineWidth: 1
            )
        }
    }

    private var profileImage:
        some View {

        AsyncImage(
            url: URL(
                string:
                    tutor.profileImageUrl
                    ?? ""
            )
        ) { image in
            image
                .resizable()
                .scaledToFill()

        } placeholder: {
            Image(
                systemName:
                    "person.crop.circle.fill"
            )
            .resizable()
            .foregroundStyle(
                Color.persianBlue
                    .opacity(0.65)
            )
        }
        .frame(
            width: 76,
            height: 76
        )
        .clipShape(
            Circle()
        )
    }

    private var levels:
        some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            Text(
                "Atende níveis"
            )
            .font(.caption)
            .foregroundStyle(
                .secondary
            )

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                HStack {
                    ForEach(
                        tutor.levels,
                        id: \.self
                    ) { level in
                        Text(level)
                            .font(
                                .caption
                                    .bold()
                            )
                            .padding(
                                .horizontal,
                                12
                            )
                            .padding(
                                .vertical,
                                7
                            )
                            .background(
                                Color.persianBlue
                                    .opacity(0.12)
                            )
                            .foregroundStyle(
                                Color.persianBlue
                            )
                            .clipShape(
                                Capsule()
                            )
                    }
                }
            }
        }
    }

    private func informationItem(
        icon: String,
        title: String,
        value: String
    ) -> some View {

        HStack(spacing: 8) {
            Image(
                systemName: icon
            )
            .foregroundStyle(
                Color.persianBlue
            )

            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(
                        .secondary
                    )

                Text(value)
                    .font(
                        .subheadline
                            .bold()
                    )
            }
        }
    }

    private var experienceText:
        String {

        tutor.yearsOfExperience == 1
        ? "1 ano de experiência"
        : """
        \(tutor.yearsOfExperience) anos de experiência
        """
    }

    private var hourlyRateText:
        String {

        String(
            format:
                "R$ %.2f",
            tutor.hourlyRate
        )
    }
}
