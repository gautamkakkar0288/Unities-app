/// Build-time configuration.
///
/// Values arrive through `--dart-define`, not a bundled config file, so a
/// release artifact cannot accidentally ship a developer's environment. See
/// `.env.example` and README § Configuration.
///
/// This class holds *configuration*, never secrets. A mobile binary is public;
/// anything compiled in is readable by anyone who downloads the app.
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment parse(String raw) {
    return AppEnvironment.values.firstWhere(
      (env) => env.name == raw.trim().toLowerCase(),
      orElse: () => AppEnvironment.development,
    );
  }

  bool get isDevelopment => this == AppEnvironment.development;
  bool get isProduction => this == AppEnvironment.production;
}

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.verboseLogging,
    required this.analyticsEnabled,
    required this.pushEnabled,
    required this.useSampleContent,
    required this.communitiesEnabled,
    required this.searchEnabled,
    required this.createEnabled,
  });

  /// Reads the compiled-in configuration.
  factory AppConfig.fromDartDefines() {
    const rawEnvironment = String.fromEnvironment(
      'CIRQLES_ENV',
      defaultValue: 'development',
    );
    final environment = AppEnvironment.parse(rawEnvironment);

    return AppConfig(
      environment: environment,
      // 10.0.2.2 is the host machine as seen from the Android emulator; the
      // iOS simulator shares the host network, so override for it.
      apiBaseUrl: const String.fromEnvironment(
        'CIRQLES_API_BASE_URL',
        defaultValue: 'http://10.0.2.2:3000',
      ),
      verboseLogging: bool.fromEnvironment(
            'CIRQLES_VERBOSE_LOGGING',
            defaultValue: true,
          ) &&
          !environment.isProduction,
      analyticsEnabled: const bool.fromEnvironment('CIRQLES_ANALYTICS_ENABLED'),
      pushEnabled: const bool.fromEnvironment('CIRQLES_PUSH_ENABLED'),
      // Sample content is a development affordance for screens whose endpoint
      // does not exist yet. Force-disabled in production so a release build
      // can never present invented data as real.
      useSampleContent:
          const bool.fromEnvironment('CIRQLES_USE_SAMPLE_CONTENT') &&
              !environment.isProduction,
      communitiesEnabled:
          const bool.fromEnvironment('CIRQLES_FEATURE_COMMUNITIES'),
      searchEnabled: const bool.fromEnvironment('CIRQLES_FEATURE_SEARCH'),
      createEnabled: const bool.fromEnvironment('CIRQLES_FEATURE_CREATE'),
    );
  }

  final AppEnvironment environment;

  /// Origin of the Cirqles Next.js deployment (the Unities repository).
  final String apiBaseUrl;

  final bool verboseLogging;
  final bool analyticsEnabled;
  final bool pushEnabled;
  final bool useSampleContent;
  final bool communitiesEnabled;
  final bool searchEnabled;
  final bool createEnabled;

  Uri get apiBaseUri => Uri.parse(apiBaseUrl);

  /// Shown as a banner in non-production builds so nobody files a bug against
  /// the wrong environment.
  bool get showEnvironmentBanner => !environment.isProduction;

  /// Fails fast at startup rather than at the first request.
  List<String> validate() {
    final problems = <String>[];
    final uri = Uri.tryParse(apiBaseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      problems.add('CIRQLES_API_BASE_URL is not an absolute URL: $apiBaseUrl');
    } else if (environment.isProduction && uri.scheme != 'https') {
      problems.add('Production builds must use https, got ${uri.scheme}');
    }
    return problems;
  }
}
