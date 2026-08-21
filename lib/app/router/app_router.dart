import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_session.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/communities/presentation/community_detail_screen.dart';
import '../../features/create/presentation/create_screen.dart';
import '../../features/events/presentation/event_detail_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../providers.dart';
import 'app_shell.dart';
import 'not_found_screen.dart';
import 'routes.dart';

/// The router.
///
/// Route protection lives here and only here: a single `redirect` reads the
/// session, so no screen can be reached by a deep link that bypasses a check
/// it forgot to make. The five tabs keep independent navigation stacks through
/// `StatefulShellRoute`, which is what makes switching tabs feel instant
/// instead of rebuilding a screen.
final routerProvider = Provider<GoRouter>((ref) {
  final logger = ref.watch(loggerProvider).child('router');

  // go_router needs a Listenable; Riverpod state is pushed into one here.
  final sessionNotifier = ValueNotifier<AuthSession>(
    const AuthSessionUnknown(),
  );
  ref.listen<AuthSession>(
    authControllerProvider,
    (previous, next) => sessionNotifier.value = next,
    fireImmediately: true,
  );
  ref.onDispose(sessionNotifier.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: sessionNotifier,
    debugLogDiagnostics: ref.watch(appConfigProvider).verboseLogging,
    redirect: (context, state) {
      final session = sessionNotifier.value;
      final location = state.matchedLocation;
      final isAuthRoute =
          location == Routes.signIn || location == Routes.signUp;

      // Still restoring: hold on the splash rather than flashing sign-in.
      if (session is AuthSessionUnknown) {
        return location == Routes.splash ? null : Routes.splash;
      }

      if (!session.isAuthenticated) {
        if (isAuthRoute) return null;
        // Remember the destination so a deep link survives sign-in.
        final target = Uri(
          path: Routes.signIn,
          queryParameters: location == Routes.splash
              ? null
              : <String, String>{
                  Routes.fromQueryParam: state.uri.toString(),
                },
        );
        return target.toString();
      }

      if (location == Routes.splash || isAuthRoute) {
        final from = state.uri.queryParameters[Routes.fromQueryParam];
        return (from != null && from.startsWith('/')) ? from : Routes.home;
      }
      return null;
    },
    errorBuilder: (context, state) {
      logger.warn('unknown route', data: <String, Object?>{
        'location': state.uri.toString(),
      });
      return NotFoundScreen(location: state.uri.toString());
    },
    routes: <RouteBase>[
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),

      // Detail routes sit outside the shell: they push over the tabs, as a
      // deep-linked event should.
      GoRoute(
        path: Routes.eventDetail,
        builder: (context, state) => EventDetailScreen(
          slug: state.pathParameters['slug'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.communityDetail,
        builder: (context, state) => CommunityDetailScreen(
          slug: state.pathParameters['slug'] ?? '',
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.explore,
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.create,
                builder: (context, state) => const CreateScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.notifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
