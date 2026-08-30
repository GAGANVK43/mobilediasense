# DiaSense AI — Full API Contract Audit

| Module | Mobile Endpoint | HTTP Method | Backend Route | Requires Auth | Status |
|---|---|---|---|---|---|
| **Auth** | `/api/auth/register` | `POST` | `/api/auth/register` | No | Verified |
| **Auth** | `/api/auth/login` | `POST` | `/api/auth/login` | No | Verified |
| **Auth** | `/api/auth/profile` | `GET` | `/api/auth/profile` | Yes (Bearer) | Verified |
| **User** | `/api/user/me` | `GET` | `/api/user/me` | Yes (Bearer) | Verified |
| **User** | `/api/user/profile` | `PUT` | `/api/user/profile` | Yes (Bearer) | Verified |
| **User** | `/api/user/change-password` | `POST` | `/api/user/change-password` | Yes (Bearer) | Verified |
| **Dashboard** | `/api/dashboard` | `GET` | `/api/dashboard` | Yes (Bearer) | Verified |
| **Assessment** | `/api/assessment` | `POST` | `/api/assessment` | Yes (Bearer) | Verified |
| **Assessment** | `/api/assessment/history` | `GET` | `/api/assessment/history` | Yes (Bearer) | Verified |
| **Assessment** | `/api/assessment/{id}` | `GET` | `/api/assessment/{id}` | Yes (Bearer) | Verified |
| **Prediction** | `/api/prediction` | `POST` | `/api/prediction` | Yes (Bearer) | Verified |
| **Prediction** | `/api/prediction/latest` | `GET` | `/api/prediction/latest` | Yes (Bearer) | Verified |
| **Prediction** | `/api/prediction/history` | `GET` | `/api/prediction/history` | Yes (Bearer) | Verified |
| **Diet** | `/api/diet/latest` | `GET` | `/api/diet/latest` | Yes (Bearer) | Verified |
| **Diet** | `/api/diet/{id}` | `GET` | `/api/diet/{id}` | Yes (Bearer) | Verified |
| **Reports** | `/api/reports/{id}` | `GET` | `/api/reports/{id}` | Yes (Bearer) | Verified |
| **Reports** | `/api/reports/{id}/pdf` | `GET` | `/api/reports/{id}/pdf` | Yes (Bearer) | Verified |
| **Nearby Care** | `/api/nearby-care` | `GET` | `/api/nearby-care` | Yes (Bearer) | Verified |
| **Nearby Care** | `/api/nearby-care/geocode` | `GET` | `/api/nearby-care/geocode` | Yes (Bearer) | Verified |
| **Food AI** | `/api/food/analyze-text` | `POST` | `/api/food/analyze-text` | Yes (Bearer) | Verified |
| **Food AI** | `/api/food/analyze-image` | `POST` | `/api/food/analyze-image` | Yes (Bearer) | Verified |
| **Chatbot** | `/api/chatbot/query` | `POST` | `/api/chatbot/query` | Yes (Bearer) | Verified |
| **System** | `/health` | `GET` | `/health` | No | Verified |
