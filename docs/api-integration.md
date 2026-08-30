# API Integration Document: DiaSense Mobile

This document specifies the exact contract between DiaSense Mobile and the FastAPI backend.

## Base URLs
- **Android Emulator**: http://10.0.2.2:8000
- **iOS Simulator / Desktop**: http://127.0.0.1:8000
- **Production**: https://your-api-domain.com

## Standard Envelope Format
`json
// Success Response
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}

// Error Response
{
  "success": false,
  "message": "Validation or server error message",
  "errors": [ ... ]
}
`

## Endpoints Summary
- POST /api/auth/register - User registration
- POST /api/auth/login - User login (Access + Refresh Token)
- GET /api/user/profile - Profile with screening stats
- PUT /api/user/profile - Update user details
- PUT /api/user/change-password - Update account password
- GET /api/dashboard - Complete dashboard metrics & active diet plan
- POST /api/assessment - Record clinical assessment & trigger risk calculation
- GET /api/assessment/history - User assessment records
- GET /api/prediction/latest - Latest ML risk prediction
- GET /api/prediction/history - Prediction history for trend charts
- GET /api/diet/latest - Personalized diet & exercise plan
- POST /api/chatbot/query - AI health assistant queries
- POST /api/food/analyze-text - Text-based nutrient & GI analysis
- POST /api/food/analyze-image - Multipart image vision food analyzer
- GET /api/reports/{id}/pdf - Downloadable clinical summary PDF
- GET /api/nearby-care - Geocoded hospital & laboratory search
