//
//  ContentView.swift
//  Lore Generator
//
//  Created by Alex on 6/26/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var loreService = LoreService()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LoreObject.timestamp, ascending: false)],
        animation: .default)
    private var loreObjects: FetchedResults<LoreObject>
    
    @State private var showingPhotoSheet = false
    @State private var selectedImage: UIImage?
    @State private var showingLoreDisplay = false
    @State private var generatedLore: String = ""
    @State private var currentObjectName: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                if loreObjects.isEmpty {
                                    EmptyStateView {
                    print("🎯 [ContentView] User tapped 'Start Creating Lore' button")
                    showingPhotoSheet = true
                }
                } else {
                    List {
                        ForEach(loreObjects, id: \.objectID) { loreObject in
                            LoreHistoryItemView(loreObject: loreObject)
                        }
                        .onDelete(perform: deleteLoreObjects)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            print("🎯 [ContentView] User tapped main camera button")
                            showingPhotoSheet = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 70, height: 70)
                                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Lore Generator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingPhotoSheet) {
                PhotoSourceSheet(
                    isPresented: $showingPhotoSheet,
                    selectedImage: $selectedImage
                )
            }
            .onChange(of: selectedImage) { newImage in
                if let image = newImage {
                    print("📸 [ContentView] User selected/captured image - size: \(image.size)")
                    generateLoreForImage(image)
                } else {
                    print("📸 [ContentView] No image selected")
                }
            }
            .sheet(isPresented: $showingLoreDisplay) {
                if let image = selectedImage {
                    LoreDisplayView(
                        image: image,
                        loreText: generatedLore,
                        objectName: currentObjectName.isEmpty ? nil : currentObjectName
                    )
                    .onDisappear {
                        saveLoreObject()
                    }
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .overlay(
                Group {
                    if loreService.isLoading {
                        LoadingView()
                    }
                }
            )
        }
    }
    
    private func generateLoreForImage(_ image: UIImage) {
        print("🎯 [ContentView] Starting lore generation for image...")
        Task {
            do {
                print("⏳ [ContentView] Calling LoreService to generate lore...")
                let lore = try await loreService.generateLore(for: image)
                await MainActor.run {
                    print("✅ [ContentView] Lore generation successful!")
                    generatedLore = lore
                    // Try to extract object name from first sentence
                    currentObjectName = extractObjectName(from: lore)
                    print("🏷️ [ContentView] Extracted object name: '\(currentObjectName)'")
                    print("📄 [ContentView] Generated lore: \(lore.prefix(100))...")
                    showingLoreDisplay = true
                    print("📱 [ContentView] Presenting lore display view")
                }
            } catch {
                await MainActor.run {
                    print("❌ [ContentView] Lore generation failed: \(error.localizedDescription)")
                    alertMessage = error.localizedDescription
                    showingAlert = true
                    selectedImage = nil
                    print("🚨 [ContentView] Showing error alert and resetting image")
                }
            }
        }
    }
    
    private func extractObjectName(from lore: String) -> String {
        // Simple extraction - get first few words before common phrases
        let commonPhrases = ["is", "was", "appears", "seems", "looks", "stands", "lies"]
        let words = lore.components(separatedBy: .whitespacesAndNewlines)
        
        for (index, word) in words.enumerated() {
            if commonPhrases.contains(word.lowercased()) && index > 0 {
                return words[0..<index].joined(separator: " ")
            }
        }
        
        // Fallback to first 3 words
        return words.prefix(3).joined(separator: " ")
    }
    
    private func saveLoreObject() {
        print("💾 [ContentView] Attempting to save lore object...")
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ [ContentView] Cannot save - no image or failed to convert to data")
            return
        }
        
        print("📦 [ContentView] Creating new LoreObject in Core Data...")
        withAnimation {
            let newLoreObject = LoreObject(context: viewContext)
            newLoreObject.id = UUID()
            newLoreObject.imageData = imageData
            newLoreObject.loreText = generatedLore
            newLoreObject.objectName = currentObjectName.isEmpty ? nil : currentObjectName
            newLoreObject.timestamp = Date()
            
            print("💿 [ContentView] Saving to Core Data...")
            print("   - Object Name: \(currentObjectName)")
            print("   - Lore Length: \(generatedLore.count) characters")
            print("   - Image Size: \(imageData.count) bytes")
            
            do {
                try viewContext.save()
                print("✅ [ContentView] Successfully saved lore object to Core Data")
            } catch {
                print("❌ [ContentView] Failed to save to Core Data: \(error.localizedDescription)")
                alertMessage = "Failed to save lore object: \(error.localizedDescription)"
                showingAlert = true
            }
        }
        
        // Reset state
        print("🔄 [ContentView] Resetting app state...")
        selectedImage = nil
        generatedLore = ""
        currentObjectName = ""
        print("✅ [ContentView] App state reset complete")
    }
    
    private func deleteLoreObjects(offsets: IndexSet) {
        withAnimation {
            offsets.map { loreObjects[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                alertMessage = "Failed to delete lore object: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let onAddPressed: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "scroll")
                .font(.system(size: 80))
                .foregroundColor(.orange.opacity(0.6))
            
            Text("No Lore Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Take a photo of any object to discover its mystical backstory")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onAddPressed) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Start Creating Lore")
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                
                Text("Consulting the Ancient Texts...")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Generating your object's lore")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
