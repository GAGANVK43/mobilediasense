# Security & Medical Safety Protocol

## Security Measures
1. **Token Storage**: All JWT access and refresh tokens are stored in Android Keystore / iOS Keychain via lutter_secure_storage.
2. **Session Lifecycles**: Logging out triggers SecureStorageService.clearSession() to purge all cached credentials and identifiers.
3. **No Hardcoded Secrets**: Third-party API keys (e.g. OpenAI / Google Vision) remain strictly encapsulated within the FastAPI backend.
4. **IDOR Protection**: All protected endpoints enforce authenticated user ownership validation.

## Medical Disclaimer & Clinical Safety
- DiaSense Mobile explicitly acts as an assistive screening indicator.
- Machine learning risk predictions are **not** clinical diagnoses.
- Prominent disclaimers appear on all assessment, result, and chatbot interfaces.
