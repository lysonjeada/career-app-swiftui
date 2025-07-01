//
//  MenuView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/03/25.
//

import SwiftUI

struct MenuView: View {
    @StateObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Button {
                        coordinator.push(page: .profile)
                    } label: {
                        HStack {
                            Text("Perfil")
                                .foregroundColor(.persianBlue)
                                .font(.system(size: 20))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.persianBlue)
                        }
                    }
                    .listRowBackground(Color.backgroundLightGray)
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
        MenuView(coordinator: Coordinator())
    }
}
