//
//  JobHorizontalList.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 01/07/25.
//

import SwiftUI

struct JobHorizontalList: View {
    @StateObject var viewModel: HomeViewModel
    @State var isClicked: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                Text("Vagas disponíveis")
                    .font(.title2)
                    .bold()
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.titleSectionColor)
                HStack {
                    Spacer()
                    tagPicker
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.githubJobListing) { job in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                AsyncImage(url: URL(string: job.icon)) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 28, height: 28)
                                .clipShape(Circle())

                                Text(job.repository.components(separatedBy: "/").first ?? "Repositório")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondaryBlue)
                            }

                            Text(job.title.prefix(90)) // limite de caracteres
                                .font(.system(size: 16))
                                .bold()
                                .foregroundColor(.persianBlue)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)

                            Text("🕐 Publicado em \(formatDateHour(job.published_at))")
                                .font(.system(size: 12))
                                .foregroundColor(.descriptionGray)

                            if !job.labels.isEmpty {
                                Text("🏷 \(job.labels.joined(separator: ", ").prefix(80))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .frame(height: 180)
                        .frame(width: 260) // ← aumenta tamanho do card
                        .background(Color.backgroundLightGray)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .onTapGesture {
                            if let url = URL(string: job.url) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
            }
        }

        Divider()
    }
    
    private var tagPicker: some View {
        Menu {
            Button(action: {
                viewModel.fetchHome()
//                    viewModel.selectedTag = tag
//                    let tagToFetch = tag == "Todos" ? nil : tag
//                    viewModel.fetchHome(tag: tagToFetch)
            }) {
                HStack {
                    Text("Todos")
                }
            }
            ForEach(viewModel.availableJobs, id: \.self) { tag in
                Button(action: {
                    viewModel.fetchHome(repository: tag)
//                    viewModel.selectedTag = tag
//                    let tagToFetch = tag == "Todos" ? nil : tag
//                    viewModel.fetchHome(tag: tagToFetch)
                }) {
                    HStack {
                        Text(tag.capitalized)
                        if viewModel.selectedTag == tag {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            VStack {
                HStack {
//                    Text(isClicked ? viewModel.selectedTag.capitalized : "")
//                        .font(.subheadline)
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
                .padding(8)
                .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .onTapGesture {
            isClicked.toggle()
        }
    }
    
    func formatDateHour(_ isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM 'às' HH:mm"

        if let date = isoFormatter.date(from: isoString) {
            return outputFormatter.string(from: date)
        } else {
            return "Data inválida"
        }
    }
}
