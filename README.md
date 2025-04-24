# Scandroid

Scandroid is a Flutter-based document scanner app powered by Google ML Kit. It captures, extracts text from, and organizes documents with intelligent features.

## Features
- Document scanning with OCR text extraction
- Smart tagging and categorization
- Biometric security
- Offline-first with local storage
- Powerful search functionality
- Modern, intuitive interface

## Project Overview

Scandroid is a document scanning and management app built with Flutter. Here's a quick rundown of what it does and how it works:

### Main Features
- Document scanning using your phone's camera
- Text extraction (OCR) from documents using Google ML Kit
- Document organization with folders and tags
- Search functionality to find documents quickly
- Biometric authentication for security

### Technical Implementation

#### Architecture
The app follows a standard Flutter project structure with:
1. **Models** - Data structures for documents and related entities
2. **Providers** - State management using the Provider pattern
3. **Screens** - UI components for different app views
4. **Services** - Core functionality like OCR and authentication
5. **Widgets** - Reusable UI components

#### Key Technologies
- **Flutter** - Cross-platform UI framework
- **Google ML Kit** - For OCR text extraction
- **Hive** - Local database for offline storage
- **Provider** - State management solution
- **Local Auth** - For biometric authentication

#### Core Workflow
1. Users scan documents using the camera
2. Google ML Kit extracts text from the images
3. The app suggests tags and categorization based on content
4. Documents are stored locally with Hive database
5. Users can search, view, and organize their documents

The app uses a responsive UI with a modern material design, making document management intuitive across different device sizes.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```
lib/
├── main.dart
├── models/
│   └── document.dart
├── screens/
│   ├── home_screen.dart
│   ├── scanner_screen.dart
│   ├── document_view_screen.dart
├── widgets/
│   └── scanner_button.dart
├── services/
│   ├── ocr_service.dart
│   ├── local_db_service.dart
│   └── biometric_service.dart
├── utils/
│   └── permissions.dart
└── providers/
    └── document_provider.dart
```

