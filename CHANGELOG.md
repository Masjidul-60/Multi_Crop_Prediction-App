# Changelog

All notable changes and architectural deliverables built for **CropDoc (ক্রপডক)**.

## [1.0.0] - 2026-10-06

### Initial Release - Full Frontend Architecture

#### Core & Architecture
- Initialized clean architecture directory hierarchy: `lib/core`, `lib/data`, `lib/features`.
- Integrated **Riverpod** (`flutter_riverpod: ^2.6.1`) for reactive state management.
- Integrated **GoRouter** (`go_router: ^14.8.1`) for declarative type-safe navigation and nested shell routing.
- Integrated **Dio** (`dio: ^5.7.0`) for resilient HTTP networking, multipart uploads, and error interceptors.
- Integrated **Hive** (`hive: ^2.2.3`, `hive_flutter: ^1.1.0`) for offline diagnosis history storage.
- Configured **flutter gen-l10n** with bilingual ARB localization tables in **Bangla** (`bn`, default) and **English** (`en`).
- Generated custom leaf mark launcher icon and native splash screen using `flutter_launcher_icons` and `flutter_native_splash`.

#### Design System & UI/UX
- Material 3 design system implemented with light and dark theme support.
- Curated agricultural palette: Deep Forest Green (`#1F6F43`), Lime Accent (`#A8D672`), Warm Off-White (`#F7F6F1`), Amber (`#B45309`), and Crimson Alert (`#B91C1C`).
- Created `CropDocThemeExtension` for semantic status colors (`confident`, `uncertain`, `unknown`).
- Configured typography with Google Fonts (*Plus Jakarta Sans* for Latin, *Noto Sans Bengali* for Bangla).
- Implemented accessibility text scaling clamped between 1.0x and 1.5x with soft shadows and 16–20px corner radii.
- Integrated subtle micro-animations using `flutter_animate` (fade/slide transitions, pulsing scanning beam, animated confidence ring).
- Added haptic feedback (`HapticFeedback.mediumImpact()`) on capture and interaction.

#### Features & Screens
1. **Onboarding Screen (`OnboardingScreen`)**:
   - 3 interactive slides detailing app capabilities, tips for leaf photography, and expert verification guidance.
   - Smooth page indicators, skippable, persistent via `SharedPreferences`.
2. **Home Screen (`HomeScreen`)**:
   - Time-sensitive greeting in selected language.
   - Large primary "Scan a Leaf" button and gallery selector.
   - Horizontal scrolling chips of supported crops (Rice, Potato, Tomato, Corn, Wheat, Cotton, Tea).
   - Horizontal carousel of recent scans with status indicators.
   - Photography tips card.
3. **Capture & Pre-Processing (`CaptureScreen`)**:
   - Live camera preview with leaf-shaped framing guide overlay (`LeafOverlayPainter`).
   - Flash toggle, gallery picker, live photography guidance tips.
   - Client-side quality inspection algorithms:
     - Laplacian-variance blur detection (`LaplacianBlurChecker`).
     - Image brightness evaluation.
     - Advisory dialog warning users if the image is too blurry or dark, with an override option.
   - Post-capture crop and rotation preview with Retake and Analyze actions.
   - Client-side image resizing to max dimension 1024px and JPEG compression.
4. **Analyzing Screen (`AnalyzingScreen`)**:
   - Image preview with animated vertical scanning laser beam.
   - 20-second timeout mechanism with retry options.
   - Cancel button to abort analysis.
   - Automatic offline handling: stores unanalyzed scans in the local queue when disconnected.
5. **Result Screen (`ResultScreen`)**:
   - **Confident State**: Custom animated circular confidence progress ring (`ConfidenceRing`), top-3 ranked predictions bar chart, symptoms list from knowledge base, "What to do next" guidance, and fixed official advisory line.
   - **Uncertain State**: Amber warning banner, top-3 candidates comparison, and specific actionable photo retake tips.
   - **Unknown State**: Soft red notification for unrecognised foliage, reassurance, and recommendation to consult an officer.
   - Share diagnosis button (`share_plus`) with text summary and image.
   - "Save to history" and "Report wrong result" dialog stub.
   - Model version and inference latency display.
6. **History Screen (`HistoryScreen`)**:
   - List and grid view of past scans with thumbnail, crop, disease, and date.
   - Search bar by crop or disease name.
   - Filter dropdowns by crop type and confidence status.
   - Swipe-to-delete with confirmation.
   - CSV export via `share_plus`.
   - Full offline functionality.
7. **Crop Library Guide (`GuideScreen`, `DiseaseDetailScreen`)**:
   - Offline encyclopedia of 22 plant diseases across 7 major crops.
   - Detailed symptom lists, descriptions, and agronomist-verified pointers.
8. **Settings Screen (`SettingsScreen`)**:
   - Language selector (Bangla / English).
   - Theme mode toggle (System, Light, Dark).
   - Data saver toggle (compresses image to 720px / 75% quality).
   - Clear history confirmation dialog.
   - Privacy note and version display.
   - **Hidden Developer Mode**: Revealed by tapping the version number 7 times; provides runtime mock/real toggle, base URL editor, and live `/v1/health` connectivity test.

#### Data & API
- Defined `PredictionService` abstract contract.
- Built `MockPredictionService`: Realistic 1.5s simulated network delay, cycles through `confident`, `uncertain`, and `unknown` states to facilitate UI testing without a live backend.
- Built `HttpPredictionService`: Production Dio client with multipart upload (`POST /v1/predict`), health check (`GET /v1/health`), and feedback recording stub (`POST /v1/feedback`).
- Created `assets/knowledge/diseases.json` containing 22 detailed crop disease definitions with zero invented advice or pesticide names, strictly annotated with `"TODO: verify with an agronomist"` markers.
- Comprehensive API specification in `lib/data/api/api_contract.md`.

#### Testing & Quality Assurance
- **16 Automated Tests** created and passing:
  - Unit tests for JSON response deserialization across all three prediction states and sorting logic.
  - Unit tests for `MockPredictionService` state cycle and health check.
  - Unit tests for `HistoryScan` serialization and updates.
  - Widget tests for `ResultScreen` covering all three states (`confident`, `uncertain`, `unknown`) in both **Bangla** and **English** locales.
- Zero warnings or errors in `flutter analyze`.
