import 'package:cirqles/app/theme/app_theme.dart';
import 'package:cirqles/core/errors/app_error.dart';
import 'package:cirqles/shared/widgets/empty_state.dart';
import 'package:cirqles/shared/widgets/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('empty state shows its message and action', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      wrap(
        EmptyState(
          icon: Icons.event_available_outlined,
          title: 'Nothing on yet',
          message: 'When your communities publish events, they show up here.',
          actionLabel: 'Explore communities',
          onAction: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Nothing on yet'), findsOneWidget);
    await tester.tap(find.text('Explore communities'));
    expect(tapped, isTrue);
  });

  testWidgets('error state offers retry for a network failure', (tester) async {
    var retries = 0;

    await tester.pumpWidget(
      wrap(
        ErrorStateView(
          error: const NetworkError(debugMessage: 'SocketException: reset'),
          onRetry: () => retries++,
        ),
      ),
    );

    // The internal message must not be on screen.
    expect(find.textContaining('SocketException'), findsNothing);

    await tester.tap(find.textContaining('Try again'));
    expect(retries, 1);
  });

  testWidgets('a missing backend capability is not offered a retry',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        ErrorStateView(
          error: const MissingBackendCapabilityError(
            capability: 'GET /api/events',
            detail: 'Events have no JSON route yet.',
          ),
          onRetry: () {},
        ),
      ),
    );

    expect(find.textContaining('Try again'), findsNothing);
  });

  testWidgets('layouts survive a small phone and large text', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrap(
        MediaQuery.withClampedTextScaling(
          minScaleFactor: 1.6,
          maxScaleFactor: 1.6,
          child: const EmptyState(
            icon: Icons.groups_2_outlined,
            title: 'No communities yet',
            message: 'Communities from your campus will appear here.',
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
