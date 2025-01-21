//
//  ImagePicker.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 20/01/25.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var image: Image?
    @Environment(\.dismiss) var dismiss
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedData: Data? = nil

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()) {
                Text("Selecionar Foto")
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    // Retrieve selected asset in the form of Data
                    if let selectedItem, let data = try? await selectedItem.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            image = Image(uiImage: uiImage)
                        }
                    }
                }
            }
    }
}
