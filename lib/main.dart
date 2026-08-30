import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app/app.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/authentication/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences & Secure Storage
  final sharedPrefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final storageService = SecureStorageService(
    secureStorage: secureStorage,
    preferences: sharedPrefs,
  );

  runApp(
    ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(storageService),
      ],
      child: const DiaSenseApp(),
    ),
  );
}
