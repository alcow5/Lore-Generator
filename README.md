# 📜 Lore Generator

> Transform ordinary objects into extraordinary tales with AI-powered mystical lore generation

## 🌟 Overview

Lore Generator is an iOS app that uses computer vision and AI to create fantasy-style backstories for any object you photograph. Point your camera at everyday items and discover their hidden mystical origins!

## ✨ Features

- 📸 **Camera Integration**: Take photos directly or choose from photo library
- 🔮 **AI-Powered Lore**: Generate fantasy backstories using LLaVA vision-language model
- 📱 **Beautiful UI**: Fantasy-themed interface with scroll and star iconography
- 💾 **Local Storage**: Save and browse your collection of enchanted objects
- 🌙 **Privacy-First**: All data stored locally on your device

## 🏗️ Architecture

### Frontend (iOS/SwiftUI)
- **SwiftUI** interface with modern iOS design patterns
- **Core Data** for local storage of lore objects
- **PhotosPicker** and **UIImagePickerController** for image capture
- **Fantasy-themed UI** with custom styling and animations

### Backend Integration
- **HTTP API** communication with local LLaVA server
- **Multipart form uploads** for image processing
- **JSON response parsing** for lore text
- **Graceful error handling** with fallback mock responses

## 🔄 Backend Workflow

The Lore Generator API is a lightweight proxy service that orchestrates AI-powered lore generation through a multi-step process:

### 1. 📸 Image Upload (Mobile App)
The iOS app sends a multipart/form-data POST request containing a JPEG image to:
```
http://YOUR_SERVER_IP:3001/generate-lore
```

### 2. 🔍 Image Captioning (LLaVA)
The proxy receives the image and forwards it to a locally hosted LLaVA server:
```
http://YOUR_SERVER_IP:11434/api/generate
```
- Image is converted to base64 format
- Sent with prompt: *"Describe this image in vivid, creative detail."*
- LLaVA responds with a detailed caption

### 3. ✨ Lore Generation (LLM)
The caption is then processed through a fantasy lore prompt:
```
"Generate a fantasy item lore based on this description: [caption]"
```
- Produces stylized fantasy-style stories and item descriptions
- Creates mystical backstories for ordinary objects

### 4. 📱 Response (Back to App)
The final lore is returned to the iOS app as JSON:
```json
{
  "lore": "In the heart of the Elderwood Forest, this ancient artifact..."
}
```

## 🛠️ Backend Technologies

- **Backend Framework**: FastAPI (Python)
- **Image Captioning**: LLaVA (Locally hosted vision-language model)
- **Lore Generation**: LLM (Qwen-1.5, LLaMA, or other GGUF-compatible models)
- **Networking**: URLSession in Swift with multipart/form-data
- **Image Processing**: Base64 encoding for API communication

## 🛠️ Technical Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI + UIKit bridges
- **Database**: Core Data
- **Networking**: URLSession with async/await
- **Image Processing**: UIImage + JPEG compression
- **Deployment**: iOS 16.0+

## 📱 Key Components

### Core Files
- `ContentView.swift` - Main interface and navigation
- `LoreService.swift` - Network service for API communication
- `ImagePicker.swift` - Camera and photo library integration
- `LoreDisplayView.swift` - Fantasy-themed lore presentation
- `Persistence.swift` - Core Data stack management

### Data Model
```swift
LoreObject {
    id: UUID
    imageData: Data
    loreText: String
    objectName: String?
    timestamp: Date
}
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ device or simulator
- LLaVA server running at specified IP (for real AI generation)

### Setup
1. Clone the repository
2. **Configure Server IP**: Replace `YOUR_SERVER_IP` in these files with your actual server IP:
   - `Lore Generator/LoreService.swift` (line 12)
   - `Lore Generator/Lore-Generator-Info.plist` (in NSExceptionDomains)
3. Open `Lore Generator.xcodeproj` in Xcode
4. Configure your target device
5. Build and run!

### Backend Server Setup
For full AI functionality, deploy the complete backend stack:

#### 1. FastAPI Proxy Server
```bash
# Deploy FastAPI proxy server at YOUR_SERVER_IP:3001
# Handles image upload and orchestrates AI pipeline
```

#### 2. LLaVA Vision Model
```bash
# Configure LLaVA model endpoint at YOUR_SERVER_IP:11434
# Provides image captioning capabilities
```

#### 3. Language Model (LLM)
```bash
# Set up GGUF-compatible model (Qwen-1.5, LLaMA, etc.)
# Generates fantasy lore from captions
```

#### 4. Configuration
- Replace `YOUR_SERVER_IP` with your actual server IP address in both:
  - `LoreService.swift` (iOS app)
  - `Info.plist` (ATS configuration)
- Ensure all services are accessible on local network
- Verify port 3001 (API) and 11434 (LLaVA) are open

## 🔒 Privacy & Security

### iOS Permissions
- **Camera Permission**: Required for photo capture
- **Photo Library Permission**: Required for image selection  
- **No Data Collection**: All processing happens locally or on your specified server

### Network Security
The API uses HTTP (not HTTPS) for local network communication. iOS requires explicit configuration to allow HTTP traffic:

#### App Transport Security (ATS) Configuration
Required in `Info.plist` to enable HTTP connections to local server:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>YOUR_SERVER_IP</key>
    <dict>
      <key>NSExceptionAllowsInsecureHTTPLoads</key>
      <true/>
      <key>NSIncludesSubdomains</key>
      <true/>
      <key>NSExceptionRequiresForwardSecrecy</key>
      <false/>
    </dict>
  </dict>
</dict>
```

#### Security Notes
- ⚠️ **HTTP Only**: Suitable for local network development
- 🏠 **Local Network**: All communication stays within your network
- 🔒 **No External Data**: Images and lore remain on your devices/servers
- 🛡️ **Privacy-First**: No telemetry or data collection

## 🎨 Design Philosophy

The app embraces a **fantasy aesthetic** with:
- 🧙‍♂️ Mystical loading messages ("Consulting the Ancient Texts...")
- 📜 Scroll-based visual metaphors
- ⭐ Star iconography for favorites and highlights
- 🎨 Warm color palette with orange accents
- 🌙 Dark mode compatibility

## 📝 Development Notes

### Logging
Comprehensive logging is implemented throughout the app for debugging:
- 🎯 User interaction tracking
- 📸 Image processing pipeline
- 🌐 Network request/response cycles
- 💾 Core Data operations
- 🔄 State management transitions

### Error Handling
- Graceful degradation with mock responses during development
- User-friendly error messages
- Automatic retry mechanisms for network failures
- Comprehensive input validation

## 🤝 Contributing

This is a personal project, but suggestions and improvements are welcome!

## 📄 License

This project is for educational and personal use.

---

*Built with ❤️ and a touch of magic ✨* 