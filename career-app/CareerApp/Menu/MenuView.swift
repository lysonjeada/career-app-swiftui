//
//  MenuView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/03/25.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    HStack {
                        Text("Perfil")
                            .foregroundColor(.persianBlue)
                            .font(.system(size: 20))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.persianBlue)
                    }
                    HStack {
                        Text("Candidaturas")
                            .foregroundColor(.persianBlue)
                            .font(.system(size: 20))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.persianBlue)
                    }
                }
                .background(Color.backgroundLightGray)
            }
            .padding(.top, 4)
            .toolbarBackground(Color.backgroundLightGray, for: .navigationBar)
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.automatic)
            .background(Color.backgroundLightGray)
        }
        .background(Color.backgroundLightGray)
        
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
