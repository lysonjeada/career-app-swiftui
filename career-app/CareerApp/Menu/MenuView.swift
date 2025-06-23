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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Menu")
                        .bold()
                        .font(.system(size: 28))
                        .foregroundColor(.persianBlue)
                }
            }
        }
//        .background(Color.backgroundLightGray)
        
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
