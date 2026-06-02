/// Environment configuration for dev/staging/prod
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

  static const dev = EnvConfig._(
    environment: Environment.dev,
    supabaseUrl: 'https://ynpzpxikzrxmbaokchei.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlucHpweGlrenJ4bWJhb2tjaGVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5OTQ3MDQsImV4cCI6MjA5NDU3MDcwNH0.W1s6cpIEgKzbZPQITNSxv-3E7VEhew-bquWRYjheOOc',
    agoraAppId: '64bf3c1d07fe42eab0f0369ab1d88b94',
    agoraCertificate: '42a57f51a3834215b453e610b8d47a1b',
    payosClientId: '46670123-66ab-4662-967a-41f6f05302e1',
    payosApiKey: '4434d998-9797-46fc-9d3d-5d469e57e47f',
    payosChecksumKey: '4b6f14d6ea597e5ab6d796f5f2ca56f82158c60240bda5cf5d1298682fd96b78',
    enableLogging: true,
    enableCrashlytics: false,
  );

  static const staging = EnvConfig._(
    environment: Environment.staging,
    supabaseUrl: 'https://ynpzpxikzrxmbaokchei.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlucHpweGlrenJ4bWJhb2tjaGVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5OTQ3MDQsImV4cCI6MjA5NDU3MDcwNH0.W1s6cpIEgKzbZPQITNSxv-3E7VEhew-bquWRYjheOOc',
    agoraAppId: '64bf3c1d07fe42eab0f0369ab1d88b94',
    agoraCertificate: '42a57f51a3834215b453e610b8d47a1b',
    payosClientId: '46670123-66ab-4662-967a-41f6f05302e1',
    payosApiKey: '4434d998-9797-46fc-9d3d-5d469e57e47f',
    payosChecksumKey: '4b6f14d6ea597e5ab6d796f5f2ca56f82158c60240bda5cf5d1298682fd96b78',
    enableLogging: true,
    enableCrashlytics: true,
  );

  static const prod = EnvConfig._(
    environment: Environment.prod,
    supabaseUrl: 'https://ynpzpxikzrxmbaokchei.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlucHpweGlrenJ4bWJhb2tjaGVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5OTQ3MDQsImV4cCI6MjA5NDU3MDcwNH0.W1s6cpIEgKzbZPQITNSxv-3E7VEhew-bquWRYjheOOc',
    agoraAppId: '64bf3c1d07fe42eab0f0369ab1d88b94',
    agoraCertificate: '42a57f51a3834215b453e610b8d47a1b',
    payosClientId: '46670123-66ab-4662-967a-41f6f05302e1',
    payosApiKey: '4434d998-9797-46fc-9d3d-5d469e57e47f',
    payosChecksumKey: '4b6f14d6ea597e5ab6d796f5f2ca56f82158c60240bda5cf5d1298682fd96b78',
    enableLogging: false,
    enableCrashlytics: true,
  );

  static EnvConfig fromString(String env) {
    return switch (env) {
      'prod' => EnvConfig.prod,
      'staging' => EnvConfig.staging,
      _ => EnvConfig.dev,
    };
  }
}
