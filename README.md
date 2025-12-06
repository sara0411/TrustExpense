# TrustExpense

Privacy-first expense tracking with blockchain certification.

## Overview

TrustExpense is a Flutter mobile application that allows users to:
- Capture receipt photos and extract data using on-device OCR
- Automatically classify expenses using local AI
- Store data securely in Firebase
- Generate monthly summaries with blockchain certification
- Export professional PDF reports

## Features

- **On-Device OCR**: Google ML Kit for text recognition
- **Local AI Classification**: TensorFlow Lite model
- **Firebase Backend**: Firestore, Storage, and Authentication
- **Blockchain Certification**: Polygon Mumbai testnet
- **PDF Reports**: With QR code verification

## Tech Stack

- **Frontend**: Flutter 3.9+
- **OCR**: Google ML Kit
- **AI**: TensorFlow Lite
- **Backend**: Firebase (Firestore, Storage, Auth)
- **Blockchain**: Polygon Mumbai (Web3)
- **State Management**: Provider
- **Dependency Injection**: GetIt

## Project Structure

```
lib/
├── core/
│   ├── constants/     # App, Firebase, and blockchain constants
│   ├── theme/         # App theme and colors
│   ├── utils/         # Utility functions
│   └── errors/        # Custom exceptions
├── data/
│   ├── models/        # Data models
│   ├── repositories/  # Business logic
│   └── services/      # Firebase, OCR, AI, blockchain services
├── presentation/
│   ├── screens/       # UI screens
│   ├── widgets/       # Reusable widgets
│   └── providers/     # State management
└── assets/
    ├── images/        # App images
    └── tflite/        # AI models
```

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Android Studio / VS Code
- Firebase account
- Polygon Mumbai testnet wallet

### Installation

1. Clone the repository:
```bash
git clone https://github.com/sara0411/TrustExpense.git
cd TrustExpense
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a Firebase project
   - Download `google-services.json` (Android)
   - Place in `android/app/`

4. Run the app:
```bash
flutter run
```

## Development Roadmap

- [x] Sprint 1.1: Project Setup
- [ ] Sprint 1.2: Authentication
- [ ] Sprint 1.3: Basic Navigation
- [ ] Phase 2: OCR & Receipt Capture
- [ ] Phase 3: AI Classification
- [ ] Phase 4: History & Management
- [ ] Phase 5: Monthly Summary & Charts
- [ ] Phase 6: Blockchain Integration
- [ ] Phase 7: PDF Export & QR
- [ ] Phase 8: Polish & Testing
- [ ] Phase 9: Deployment

## Version

Current Version: 1.0.0 (MVP in development)

## License

Private project - All rights reserved

## Contact

For questions or support, please contact the development team.
