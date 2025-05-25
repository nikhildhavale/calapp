import SwiftUI
import AVFoundation
import UIKit
import PhotosUI

struct CameraView: View {
    @Binding var imageData: Data?
    @Environment(\.presentationMode) var presentationMode
    @State private var showSourceTypeMenu = true
    @State private var sourceType: UIImagePickerController.SourceType?
    
    var body: some View {
        Group {
            if let sourceType = sourceType {
                ImagePickerView(imageData: $imageData, sourceType: sourceType)
                    .ignoresSafeArea()
            } else {
                sourceTypeSelector
            }
        }
    }
    
    private var sourceTypeSelector: some View {
        VStack(spacing: 20) {
            Button(action: {
                sourceType = .camera
            }) {
                HStack {
                    Image(systemName: "camera")
                        .font(.title)
                    Text("Take Photo")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button(action: {
                sourceType = .photoLibrary
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title)
                    Text("Choose from Library")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage,
               let imageData = editedImage.jpegData(compressionQuality: 0.8) {
                parent.imageData = imageData
            } else if let originalImage = info[.originalImage] as? UIImage,
                      let imageData = originalImage.jpegData(compressionQuality: 0.8) {
                parent.imageData = imageData
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
} 