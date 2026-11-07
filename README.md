# CropDoc (ক্রপডক) — Mobile Plant Disease Diagnosis App

CropDoc is an offline-first, professional Flutter mobile application designed for farmers and agricultural workers. CropDoc allows farmers to photograph an affected crop leaf and receive instant recognition of the crop type, disease classification, symptoms, and actionable next steps.

---

## 🌟 Key Features

- **📸 Leaf Photography & Camera Capture**:
  - Custom camera interface with leaf-shaped framing guide overlay.
  - Flashlight toggle, live photography guidance tips ("One leaf • Fill frame • Bright light • Avoid shadows").
  - Client-side quality inspection before upload: Laplacian-variance blur detection and brightness thresholding warning dialog with user override.
  - Client-side image resizing and JPEG compression (max side 1024px, target size ~200–300 KB) for fast low-bandwidth uploads.

- **🔬 Three Clear Diagnosis States**:
  - **Confident (`status: confident`)**: Displays crop and disease name, animated confidence score ring, top-3 ranked predictions bar chart, detailed symptoms, and agronomic guidance.
  - **Uncertain (`status: uncertain`)**: Amber warning card displaying top candidate possibilities and clear advice on how to take a clearer photograph.
  - **Unknown (`status: unknown`)**: Red notice indicating an unrecognised leaf or out-of-distribution foliage, advising not to spray unnecessarily and to consult an expert.
  - **Fixed Official Advisory**: Always displays *"Confirm with a local agricultural extension officer before spraying anything."* on every diagnosis.

- **🌐 Dual Backend Strategy (Mock & Real)**:
  - Works immediately out of the box with a built-in `MockPredictionService` that simulates realistic 1.5s network delay and cycles through confident, uncertain, and unknown cases.
  - Easily switched to a production backend (`HttpPredictionService`) via configuration or the hidden developer options.

- **🛠 Hidden Developer Toggle**:
  - Tap the version number on the **Settings** screen **7 times** to unlock Developer Options.
  - Toggle between Mock and Live API at runtime without rebuilding the app.
  - Live Base URL editor with one-tap `/v1/health` connectivity test.

- **💾 Offline-First History & Queuing**:
  - Local scan history backed by Hive.
  - Search and filter scans by crop type and confidence status.
  - Swipe-to-delete past scans.
  - Export diagnosis records to CSV via `share_plus`.
  - Offline upload queue: saves scans when the device is disconnected and notifies the user.

- **📖 Offline Crop Library (Guide)**:
  - Browse all supported crops (Rice, Potato, Tomato, Corn, Wheat, Cotton, Tea) and their diseases offline with localized descriptions and symptoms.

- **🌏 Bilingual Support**:
  - Full localization in **Bangla** (`bn`, default) and **English** (`en`) via `flutter gen-l10n`.
  - Knowledge base (`assets/knowledge/diseases.json`) localized in both languages.

- **🎨 Agricultural Material 3 Design System**:
  - Deep green primary (`#1F6F43`), fresh lime accent (`#A8D672`), warm off-white background (`#F7F6F1`).
  - Google Fonts: *Plus Jakarta Sans* (Latin) & *Noto Sans Bengali* (Bangla).
  - Light and Dark modes.
  - Accessible typography with text scaling clamped up to 1.5x without overflow.

---

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK 3.22.0 or higher (Tested with Flutter 3.41.0)
- Android SDK (API 34+ recommended, minSdk 21)
- Java 17 / Gradle

### Installation Steps

1. Navigate to the project directory:
   ```bash
   cd cropdoc_app
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Generate localization files (already configured via `l10n.yaml`):
   ```bash
   flutter gen-l10n
   ```

4. Verify code cleanliness:
   ```bash
   flutter analyze
   flutter test
   ```

---

## 📱 How to Run on a Phone

### 1. Physical Android Device
1. Enable **Developer Options** and **USB Debugging** on your Android smartphone.
2. Connect your device via USB.
3. Verify device recognition:
   ```bash
   flutter devices
   ```
4. Run the app:
   ```bash
   flutter run -d <device-id>
   ```

### 2. Building a Debug APK
To build an APK file for direct installation:
```bash
flutter build apk --debug
```
The generated APK will be located at:
```
build/app/outputs/flutter-apk/app-debug.apk
```
Copy this APK to your phone and install it directly.

### Required Permissions
- **Camera (`android.permission.CAMERA`)**: For taking photos of leaves.
- **Internet (`android.permission.INTERNET`)**: For communicating with the prediction backend.
- **Network State (`android.permission.ACCESS_NETWORK_STATE`)**: For detecting offline/online connectivity.
- **Photo Library**: For selecting images from the device gallery.

Permissions are handled gracefully at runtime with rationale dialogs and settings fallbacks.

---

## 🔄 How to Switch Between Mock and Real Backend

### Run the included PyTorch model backend

The project includes a local inference service for `best.pt` (`e3_full`, epoch
8) and its matching 59-class `ood_stats.pt` file. From the project root:

```powershell
python -m pip install -r backend/requirements.txt
python backend/server.py
```

In the Android emulator, use `http://10.0.2.2:8000` as the API URL. For a
physical phone, use the computer's LAN IP and keep both devices on the same
network. Then turn off mock predictions in Developer Options and run the
server health check. Details are in [backend/README.md](backend/README.md).

