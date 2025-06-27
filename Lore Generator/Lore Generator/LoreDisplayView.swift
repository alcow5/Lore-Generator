//
//  LoreDisplayView.swift
//  Lore Generator
//
//  Created by Alex on 6/26/25.
//

import SwiftUI

struct LoreDisplayView: View {
    let image: UIImage
    let loreText: String
    let objectName: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Display
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    // Object Name (if available)
                    if let objectName = objectName {
                        Text(objectName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    // Lore Container
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "scroll")
                                .foregroundColor(.orange)
                            Text("Ancient Lore")
                                .font(.headline)
                                .foregroundColor(.orange)
                            Spacer()
                        }
                        
                        Text(loreText)
                            .font(.body)
                            .lineSpacing(6)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Object Lore")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Lore History Item View
struct LoreHistoryItemView: View {
    let loreObject: LoreObject
    @State private var showingDetail = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let imageData = loreObject.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(loreObject.objectName ?? "Unknown Object")
                    .font(.headline)
                    .lineLimit(1)
                
                Text(loreObject.loreText?.prefix(100) ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if let timestamp = loreObject.timestamp {
                    Text(timestamp, formatter: itemFormatter)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            if let imageData = loreObject.imageData,
               let uiImage = UIImage(data: imageData),
               let loreText = loreObject.loreText {
                LoreDisplayView(
                    image: uiImage,
                    loreText: loreText,
                    objectName: loreObject.objectName
                )
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}() 
