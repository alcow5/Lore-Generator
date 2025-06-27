//
//  LoreService.swift
//  Lore Generator
//
//  Created by Alex on 6/26/25.
//

import Foundation
import UIKit

class LoreService: ObservableObject {
    private let baseURL = "http://YOUR_SERVER_IP:3001" // Replace YOUR_SERVER_IP with your actual server IP
    
    struct LoreResponse: Codable {
        let lore: String
    }
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func generateLore(for image: UIImage) async throws -> String {
        print("🖼️ [LoreService] Converting image to JPEG data...")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ [LoreService] Failed to convert image to JPEG data")
            throw LoreError.imageConversionFailed
        }
        print("✅ [LoreService] Image converted to JPEG (\(imageData.count) bytes)")
        
        return try await generateLore(from: imageData)
    }
    
    private func generateLore(from imageData: Data) async throws -> String {
        print("🚀 [LoreService] Starting lore generation process...")
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        print("⏳ [LoreService] Loading state set to true")
        
        defer {
            Task { @MainActor in
                isLoading = false
                print("⏹️ [LoreService] Loading state set to false")
            }
        }
        
        guard let url = URL(string: "\(baseURL)/generate-lore") else {
            print("❌ [LoreService] Invalid URL: \(baseURL)/generate-lore")
            throw LoreError.invalidURL
        }
        print("🌐 [LoreService] Target URL: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        print("📝 [LoreService] Created multipart request with boundary: \(boundary)")
        
        let body = createMultipartBody(imageData: imageData, boundary: boundary)
        request.httpBody = body
        print("📦 [LoreService] Created request body (\(body.count) bytes)")
        
        do {
            print("📡 [LoreService] Sending request to server...")
            let (data, response) = try await URLSession.shared.data(for: request)
            print("📨 [LoreService] Received response")
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📋 [LoreService] HTTP Status Code: \(httpResponse.statusCode)")
                guard httpResponse.statusCode == 200 else {
                    print("❌ [LoreService] Server error with status: \(httpResponse.statusCode)")
                    throw LoreError.serverError(httpResponse.statusCode)
                }
            }
            
            print("🔍 [LoreService] Parsing JSON response (\(data.count) bytes)")
            let loreResponse = try JSONDecoder().decode(LoreResponse.self, from: data)
            print("✨ [LoreService] Successfully generated lore: \(loreResponse.lore.prefix(50))...")
            return loreResponse.lore
            
        } catch {
            print("💥 [LoreService] Error occurred: \(error)")
            
            // Try mock response as fallback for development
            #if DEBUG
            if error.localizedDescription.contains("App Transport Security") {
                print("🔒 [LoreService] ATS blocking detected - using mock response")
                let mockLore = "In the depths of the ancient Elderwood Forest, this mystical artifact was forged by the legendary Moonsmith during the Great Convergence. Legend speaks of its power to reveal hidden truths and illuminate the path of destiny for those brave enough to wield it."
                print("✨ [LoreService] Mock lore generated as fallback")
                return mockLore
            } else if error.localizedDescription.contains("could not connect") || error.localizedDescription.contains("network") {
                print("🌐 [LoreService] Network/server error - using mock response")
                print("   Make sure your LLaVA server is running at \(baseURL)")
                let mockLore = "In the depths of the ancient Elderwood Forest, this mystical artifact was forged by the legendary Moonsmith during the Great Convergence. Legend speaks of its power to reveal hidden truths and illuminate the path of destiny for those brave enough to wield it."
                print("✨ [LoreService] Mock lore generated as fallback")
                return mockLore
            }
            #endif
            
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    private func createMultipartBody(imageData: Data, boundary: String) -> Data {
        var body = Data()
        
        let lineBreak = "\r\n"
        
        // Add image data
        body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)".data(using: .utf8)!)
        body.append(imageData)
        body.append("\(lineBreak)".data(using: .utf8)!)
        
        // End boundary
        body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
        
        return body
    }
}

enum LoreError: LocalizedError {
    case imageConversionFailed
    case invalidURL
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image to data"
        case .invalidURL:
            return "Invalid server URL"
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
} 