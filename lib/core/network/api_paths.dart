/// The HTTP surface the Cirqles backend actually exposes today.
///
/// Verified against the Unities repository: the only route handler in `app/` is
/// `app/api/auth/[...nextauth]/route.ts`. Everything else in the product is a
/// Next.js **server action** invoked from a React component, which is not a
/// callable HTTP contract for a mobile client.
///
/// Nothing may be added here speculatively. If a path is not in this file, the
/// data layer raises [MissingBackendCapabilityError] instead.
class AuthPaths {
  const AuthPaths._();

  /// Returns `{ csrfToken }` and sets the CSRF cookie. Auth.js rejects a
  /// credentials POST without both.
  static const String csrf = '/api/auth/csrf';

  /// Returns the current session as JSON (`{}` when signed out).
  static const String session = '/api/auth/session';

  /// Credentials sign-in. Form-encoded, as Auth.js expects.
  static const String signInCredentials = '/api/auth/callback/credentials';

  /// Clears the session cookie. Requires the CSRF token.
  static const String signOut = '/api/auth/signout';
}

/// Capabilities the mobile MVP needs that the backend does not expose over
/// HTTP yet. Referenced by the feature repositories so the gap is visible in
/// code, in the UI and in ARCHITECTURE.md rather than papered over.
class MissingCapabilities {
  const MissingCapabilities._();

  static const String signUp = 'auth.signUp';
  static const String signUpDetail =
      'Registration lives in the `registerUser` server action '
      '(features/auth/actions.ts) and is not reachable over HTTP. The app '
      'hands off to the web sign-up page until an endpoint exists.';

  static const String eventsList = 'events.list';
  static const String eventsDetail =
      'Event queries live in lib/services and are consumed by server '
      'components. No JSON endpoint exists yet.';

  static const String communitiesList = 'communities.list';
  static const String communitiesDetail =
      'Community listing and membership actions are server actions only.';

  static const String notificationsList = 'notifications.list';
  static const String notificationsDetail =
      'The notifications table exists, but there is no read endpoint and no '
      'device-token registration for push.';

  static const String search = 'search.query';
  static const String searchDetail =
      'Search is rendered server-side; no query endpoint is exposed.';

  static const String profile = 'profile.get';
  static const String profileDetail =
      'Profile data beyond the Auth.js session payload has no endpoint. The '
      'session gives id, name, email, image and role only.';
}
