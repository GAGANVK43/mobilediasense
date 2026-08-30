# DiaSense AI — Security Audit & Hardening Report

## 1. Authentication & Token Management
- **JWT Storage**: Managed via `FlutterSecureStorage` with `AndroidOptions(encryptedSharedPreferences: true)`. AES-256 encrypted hardware keystore backing on modern Android.
- **Authorization Header Injection**: Centralized in `ApiInterceptor`. Bearer token dynamically read and attached.
- **Session Eviction**: Interceptor catches `401 Unauthorized` responses and immediately calls `clearSession()` to prevent token replay attacks or zombie sessions.
- **Password Security**: Bcrypt with salt hashing on backend. Implements strict 72-byte string truncating protection against denial-of-service hash attacks.

## 2. Insecure Direct Object References (IDOR) Protection
- All authenticated endpoints derive patient identity directly from the signed JWT subject claim (`sub=email`), querying the database by authenticated user id.
- No user can access or modify another patient''s assessment, prediction, diet plan, or clinical PDF report.

## 3. Data Protection & Privacy Compliance
- Assistant disclaimer active across all screening workflows: "Assistive risk screening tool; not a clinical medical diagnosis."
- No passwords, full JWTs, or raw patient records are leaked in frontend or backend application logs.
