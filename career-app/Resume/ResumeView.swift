//
//  ResumeView.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 24/08/24.
//

import SwiftUI

import SwiftUI

struct ResumeView: View {
    @State private var name: String = "Your Name"
    @State private var city: String = "City"
    @State private var state: String = "State/Country"
    @State private var email: String = "email@address.com"
    @State private var phone: String = "+65 1234 5678"
    @State private var linkedin: String = "linkedin.com/in/your_linkedin"
    @State private var github: String = "github.com/username"
    @State private var otherLink: String = "otherlink.com"
    @State private var summary: String = """
A summary includes short, concise and targeted statements to summarize your skills and experiences. Mostly people will start with why they are here. What is the reason why they do what they do. Followed by “how” they do it and close it with “what” is the thing that they currently doing right now with respect to the ‘why’ and the ‘how’.
"""
    
    @State private var workExperience: [ExperienceItem] = [
        ExperienceItem(position: "Position", companyName: "Company Name", dateRange: "May 2022 - Present", location: "City, State/Country", description: "State your tasks and accomplishments including name of the project and position of responsibility held.")
    ]
    
    @State private var education: [ExperienceItem] = [
        ExperienceItem(position: "Bachelor of Computer Science", companyName: "Name of the Educational Institution", dateRange: "May 2022 - Present", location: "GPA: 4.0 of 4.0", description: "E.g., info about scholarships, student activity, etc.")
    ]
    
    @State private var projects: [ExperienceItem] = [
        ExperienceItem(position: "Project Name", companyName: "(project link)", dateRange: "May 2022 - Present", location: "", description: "State your tasks and accomplishments including name of the project and position of responsibility held.")
    ]
    
    @State private var skills: String = "Skill Category: Skill Name 1, Skill Name 2, Skill Name 3, Skill Name 4, Skill Name 5, etc."
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with name and contact information
                VStack(alignment: .center, spacing: 8) {
                    TextField("Name", text: $name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    TextField("Location", text: Binding(
                        get: { "\(city), \(state)" },
                        set: {
                            let components = $0.split(separator: ",")
                            city = components.first?.trimmingCharacters(in: .whitespaces) ?? ""
                            state = components.last?.trimmingCharacters(in: .whitespaces) ?? ""
                        }
                    ))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    
                    TextField("Email", text: $email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    TextField("Phone", text: $phone)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    TextField("LinkedIn", text: $linkedin)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    TextField("GitHub", text: $github)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    TextField("Other Link", text: $otherLink)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 20)
                
                // Summary section
                TextEditor(text: $summary)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                
                // Work Experience section
                EditableSectionView(title: "WORK EXPERIENCE", items: $workExperience)
                
                // Education section
                EditableSectionView(title: "EDUCATION", items: $education)
                
                // Projects section
                EditableSectionView(title: "PROJECTS", items: $projects)
                
                // Skills section
                VStack(alignment: .leading) {
                    HStack {
                        Text("SKILLS")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        Spacer()
                        
                        Button(action: {
                            // Add a new skill set or category
                            skills += "\nNew Skill Category: Skill Name X, Skill Name Y, etc."
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                    
                    TextEditor(text: $skills)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct EditableSectionView: View {
    let title: String
    @Binding var items: [ExperienceItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.headline)
                    .padding(.bottom, 4)
                
                Spacer()
                
                Button(action: {
                    // Add a new item to the section
                    items.append(ExperienceItem(position: "", companyName: "", dateRange: "", location: "", description: ""))
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            
            ForEach($items) { $item in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("Position", text: $item.position)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: {
                            // Remove the current item
                            if let index = items.firstIndex(where: { $0.id == item.id }) {
                                items.remove(at: index)
                            }
                        }) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                        }
                    }
                    
                    TextField("Company Name", text: $item.companyName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Date Range", text: $item.dateRange)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("Location", text: $item.location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    TextEditor(text: $item.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                Divider()
            }
        }
    }
}

struct ExperienceItem: Identifiable {
    let id = UUID()
    var position: String
    var companyName: String
    var dateRange: String
    var location: String
    var description: String
}

struct ResumeView_Previews: PreviewProvider {
    static var previews: some View {
        ResumeView()
    }
}
