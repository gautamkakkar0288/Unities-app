import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';
import 'app/providers.dart';
import 'core/logging/app_logger.dart';
import 'core/storage/preferences_key_value_store.dart';

/// Entry point.
///
/// Startup does exactly three things before the first frame: read the compiled
/// configuration, validate it, and open device preferences. Session restoration
/// is *not* awaited here — it runs behind the splash route, so a slow network
/// delays a screen the student can see rather than a blank window.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromDartDefines();
  final logger = AppLogger.forConfig('bootstrap', config);

  final problems = config.validate();
  if (problems.isNotEmpty) {
    for (final problem in problems) {
      logger.error('configuration problem: $problem');
    }
    runApp(ConfigurationErrorApp(problems: problems));
    return;
  }

  final preferences = await PreferencesKeyValueStore.open();
  logger.info('starting', data: <String, Object?>{
    'environment': config.environment.name,
    'apiBaseUrl': config.apiBaseUrl,
    'sampleContent': config.useSampleContent,
  });

  runApp(
    ProviderScope(
      overrides: <Override>[
        appConfigProvider.overrideWithValue(config),
        preferencesStoreProvider.overrideWithValue(preferences),
      ],
      child: const CirqlesApp(),
    ),
  );
}
