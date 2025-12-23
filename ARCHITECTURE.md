# TrustExpense Architecture Documentation

## Overview

TrustExpense is a Flutter mobile application for expense tracking with AI-powered receipt processing. The app uses a clean, layered architecture to separate concerns and make the codebase easy to understand and maintain.

## Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens, Widgets, UI Components)      │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│       Business Logic Layer              │
│    (Providers - State Management)       │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          Data Layer                     │
│  (Repositories - Data Access Logic)     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Service Layer                   │
│  (Supabase, OCR, AI, Storage)          │
└─────────────────────────────────────────┘
```

## Data Flow: Receipt Capture to Display

Here's how data flows through the app when a user captures a receipt:

```
1. USER ACTION
   └─> User taps camera button in UI
   
2. PRESENTATION LAYER
   └─> ReceiptCaptureScreen displays camera
   └─> User takes photo
   └─> Image displayed in ImagePreviewScreen
   
3. SERVICE LAYER - OCR
   └─> ImagePickerService gets image file
   └─> OCRService.extractText(image)
       └─> Google ML Kit processes image
       └─> Returns extracted text
   
4. SERVICE LAYER - AI Classification
   └─> AIClassificationService.classifyText(ocrText)
       └─> TensorFlow Lite model processes text
       └─> Returns category + confidence score
   
5. SERVICE LAYER - Storage
   └─> StorageService.uploadImage(image)
       └─> Uploads to Supabase Storage
       └─> Returns image URL
   
6. DATA LAYER
   └─> ReceiptRepository.createReceipt(data)
       └─> Creates Receipt model object
       └─> SupabaseService.insertReceipt(receipt)
           └─> Saves to PostgreSQL database
   
7. BUSINESS LOGIC LAYER
   └─> ReceiptProvider.addReceipt(receipt)
       └─> Updates app state
       └─> Notifies listeners
   
8. PRESENTATION LAYER
   └─> UI automatically rebuilds
   └─> Receipt appears in HistoryScreen
   └─> Summary updates with new data
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Root widget, Provider setup
│
├── core/                        # Core utilities and configuration
│   ├── constants/               # App-wide constants
│   │   ├── app_constants.dart   # General app constants
│   │   └── supabase_constants.dart  # Backend configuration
│   ├── theme/                   # App theming
│   │   ├── app_theme.dart       # Material theme definition
│   │   └── app_colors.dart      # Color palette
│   ├── utils/                   # Utility functions
│   │   ├── date_utils.dart      # Date formatting helpers
│   │   └── currency_utils.dart  # Currency formatting
│   └── errors/                  # Custom exceptions
│       └── exceptions.dart      # App-specific exceptions
│
├── data/                        # Data layer
│   ├── models/                  # Data models
│   │   ├── receipt_model.dart   # Receipt entity
│   │   └── monthly_summary_model.dart  # Summary entity
│   │
│   ├── repositories/            # Data access logic
│   │   ├── receipt_repository.dart     # Receipt CRUD operations
│   │   └── summary_repository.dart     # Summary queries
│   │
│   └── services/                # External service integrations
│       ├── supabase_service.dart       # Database operations
│       ├── storage_service.dart        # Image storage
│       ├── auth_service.dart           # Authentication
│       ├── ocr_service.dart            # Text recognition (ML Kit)
│       ├── ai_classification_service.dart  # Deep learning classification
│       └── image_picker_service.dart   # Camera/gallery access
│
├── presentation/                # Presentation layer
│   ├── providers/               # State management (Provider pattern)
│   │   ├── auth_provider.dart   # Auth state
│   │   ├── receipt_provider.dart  # Receipt state
│   │   └── summary_provider.dart  # Summary state
│   │
│   ├── screens/                 # Full-screen pages
│   │   ├── splash/              # Splash screen
│   │   ├── auth/                # Login/Register
│   │   ├── home/                # Home dashboard
│   │   ├── receipt/             # Receipt capture & edit
│   │   ├── history/             # Receipt list
│   │   └── summary/             # Monthly summary
│   │
│   └── widgets/                 # Reusable UI components
│       ├── charts/              # Chart widgets
│       │   └── category_pie_chart.dart
│       ├── common/              # Common widgets
│       └── receipt_card.dart    # Receipt list item
│
└── assets/                      # Static assets
    ├── images/                  # App images
    └── tflite/                  # AI model files
```

## Key Technologies

### Frontend
- **Flutter 3.9+**: Cross-platform mobile framework
- **Provider**: State management pattern
- **Material Design**: UI component library

### Backend
- **Supabase**: Backend-as-a-Service
  - PostgreSQL database for receipts
  - Storage for receipt images
  - Authentication for users

### AI/ML
- **Google ML Kit**: On-device OCR text recognition
- **TensorFlow Lite**: Deep learning for category classification

## State Management Pattern

The app uses the **Provider** pattern for state management:

### Provider Pattern Flow

```
┌─────────────┐
│   Widget    │  1. Widget needs data
└──────┬──────┘
       │
       │ 2. Reads from Provider
       ▼
