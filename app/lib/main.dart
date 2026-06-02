import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/env.dart';
import 'package:doctor_booking_app/core/di/di_providers.dart';
import 'package:doctor_booking_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Select environment
  const envStr = String.fromEnvironment('ENV', defaultValue: 'dev');
  final config = EnvConfig.fromString(envStr);

  // 2. Initialize Supabase (primary database)
  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
  );

  // 3. Global error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (config.enableLogging) {
      debugPrint('FlutterError: ${details.exception}');
    }
  };

  // 4. Run app with Riverpod
  runApp(
    ProviderScope(
      overrides: [
        envConfigProvider.overrideWithValue(config),
      ],
      child: const DoctorBookingApp(),
    ),
  );
}
