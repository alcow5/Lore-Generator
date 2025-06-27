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

### API Specification
```
Endpoint: http://100.75.161.47:3001/generate-lore
Method: POST
Content-Type: multipart/form-data
Form Field: file (image)

Response: 
{
  "lore": "In the mystical realm of ancient wisdom..."
}
```

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
2. Open `Lore Generator.xcodeproj` in Xcode
3. Configure your target device
4. Build and run!

### Server Setup (Optional)
For full AI functionality, set up the LLaVA backend:
1. Deploy Node.js proxy server at `100.75.161.47:3001`
2. Configure LLaVA model endpoint at `localhost:11434`
3. Update IP address in `LoreService.swift` if needed

## 🔒 Privacy & Security

- **Camera Permission**: Required for photo capture
- **Photo Library Permission**: Required for image selection  
- **No Data Collection**: All processing happens locally or on your specified server
- **App Transport Security**: Configured for local development server access

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