# DiaSense AI — Full Architecture Specification

## 1. System Architecture Diagram

```text
┌─────────────────────────────────────────────────────────────────────────┐
│              DiaSense Mobile (Flutter / Dart / Riverpod)                │
│   • Presentation: Screens (Home, Health, Care, Food, Profile, Diet)     │
│   • State Management: Riverpod (AsyncNotifiers, StateNotifiers)         │
│   • Networking: Dio Client + ApiInterceptor (Bearer JWT Token)         │
│   • Security: FlutterSecureStorage (AES EncryptedSharedPreferences)     │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │  HTTPS REST API (JWT Bearer)
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                 FastAPI Cloud Backend Service (Python 3.12)             │
│   • Routers: /api/auth, /api/assessment, /api/prediction,               │
│              /api/diet, /api/reports, /api/nearby-care, /api/food        │
│   • Security: OAuth2 Bearer, Passlib Bcrypt (72-byte safe), JWT (HS256) │
│   • ReportLab: Automated PDF Clinical Summary Generator                │
└───────────────────┬─────────────────────────────────┬───────────────────┘
                    │                                 │
                    ▼                                 ▼
┌──────────────────────────────────────┐  ┌───────────────────────────────┐
│   Supabase Cloud PostgreSQL DB       │  │  XGBoost Classifier Model     │
│   • users, assessments, predictions  │  │  • 12 Clinical Features       │
│   • diet_plans, contact_messages     │  │  • Authentic Pima Dataset     │
└──────────────────────────────────────┘  └───────────────────────────────┘
```

## 2. Component Specifications

### A. Mobile Application (Frontend)
- **Framework**: Flutter 3.x / Dart 3.x
- **State Management**: Flutter Riverpod 2.x
- **Navigation**: GoRouter (Declarative, type-safe routing)
- **Local Persistence**: `flutter_secure_storage` (Android `EncryptedSharedPreferences`) and `shared_preferences`
- **Network Layer**: `dio` with custom `ApiInterceptor` for automated Bearer token injection and 401 unauthenticated session clearance.
- **Charts**: `fl_chart` for historical glycemic and health trends.

### B. Backend Service
- **Framework**: FastAPI (Asynchronous ASGI Python framework)
- **ORM & DB Layer**: SQLAlchemy 2.0 connected via connection pool to cloud Supabase PostgreSQL.
- **Authentication**: JWT access tokens (HS256) with 24-hour lifecycle, Bcrypt salted password hashing.
- **External Integrations**: OpenStreetMap Nominatim and Overpass API for real nearby hospitals and diagnostic laboratories.

### C. Machine Learning Engine
- **Algorithm**: XGBoost Classifier (`XGBClassifier`)
- **Features (12 Total)**:
  1. `Pregnancies` (count)
  2. `Glucose` (mg/dL)
  3. `BloodPressure` (mmHg)
  4. `SkinThickness` (mm)
  5. `Insulin` (mu U/ml)
  6. `BMI` (kg/m²)
  7. `DiabetesPedigreeFunction` (genetic score)
  8. `Age` (years)
  9. `Glucose_BMI` (engineered interaction)
  10. `Glucose_Age` (engineered interaction)
  11. `High_Glucose` (clinical indicator >= 140 mg/dL)
  12. `High_BMI` (clinical indicator >= 30.0 kg/m²)
- **Dataset**: Authentic Pima Indians Diabetes Dataset (768 clinical patient records from NIDDK).
