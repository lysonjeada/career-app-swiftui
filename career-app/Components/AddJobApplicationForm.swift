//
//  AddJobApplicationForm.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/01/25.
//

import SwiftUI

struct AddJobApplicationForm: View {
    @Binding var newCompany: String
    @Binding var newLevel: String
    @Binding var newLastInterview: String
    @Binding var newNextInterview: String
    @Binding var newTechnicalSkills: String
    
    var addNewJob: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Company Details")) {
                    TextField("Company", text: $newCompany)
                    TextField("Job Level", text: $newLevel)
                }
                
                Section(header: Text("Interview Dates")) {
                    TextField("Last Interview", text: $newLastInterview)
                    TextField("Next Interview", text: $newNextInterview)
                }
                
                Section(header: Text("Technical Skills")) {
                    TextEditor(text: $newTechnicalSkills)
                        .frame(height: 150)
                }
                
                Button(action: {
                    addNewJob()
                }) {
                    Text("Add Job Application")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Add Job Application")
            .navigationBarItems(trailing: Button("Cancel") {
                UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true)
            })
        }
    }
}
