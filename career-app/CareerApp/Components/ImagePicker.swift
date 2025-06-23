//
//  ImagePicker.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 20/01/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: Image?
    @Binding var imageData: Data?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true // Habilita o editor de imagem
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.editedImage] as? UIImage { // Usa a imagem editada
                parent.image = Image(uiImage: uiImage)
                parent.imageData = uiImage.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// Versão alternativa com PhotosPicker + Editor customizado
struct AdvancedImagePicker: View {
    @Binding var image: Image?
    @Binding var imageData: Data?
    @Environment(\.dismiss) var dismiss
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showingCropper = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Selecionar Foto")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.persianBlue)
                    .cornerRadius(8)
            }
        }
        .onChange(of: selectedItem) {
            guard let selectedItem else { return }
            Task {
                if let data = try? await selectedItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    // Mostra o editor antes de confirmar
                    inputImage = uiImage
                    showingCropper = true
                }
            }
        }
        .sheet(isPresented: $showingCropper) {
            if let inputImage {
                ImageCropper(image: $image, imageData: $imageData, inputImage: inputImage)
            }
        }
    }
}

struct ImageCropper: View {
    @Binding var image: Image?
    @Binding var imageData: Data?
    @Environment(\.dismiss) var dismiss
    let inputImage: UIImage
    @State private var croppedImage: UIImage?
    
    var body: some View {
        VStack {
            Image(uiImage: inputImage)
                .resizable()
                .scaledToFit()
                .overlay(
                    Rectangle()
                        .stroke(Color.persianBlue, lineWidth: 2)
                        .frame(width: 200, height: 200)
                )
            
            HStack {
                Button("Cancelar") {
                    dismiss()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Confirmar") {
                    if let cropped = cropImage(inputImage, to: CGRect(x: 100, y: 100, width: 200, height: 200)) {
                        image = Image(uiImage: cropped)
                        imageData = cropped.jpegData(compressionQuality: 0.8)
                    }
                    dismiss()
                }
                .padding()
                .background(Color.persianBlue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
    
    func cropImage(_ inputImage: UIImage, to rect: CGRect) -> UIImage? {
        guard let cgImage = inputImage.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: inputImage.scale, orientation: inputImage.imageOrientation)
    }
}

