//
//  JobApplicationCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 13/01/25.
//

import SwiftUI

struct JobApplicationCard: View {
    var job: JobApplication
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                // Informações principais alinhadas à esquerda
                VStack(alignment: .leading) {
                    Text(job.company)
                        .font(.system(size: 24))
                        .foregroundColor(.fivethBlue)
                        .padding(.bottom, 2)
                    
                    Text(job.level)
                        .font(.system(size: 24))
                        .foregroundColor(.fivethBlue)
                        .padding(.bottom, 8)
                    
                    HStack {
                        Text("Skills")
                            .font(.system(size: 22))
                            .foregroundColor(.fivethBlue)
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Botão "Editar" e datas alinhados à direita
                VStack(alignment: .trailing) {
                    Button(action: {
                        // Ação do botão de editar
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                                .resizable()
                                .bold()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.persianBlue)
                            Text("Editar")
                                .bold()
                                .font(.system(size: 24))
                                .foregroundColor(.persianBlue)
                        }
                    }
                    .padding(.bottom, 8)
                    .shadow(radius: 0.7)
                    
                    if let lastInterview = job.lastInterview,
                       let nextInterview = job.nextInterview {
                        buildDateText(lastInterview: lastInterview, nextInterview: nextInterview)
                    }
                }
                .padding(.trailing, 16)
            }
            
            // Lista horizontal para habilidades técnicas
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(job.technicalSkills, id: \.self) { skill in
                        Text(skill)
                            .bold()
                            .font(.system(size: 16))
                            .padding(.horizontal)
                            .frame(height: 32)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .foregroundColor(.white)
                            .background(Color.persianBlue.opacity(0.8))
                            .cornerRadius(12)
                    }
                    Image(systemName: "pencil")
                        .padding(16)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.leading, 16)
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.descriptionGray.opacity(0.9), lineWidth: 1)
        )
        .cornerRadius(10)
    }

    
    @ViewBuilder
    private func buildDateText(lastInterview: String, nextInterview: String) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "arrowshape.turn.up.backward.2")
                    .resizable()
                    .foregroundColor(.fivethBlue.opacity(0.7))
                    .frame(width: 20, height: 20)
                Text(lastInterview)
                    .font(.system(size: 20))
                    .foregroundColor(.fivethBlue.opacity(0.7))
            }
            HStack {
                Image(systemName: "arrow.forward.circle.dotted")
                    .resizable()
                    .bold()
                    .foregroundColor(Color(red: 0, green: 94, blue: 66))
                    .frame(width: 20, height: 20)
                Text(nextInterview)
                    .bold()
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0, green: 94, blue: 66))
            }
        }
    }
    

}
