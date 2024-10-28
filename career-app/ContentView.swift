//
//  ContentView.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 12/08/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BlogView()
                .tabItem {
                    Label(HomeStrings.blogTitle,
                          systemImage: "doc.text")
                    .foregroundColor(.persianBlue)
                    
                }
                .foregroundColor(.persianBlue)
            
            InterviewGenerateQuestionsView()
                .tabItem {
                    Label(HomeStrings.interviewTitle,
                          systemImage: "mic.fill")
                    .foregroundColor(.persianBlue)
                }
                .foregroundColor(.persianBlue)
            
            JobApplicationTrackerView()
                .tabItem {
                    Label(HomeStrings.resumeTitle,
                          systemImage: "book.fill")
                    .foregroundColor(.persianBlue)
                }
                .foregroundColor(.persianBlue)
            
            MenuView()
                .tabItem {
                    Label(HomeStrings.menuTitle,
                          systemImage: "line.horizontal.3")
                    .foregroundColor(.persianBlue)
                }
                
        }
    }
}

struct CurriculumView: View {
    var body: some View {
        Text("Curriculum View")
            .font(.largeTitle)
            .navigationTitle("Curriculum")
    }
}

struct MenuView: View {
    var body: some View {
        Text("Menu View")
            .font(.largeTitle)
            .navigationTitle("Menu")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



