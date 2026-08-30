# DiaSense Mobile - Production Health Companion Application

DiaSense Mobile is a Flutter mobile application engineered for proactive diabetes risk prediction, real-time glycemic tracking, personalized dietary planning, AI health conversation, and nearby care facility discovery.

Built specifically for Android and iOS devices, it connects directly to the DiaSense / MajorPro FastAPI backend via clean RESTful API abstractions.

---

## Key Features

1. **AI-Driven Diabetes Risk Assessment**:
   - 5-step guided wizard capturing clinical baseline metrics (Glucose, Blood Pressure, BMI, Insulin, DPF, Age, Pregnancies).
   - Real-time inference using an 88.3% accuracy Random Forest machine learning model.
   - Comprehensive risk score gauge and detailed "Why is my risk elevated?" contributing factor breakdown.

2. **Personalized Diet & Lifestyle Plans**:
   - Tailored meal recommendations for Breakfast, Lunch, Dinner, and Healthy Snacks.
   - Daily exercise regimes and evidence-based lifestyle tips.

3. **Intelligent Food & Nutrition Vision Analyzer**:
   - Instant text query or camera/gallery meal image recognition.
   - Computes calories, net carbohydrates, glycemic index (GI), glycemic load (GL), and diabetic suitability.

4. **DiaSense AI Health Assistant**:
   - Interactive medical and dietary conversational assistant with conversational context and retry recovery.

5. **Clinical Reports & Care Locator**:
   - Official downloadable and viewable PDF medical summary reports.
   - Geocoded search and GPS locator for nearby hospitals, clinics, and diagnostic labs.

6. **Medical Safety & Security**:
   - Strict non-diagnostic disclaimers across all risk screens.
   - Encrypted token storage via lutter_secure_storage (Android Keystore & iOS Keychain).
   - Zero hardcoded secrets; centralized Dio interceptor handling 401 expiration gracefully.

---

## Architecture

DiaSense Mobile follows **Clean Architecture** with a **Feature-First** modular organization:

`
lib/
├── app/                  # App entrypoint, GoRouter navigation, theme & config
├── core/                 # Centralized DioClient, secure storage, validators, reusable UI
├── features/
│   ├── authentication/   # JWT Auth, Register, Login, Splash
│   ├── onboarding/       # Carousel introduction flow
│   ├── dashboard/        # Health score overview, recent activities, quick tools
│   ├── assessment/       # 5-step guided clinical wizard & details
│   ├── prediction/       # Risk gauge, contributing factor bars, explanations
│   ├── health_history/   # FlChart trend graphs & historical assessments
│   ├── diet/             # Meal plans, exercise regimens, tips
│   ├── chatbot/          # AI conversational health assistant
│   ├── food_analysis/    # Text & image-based macro/GI analysis
│   ├── reports/          # Downloadable PDF clinical summaries
│   ├── nearby_care/      # Hospital & diagnostic center locator
│   ├── profile/          # User metadata, password update, disclaimer
│   └── shell/            # 5-tab persistent bottom navigation shell
└── shared/               # Shared models & utilities
`

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.19+ recommended)
- [Dart SDK](https://dart.dev/get-dart) (v3.0.0+)
- DiaSense FastAPI Backend running locally or on a server (http://127.0.0.1:8000 / http://10.0.2.2:8000)

### Installation & Run

1. Clone or navigate to the project directory:
   `ash
   cd mobileDBsenseAi
   `

2. Install dependencies:
   `ash
   flutter pub get
   `

3. Configure Environment:
   Edit .env or pass runtime arguments:
   `env
   API_BASE_URL=http://10.0.2.2:8000  # For Android Emulator
   # API_BASE_URL=http://127.0.0.1:8000  # For iOS Simulator / Web
   `

4. Run the application:
   `ash
   flutter run
   `

5. Run Automated Tests:
   `ash
   flutter test
   `

---

## Documentation
- [Architecture Details](docs/architecture.md)
- [API Integration Specification](docs/api-integration.md)
- [Development & Testing Guide](docs/development.md)
- [Security & Medical Disclaimers](docs/security.md)
