/// Every route path in one place.
///
/// Paths are the deep-link contract with the web app: `/events/:slug` in the
/// browser must open the same screen in the app, so they mirror
/// `lib/navigation/config.ts` in the Unities repository rather than inventing a
/// mobile-only URL space.
class Routes {
  const Routes._();

  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';

  /// Tabs. `appHomeHref` on the web is `/home`, and these match `mobileNav`.
  static const String home = '/home';
  static const String explore = '/explore';
  static const String create = '/create';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  /// Deep links, shared with the web routes of the same shape.
  static const String eventDetail = '/events/:slug';
  static const String communityDetail = '/communities/:slug';

  static String eventPath(String slug) => '/events/$slug';
  static String communityPath(String slug) => '/communities/$slug';

  /// Query parameter used to remember where a signed-out student was heading.
  static const String fromQueryParam = 'from';
}