The supplied checkpoint does not contain the human-readable disease
`class_to_idx` list. The backend therefore returns crop plus `class_00` to
`class_58`, and keeps non-OOD results as uncertain instead of displaying an
unverified disease name or treatment advice. Its in-domain evaluation is much
stronger than its cross-dataset result; use it as an experimental aid.

There are **two ways** to switch between the mock service and a live AI backend:

### Option A: At Runtime via Hidden Developer Options (No Rebuild)
1. Open the CropDoc app.
2. Tap the **Settings** tab (gear icon in bottom navigation).
3. Scroll down to the **About & Version** section.
4. **Tap the version number 7 times quickly**.
5. A green toast *"Developer Mode unlocked"* will appear, revealing the **Developer Options** card.
6. Toggle **"Use Mock Prediction Service"** OFF.
7. Enter your backend URL (e.g., `http://192.168.1.100:8000` or `https://api.cropdoc.org`).
8. Tap **"Test Server Health"** to verify the `/v1/health` endpoint.
9. Settings are saved permanently in `SharedPreferences`.

### Option B: Compile-Time Configuration
Open `lib/core/config.dart` and modify:
```dart
class AppConfig {
  // Set to false to use the live backend by default
  static const bool defaultUseMock = false;

  // Set your default backend server URL
  static const String defaultBaseUrl = 'https://api.cropdoc.example.com';
}
```

---

## 🌾 How to Add a Crop to `assets/knowledge/diseases.json`

The offline knowledge base is stored in [assets/knowledge/diseases.json](assets/knowledge/diseases.json).

### 1. Add the JSON Entry
Add a new object keyed by `"crop/disease"`:
```json
"wheat/yellow_rust": {
  "crop": "wheat",
  "disease": "yellow_rust",
  "crop_name_bn": "গম",
  "crop_name_en": "Wheat",
  "disease_name_bn": "হলুদ মরিচা রোগ",
  "disease_name_en": "Yellow Rust (Stripe Rust)",
  "description_bn": "পাতায় সমান্তরাল হলুদ রেখার মতো ছোট ছোট গুটির সারি তৈরি হয়।",
  "description_en": "Bright yellow pustules arranged in linear stripes along leaf veins.",
  "symptoms_bn": [
    "পাতার শিরা বরাবর সমান্তরাল হলুদ দাগের সারি",
    "স্পর্শ করলে হলুদ গুঁড়ার মতো রেণু বের হওয়া"
  ],
  "symptoms_en": [
    "Linear stripes of bright yellow powdery pustules",
    "Yellow spore dust dislodges easily when touched"
  ],
  "what_to_do_bn": [
    "আক্রান্ত অংশ চিহ্নিত করে বিচ্ছিন্ন করুন",
    "সহনশীল জাতের গম চাষের ব্যবস্থা নিন",
    "TODO: verify with an agronomist"
  ],
  "what_to_do_en": [
    "Identify and isolate early hotspots",
    "Plant rust-resistant cultivars in subsequent seasons",
    "TODO: verify with an agronomist"
  ]
}
```

> **Important**: Do not invent chemical fungicides or doses. Always include the `"TODO: verify with an agronomist"` marker for specialist verification.

### 2. Register the Crop in Supported Crops List
In [lib/core/config.dart](lib/core/config.dart), add the crop identifier to `supportedCrops` if it is a new crop:
```dart
static const List<String> supportedCrops = [
  'rice',
  'potato',
  'tomato',
  'corn',
  'wheat',
  'cotton',
  'tea',
];
```

---

## 📡 API Contract

The full API contract specification is also documented in [lib/data/api/api_contract.md](lib/data/api/api_contract.md).