┌─────────────┐
│  Provider   │  3. Provider holds state
└──────┬──────┘
       │
       │ 4. Provider calls Repository
       ▼
┌─────────────┐
│ Repository  │  5. Repository fetches data
└──────┬──────┘
       │
       │ 6. Returns data
       ▼
┌─────────────┐
│  Provider   │  7. Provider updates state
└──────┬──────┘
       │
       │ 8. notifyListeners()
       ▼
┌─────────────┐
│   Widget    │  9. Widget rebuilds with new data
└─────────────┘
```

### Example: Fetching Receipts

```dart
// 1. Widget requests data
final provider = Provider.of<ReceiptProvider>(context);
provider.loadReceipts();

// 2. Provider calls repository
class ReceiptProvider extends ChangeNotifier {
  Future<void> loadReceipts() async {
    _receipts = await _repository.getAllReceipts();
    notifyListeners();  // 3. Notify widgets to rebuild
  }
}

// 4. Repository calls service
class ReceiptRepository {
  Future<List<Receipt>> getAllReceipts() async {
    return await _supabaseService.fetchReceipts();
  }
}

// 5. Service queries database
class SupabaseService {
  Future<List<Receipt>> fetchReceipts() async {
    final data = await supabase.from('receipts').select();
    return data.map((json) => Receipt.fromJson(json)).toList();
  }
}
```

## Database Schema (Supabase)

### receipts table

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key (auto-generated) |
| user_id | UUID | Foreign key to auth.users |
| amount | DECIMAL | Receipt total amount |
| date | TIMESTAMP | Transaction date |
| merchant | TEXT | Store/vendor name |
| category | TEXT | Expense category (AI-predicted) |
| category_confidence | DECIMAL | AI confidence (0.0-1.0) |
| manual_override | BOOLEAN | User changed category? |
| image_url | TEXT | Supabase Storage URL |
| ocr_text | TEXT | Full OCR-extracted text |
| created_at | TIMESTAMP | Auto-generated |
| updated_at | TIMESTAMP | Auto-updated |

### monthly_summaries table

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | Foreign key to auth.users |
| month | DATE | Month (YYYY-MM-01) |
| total_amount | DECIMAL | Total spending |
| category_breakdown | JSONB | Category totals |
| receipt_count | INTEGER | Number of receipts |
| created_at | TIMESTAMP | Auto-generated |
| updated_at | TIMESTAMP | Auto-updated |

## Deep Learning Integration

### AI Classification Service

The app uses TensorFlow Lite for on-device deep learning:

1. **Input**: OCR-extracted text from receipt
2. **Processing**: Text → Feature extraction → Neural network → Category prediction
3. **Output**: Category name + confidence score

### Supported Categories

- Food & Dining
- Transportation
- Shopping
- Entertainment
- Bills & Utilities
- Other

### How It Works

```dart
// 1. Extract text from receipt image
final ocrText = await ocrService.extractText(imageFile);

// 2. Classify text using deep learning
final result = await aiService.classifyText(ocrText);

// 3. Get predicted category and confidence
final category = result['category'];        // e.g., "Food & Dining"
final confidence = result['confidence'];    // e.g., 0.85 (85% confident)

// 4. Save receipt with AI prediction
final receipt = Receipt(
  category: category,
  categoryConfidence: confidence,
  ocrText: ocrText,
  // ... other fields
);
```

## Error Handling

The app uses custom exceptions for clear error handling:

```dart
// Custom exceptions in core/errors/exceptions.dart
class OCRException extends AppException { }
class AIException extends AppException { }
class StorageException extends AppException { }
class DatabaseException extends AppException { }

// Usage in services
try {
  final text = await ocrService.extractText(image);
} catch (e) {
  if (e is OCRException) {
    // Handle OCR-specific error
    showError('Could not read receipt. Please try again.');
  }
}
```

## Development Guidelines

### Adding a New Feature

1. **Model**: Create/update data model in `data/models/`
2. **Service**: Add service method in `data/services/`
3. **Repository**: Add repository method in `data/repositories/`
4. **Provider**: Add state management in `presentation/providers/`
5. **UI**: Create screen/widget in `presentation/screens/` or `presentation/widgets/`

### Code Style

- **Comments**: Every class, method, and complex logic should have comments
- **Naming**: Use descriptive names (e.g., `fetchReceiptsByCategory` not `fetch`)
- **Async**: Always use `async/await` for asynchronous operations
- **Error Handling**: Use try-catch with specific exception types

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build for production
flutter build apk  # Android
flutter build ios  # iOS
```

## Configuration

Before running, update these files:

1. **lib/core/constants/supabase_constants.dart**
   - Add your Supabase project URL
   - Add your Supabase anon key

2. **assets/tflite/** (optional)
   - Add TensorFlow Lite model file if using custom model

## Summary

TrustExpense follows a clean, layered architecture that separates:
- **UI** (Presentation Layer)
- **State** (Business Logic Layer)
- **Data** (Data Layer)
- **Services** (Service Layer)

This makes the code:
- ✅ Easy to understand
- ✅ Easy to test
- ✅ Easy to modify
- ✅ Easy to maintain
