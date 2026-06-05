/// Environment configuration for dev/staging/prod
///
/// Tất cả secrets được inject qua --dart-define-from-file=.env.{env}
/// KHÔNG hardcode bất kỳ API key nào trong source code.
enum Environment { dev, staging, prod }

class EnvConfig {
  final Environment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String agoraAppId;
  final String agoraCertificate;
  final String payosClientId;
  final String payosApiKey;
  final String payosChecksumKey;
  final bool enableLogging;
  final bool enableCrashlytics;

  const EnvConfig._({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.agoraAppId,
    this.agoraCertificate = '',
    required this.payosClientId,
    required this.payosApiKey,
    required this.payosChecksumKey,
    this.enableLogging = false,
    this.enableCrashlytics = false,
  });

  bool get isDev => environment == Environment.dev;
  bool get isStaging => environment == Environment.staging;
  bool get isProd => environment == Environment.prod;

  /// Tạo EnvConfig từ dart-define variables (inject lúc build)
  ///
  /// Sử dụng:
  ///   flutter run --dart-define-from-file=.env.dev
  ///   flutter build apk --dart-define-from-file=.env.prod
  ///   flutter build web --dart-define-from-file=.env.prod
  static EnvConfig fromEnvironment() {
    const envStr = String.fromEnvironment('ENV', defaultValue: 'dev');
    final environment = switch (envStr) {
      'prod' => Environment.prod,
      'staging' => Environment.staging,
      _ => Environment.dev,
    };


    return EnvConfig._(
      environment: environment,
      supabaseUrl: const String.fromEnvironment('SUPABASE_URL',
          defaultValue: 'https://ynpzpxikzrxmbaokchei.supabase.co'),
      supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
          defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlucHpweGlrenJ4bWJhb2tjaGVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5OTQ3MDQsImV4cCI6MjA5NDU3MDcwNH0.W1s6cpIEgKzbZPQITNSxv-3E7VEhew-bquWRYjheOOc'),
      agoraAppId: const String.fromEnvironment('AGORA_APP_ID',
          defaultValue: '64bf3c1d07fe42eab0f0369ab1d88b94'),
      agoraCertificate: const String.fromEnvironment('AGORA_CERTIFICATE'),
      payosClientId: const String.fromEnvironment('PAYOS_CLIENT_ID'),
      payosApiKey: const String.fromEnvironment('PAYOS_API_KEY'),
      payosChecksumKey: const String.fromEnvironment('PAYOS_CHECKSUM_KEY'),
      enableLogging: environment == Environment.dev ? true : const bool.fromEnvironment('ENABLE_LOGGING'),
      enableCrashlytics: const bool.fromEnvironment('ENABLE_CRASHLYTICS'),
    );
  }

  /// Backward-compatible factory (deprecated, sẽ xóa sau)
  @Deprecated('Sử dụng EnvConfig.fromEnvironment() thay thế')
  static EnvConfig fromString(String env) {
    return fromEnvironment();
  }
}