### 1. Prediction Endpoint
- **URL**: `POST {BASE_URL}/v1/predict`
- **Content-Type**: `multipart/form-data`
- **Request Body**:
  - `image`: JPEG binary file (max dimension 1024px, auto-resized client-side).

#### Success Response (200 OK)
```json
{
  "request_id": "req-94812f8a-c603-4f92-bd92",
  "crop": {
    "name": "rice",
    "confidence": 0.96
  },
  "predictions": [
    {
      "label": "rice/blast",
      "crop": "rice",
      "disease": "blast",
      "confidence": 0.92
    },
    {
      "label": "rice/brown_spot",
      "crop": "rice",
      "disease": "brown_spot",
      "confidence": 0.05
    },
    {
      "label": "rice/bacterial_leaf_blight",
      "crop": "rice",
      "disease": "bacterial_leaf_blight",
      "confidence": 0.02
    }
  ],
  "status": "confident",
  "reasons": [],
  "model_version": "v1.2.0-mobilenetv3-plantnet",
  "inference_ms": 138
}
```

#### Status Enum Values
- `"confident"`: Model has high confidence in the top classification.
- `"uncertain"`: Multiple competing diagnoses or low softmax probability.
- `"unknown"`: Non-leaf foliage, out-of-distribution background, or unrecognizable specimen.

#### Error Responses
- `400 Bad Request`: Invalid image payload or corrupt file.
- `413 Payload Too Large`: Image file exceeds server limits.
- `422 Unprocessable Entity`: No plant leaf detected in the image.
- `500 Internal Server Error`: Backend inference server error.

### 2. Health Check Endpoint
- **URL**: `GET {BASE_URL}/v1/health`
- **Response (200 OK)**:
```json
{
  "status": "ok",
  "model_version": "v1.2.0-mobilenetv3-plantnet"
}
```

### 3. Feedback Endpoint (Stub)
- **URL**: `POST {BASE_URL}/v1/feedback`
- **Body**:
```json
{
  "request_id": "req-...",
  "predicted_label": "rice/blast",
  "reported_wrong": true,
  "comment": "User notes"
}
```

---

## 🧪 Testing

To run the full suite of unit and widget tests:
```bash
flutter test
```

### Test Coverage
- `test/unit/json_parsing_test.dart`: Validates strict parsing of Confident, Uncertain, and Unknown payloads, confidence sorting, and knowledge base fallbacks.
- `test/unit/mock_prediction_service_test.dart`: Validates cycling sequence through all 3 response states, latency simulation, and health check.
- `test/unit/history_repository_test.dart`: Tests `HistoryScan` JSON serialization, updates, and feedback tracking.
- `test/widget/result_screen_test.dart`: Comprehensive widget tests for `ResultScreen` across all 3 prediction states (`confident`, `uncertain`, `unknown`) in both **Bangla** and **English** locales.

---

## 🏛 Architecture Overview

```
cropdoc_app/
├── assets/
│   ├── icons/                 # App launcher icon
│   └── knowledge/
│       └── diseases.json      # Bilingual offline disease knowledge base
├── lib/
│   ├── core/                  # Core design tokens, theme, utilities
│   │   ├── config.dart        # Configuration & developer mode settings
│   │   ├── providers/         # Global Riverpod state providers
│   │   ├── theme/             # Material 3 colors, typography, extensions
│   │   └── utils/             # Blur check, image resize, haptics, helpers
│   ├── data/                  # Data layer: API, models, repositories
│   │   ├── api/               # PredictionService, Mock, Http (Dio), contract
│   │   ├── models/            # PredictionResponse, CropDiseaseInfo, HistoryScan
│   │   └── repositories/      # HistoryRepository (Hive), DiseaseRepository
│   ├── features/              # Feature modules (Clean Architecture)
│   │   ├── analyzing/         # Scanning animation & timeout screen
│   │   ├── capture/           # Camera preview & quality check screen
│   │   ├── guide/             # Offline disease library & detail screen
│   │   ├── history/           # History listing, filter, CSV export
│   │   ├── home/              # Main dashboard screen
│   │   ├── onboarding/        # 3-slide introductory onboarding
│   │   ├── result/            # Diagnosis presentation screen
│   │   ├── settings/          # App settings & hidden developer panel
│   │   └── shell/             # Scaffold with smooth bottom navigation
│   ├── l10n/                  # ARB files (app_en.arb, app_bn.arb)
│   └── main.dart              # App bootstrap & Hive initialization
└── test/                      # Unit and widget test suite
```
