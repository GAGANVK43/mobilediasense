# Architecture Specification: DiaSense Mobile

DiaSense Mobile is architected around Clean Architecture and Riverpod state management.

`
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│    (Screens, Reusable Widgets, Modals, StateNotifier)       │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                       Domain Layer                          │
│               (Entities & Repository Interfaces)             │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        Data Layer                           │
│ (Remote DataSources, Repository Implementations, DTO Models)│
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        Core Layer                           │
│ (DioClient, ApiInterceptor, SecureStorage, Validators, Theme)│
└─────────────────────────────────────────────────────────────┘
`

## State Management Flow with Riverpod
1. **View / Screen**: Watches a StateNotifierProvider or FutureProvider.
2. **StateNotifier / Provider**: Dispatches actions to the Domain Repository.
3. **Repository Implementation**: Coordinates Remote DataSource and Local Secure Storage.
4. **DioClient**: Dispatches authenticated HTTP requests with ApiInterceptor.
5. **FastAPI Backend**: Returns structured JSON envelope { "success": true, "message": "...", "data": {...} }.
