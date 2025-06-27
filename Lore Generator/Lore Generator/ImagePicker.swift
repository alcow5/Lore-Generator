//
//  ImagePicker.swift
//  Lore Generator
//
//  Created by Alex on 6/26/25.
//

import SwiftUI
import UIKit
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                print("📷 [ImagePicker] User captured/selected image from camera - size: \(image.size)")
                parent.selectedImage = image
            } else {
                print("❌ [ImagePicker] No image found in camera picker result")
            }
            parent.isPresented = false
            print("📱 [ImagePicker] Dismissing camera picker")
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("🚫 [ImagePicker] User cancelled camera picker")
            parent.isPresented = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// MARK: - Modern Photo Picker (iOS 14+)
@available(iOS 14, *)
struct ModernPhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ModernPhotoPicker
        
        init(_ parent: ModernPhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            print("📋 [ModernPhotoPicker] User finished picking photos - \(results.count) results")
            parent.isPresented = false
            
            guard let provider = results.first?.itemProvider else { 
                print("❌ [ModernPhotoPicker] No item provider found")
                return 
            }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                print("⏳ [ModernPhotoPicker] Loading image from provider...")
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("❌ [ModernPhotoPicker] Error loading image: \(error)")
                        } else if let image = image as? UIImage {
                            print("✅ [ModernPhotoPicker] Successfully loaded image - size: \(image.size)")
                            self.parent.selectedImage = image
                        } else {
                            print("❌ [ModernPhotoPicker] Failed to cast loaded object to UIImage")
                        }
                    }
                }
            } else {
                print("❌ [ModernPhotoPicker] Provider cannot load UIImage objects")
            }
        }
    }
}

// MARK: - Photo Source Selection Sheet
struct PhotoSourceSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    @State private var showingCameraPicker = false
    @State private var showingPhotoPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose Photo Source")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 16) {
                    Button(action: {
                        print("📷 [PhotoSourceSheet] User tapped 'Take Photo' button")
                        showingCameraPicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text(UIImagePickerController.isSourceTypeAvailable(.camera) ? "Take Photo" : "Camera Not Available")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(UIImagePickerController.isSourceTypeAvailable(.camera) ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                    
                    Button(action: {
                        print("📂 [PhotoSourceSheet] User tapped 'Choose from Library' button")
                        showingPhotoPicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.fill")
                            Text("Choose from Library")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Photo")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
        }
        .sheet(isPresented: $showingCameraPicker) {
            ImagePicker(
                selectedImage: $selectedImage,
                isPresented: $showingCameraPicker,
                sourceType: .camera
            )
            .onDisappear {
                if selectedImage != nil {
                    isPresented = false
                }
            }
        }
        .sheet(isPresented: $showingPhotoPicker) {
            if #available(iOS 14, *) {
                ModernPhotoPicker(
                    selectedImage: $selectedImage,
                    isPresented: $showingPhotoPicker
                )
                .onDisappear {
                    if selectedImage != nil {
                        isPresented = false
                    }
                }
            } else {
                ImagePicker(
                    selectedImage: $selectedImage,
                    isPresented: $showingPhotoPicker,
                    sourceType: .photoLibrary
                )
                .onDisappear {
                    if selectedImage != nil {
                        isPresented = false
                    }
                }
            }
        }
    }
} 