# TrustExpense

**Privacy-first expense tracking with AI-powered receipt processing**

## Overview

TrustExpense is a Flutter mobile application that helps users track expenses by capturing receipt photos and automatically extracting information using OCR and deep learning.

### Key Features

- ** Receipt Capture**: Take photos of receipts using camera or gallery
- ** OCR Text Extraction**: On-device text recognition using Google ML Kit
- ** AI Category Classification**: Deep learning model classifies expenses automatically
- ** Cloud Storage**: Secure data storage with Supabase (PostgreSQL + Storage)
- ** Spending Summaries**: View monthly spending with category breakdowns
- ** Clean UI**: Simple, easy-to-use Material Design interface

## How It Works

```
1. Capture Receipt Photo
   ↓
2. OCR Extracts Text (Google ML Kit)
   ↓
3. AI Classifies Category (TensorFlow Lite)
   ↓
4. Save to Database (Supabase)
   ↓
5. View in History & Summary
```

## Tech Stack

### Frontend
- **Flutter 3.9+**: Cross-platform mobile framework
- **Provider**: State management
- **Material Design**: UI components

### Backend
- **Supabase**: Backend-as-a-Service
  - PostgreSQL database
  - File storage
  - Authentication

### AI/ML
- **Google ML Kit**: On-device OCR text recognition
- **TensorFlow Lite**: Deep learning for expense classification

## Expense Categories

The AI model classifies receipts into these categories:
-  Food & Dining
-  Transportation
-  Shopping
-  Entertainment
-  Bills & Utilities
-  Other

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Root widget, providers
├── core/                     # Constants, theme, utilities
├── data/                     # Models, repositories, services
│   ├── models/               # Data models (Receipt, Summary)
│   ├── repositories/         # Data access logic
│   └── services/             # Supabase, OCR, AI, Storage
└── presentation/             # UI layer
    ├── providers/            # State management
    ├── screens/              # App screens
    └── widgets/              # Reusable components
```

For detailed architecture documentation, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Android Studio / VS Code
- Supabase account (free tier available)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/sara0411/TrustExpense.git
cd TrustExpense
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Supabase**
   - Create a free Supabase project at [supabase.com](https://supabase.com)
   - Get your project URL and anon key
   - Update `lib/core/constants/supabase_constants.dart`:
   ```dart
   class SupabaseConstants {
     static const String supabaseUrl = 'YOUR_PROJECT_URL';
     static const String supabaseAnonKey = 'YOUR_ANON_KEY';
   }
   ```

4. **Set up database**
   - Run the SQL schema in Supabase SQL Editor (see `database_schema.sql`)
   - This creates the `receipts` and `monthly_summaries` tables

5. **Run the app**
```bash
flutter run
```

## Code Documentation

The codebase is extensively commented to make it easy to understand:

- **File-level comments**: Explain the purpose of each file
- **Class-level comments**: Describe what each class does
- **Method-level comments**: Detail what each function does and how
- **Inline comments**: Clarify complex logic

Example:
```dart
/// OCR (Optical Character Recognition) Service
/// 
/// This service handles text extraction from receipt images using Google ML Kit.
/// ML Kit provides on-device text recognition, meaning all processing happens
/// locally on the user's phone without sending data to external servers.
class OCRService {
  // ... implementation
}
```

## Deep Learning Integration

The app uses TensorFlow Lite for on-device deep learning:

### How AI Classification Works

1. **Input**: OCR-extracted text from receipt
2. **Feature Extraction**: Convert text to numerical features
3. **Neural Network**: Process features through model layers
4. **Output**: Predicted category + confidence score

### Example
```dart
// Extract text from receipt
final text = await ocrService.extractText(imageFile);

// Classify using deep learning
final result = await aiService.classifyText(text);

// Get prediction
print(result['category']);     // "Food & Dining"
print(result['confidence']);   // 0.85 (85% confident)
```

## Development Status

Current Version: **1.0.0** (Simplified for Presentation)

### Completed Features
-  Receipt capture (camera/gallery)
-  OCR text extraction
-  AI category classification
-  Supabase integration
-  Receipt history
-  Monthly summaries
-  Category breakdown charts
## License

Private project - All rights reserved

## Contact

For questions or support, please contact the collaborators saraferraa0@gmail.com OR hajarafdelsemlali@gmail.com

---

**Note**: This is an educational project demonstrating Flutter development, OCR integration, and deep learning for mobile applications.
