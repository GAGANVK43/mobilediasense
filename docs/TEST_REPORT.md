# DiaSense AI — Test Report & Verification Matrix

## 1. Flutter Unit & Widget Test Matrix
| Module | Test Description | Expected | Result | Status |
|---|---|---|---|---|
| `auth_models_test` | `AuthTokens` serialization & parsing | Parsed correctly | Parsed correctly | PASS |
| `auth_models_test` | `UserModel` copyWith & JSON | Matches input | Matches input | PASS |
| `prediction_model_test` | Risk category & contributing factors | Extracted properly | Extracted properly | PASS |
| `validators_test` | Email format validator | Validates syntax | Validates syntax | PASS |
| `validators_test` | Password length validator | Enforces >= 6 chars | Enforces >= 6 chars | PASS |
| `validators_test` | Clinical number range validator | Rejects out-of-range | Rejects out-of-range | PASS |
| `app_button_test` | Button click & label widget test | Fires callback | Fires callback | PASS |
| `risk_gauge_test` | RiskGauge percentage visual widget test | Renders gauge | Renders gauge | PASS |
| **Total Test Suite** | **9/9 Test Suites** | **All Pass** | **9 Passed, 0 Failed** | **PASS** |

## 2. API Contract & Cloud Integration Tests
- **Cloud Backend Endpoint**: `https://diasense-ai-backend.onrender.com/health` (HTTP 200 OK)
- **Supabase DB Pooler**: Verified across 5 tables (`users`, `assessments`, `predictions`, `diet_plans`, `contact_messages`).
