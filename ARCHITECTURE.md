# Cirqles mobile architecture

How this app is put together, and why. Product rules, data shapes and business
logic belong to the web repository
([`Unities`](https://github.com/gautamkakkar0288/Unities)); this document covers
only the client.

---

## 1. The constraint that shaped everything

Cirqles is a Next.js App Router application. Its data access lives in
`lib/services/*` and is consumed by **server components and server actions**.
Apart from Auth.js, there is no JSON API:

```
app/api/auth/[...nextauth]/route.ts   ← the only HTTP route
features/*/actions.ts                 ← server actions (no HTTP contract)
lib/services/*.ts                     ← data access, server-only
```

A mobile client cannot call a server action. So this app was built around an
honest split:

- **Authentication is real**, because Auth.js exposes HTTP endpoints.
- **Everything else is architecture-ready and blocked**, with typed interfaces
  written as the specification the backend work can be built against.

The alternative — inventing `/api/events` and shipping a client that 404s —
would have produced a more impressive-looking Phase 1 and a worse codebase.

## 2. Project structure

```
lib/
  app/
    config/app_config.dart        compiled configuration + validation
    theme/                        design tokens translated from DESIGN_SYSTEM.md
    router/                       routes, guard, bottom-nav shell
    providers.dart                dependency injection graph
    app.dart                      MaterialApp.router
  core/
    errors/                       AppError taxonomy + user-facing copy
    logging/                      AppLogger with credential redaction
    network/                      ApiClient, Dio implementation, paths, paging
    storage/                      KeyValueStore: secure and preference-backed
    utils/                        Result, formatters
  features/<feature>/
    domain/                       repository interfaces, feature models
    data/                         implementations + Riverpod providers
    presentation/                 screens and controllers
  shared/
    models/                       typed models mirroring the backend schema
    widgets/                      the component library
```

Features are vertical slices. There is no `data → domain → usecase → repository`
chain where a layer only forwards a call: a screen watches a provider, the
provider calls a repository, the repository talks to the API. Three hops, each
doing real work.

## 3. State management

**Riverpod** (`flutter_riverpod`), chosen because it gives compile-time-safe
dependency injection and testability without code generation or a `BuildContext`
dependency — repositories can be overridden in tests and in `main()` with no
service locator and no globals.

- `Provider` for wiring (config, logger, Dio, repositories).
- `FutureProvider` for reads; `AsyncValue` carries loading/error into the UI.
- `Notifier` for the one piece of long-lived state that matters:
  `AuthController`.

Every dependency in `lib/app/providers.dart` is overridable, which is what makes
the repository tests run with no network and no plugins.

## 4. Networking

`ApiClient` (`lib/core/network/api_client.dart`) is the only abstraction the app
uses; `DioApiClient` implements it. Each call passes a `JsonDecoder<T>`, so
responses become typed models at the boundary and no `Map<String, dynamic>`
travels further in.

Responsibilities held there, deliberately not in features or widgets:

- timeouts (connect, send, receive);
- cookie handling via `dio_cookie_manager` + `cookie_jar`, because Auth.js is
  cookie-based;
- `form-urlencoded` bodies, required by the Auth.js credentials callback;
- mapping every failure to a typed `AppError` — `DioExceptionType` never
  escapes this layer;
- request/response logging that redacts credentials, in verbose builds only;
- broadcasting a 401 on `UnauthorizedSignal` so the session can be ended once,
  centrally, wherever the response came from.

Pagination is cursor-shaped from the start (`PageRequest` / `Paginated<T>`), so
no list screen was written assuming it could load everything.

## 5. Authentication

Mirrors Auth.js v5 with the **Credentials provider** (the only provider
configured in `auth.config.ts`) and a JWT session in an httpOnly cookie.

Sign-in is the browser flow, performed by a client:

1. `GET /api/auth/csrf` — obtain the CSRF token and cookie.
2. `POST /api/auth/callback/credentials` — form-encoded email, password, CSRF
   token; `followRedirects: false`, because a 302 to the sign-in page *is* the
   failure signal.
3. `GET /api/auth/session` — confirm and read the user payload
   (`id`, `role`, `name`, `email`, `image`).

The session cookie is persisted with `flutter_secure_storage` (Keychain /
Keystore) and restored into the cookie jar at launch. `SharedPreferences` holds
only non-sensitive values.

Lifecycle: launch → `AuthSessionUnknown` (splash) → restore →
`AuthSessionActive` or `AuthSessionSignedOut`. `AuthSession` is a sealed class,
so “unknown” and “signed out” cannot be confused — that distinction is what
stops the app flashing sign-in at a signed-in student. A 401 from any request
ends the session with a reason, which the sign-in screen displays.

Validation rules (`AuthValidation`) are copied from `lib/schemas/auth.ts`:
password 8–72 characters (bcrypt truncates beyond 72 bytes), name 2–80
trimmed. They exist to save a round trip; the server remains authoritative, and
`test/features/auth/auth_validation_test.dart` is where drift will show.

**Known gaps, by design:** there is no refresh-token rotation (Auth.js JWT
sessions do not expose one), and registration has no endpoint —
`AuthRepository.signUp` fails with `MissingBackendCapabilityError` and the UI
hands off to the web sign-up page.

## 6. Navigation

`go_router` with a single `redirect` guard, so no screen can be reached by a
deep link that skips an auth check:

- `AuthSessionUnknown` → hold on the splash.
- signed out → `/sign-in`, with the intended location preserved in `?from=`, so
  a deep link survives sign-in.
- signed in on an auth route → the remembered destination, else `/home`.

Authenticated navigation is a `StatefulShellRoute.indexedStack` with five
branches, each keeping its own stack. The tabs are **Home, Explore, Create,
Alerts, Profile** — taken from `mobileNav` in the web repository's
`lib/navigation/config.ts`, not guessed. That is why there is no Communities
tab: on the web, communities live inside discovery, and giving mobile a
different information architecture would teach students two mental models.
Communities are reachable from Explore.

Detail routes sit outside the shell and share the web URL shape, so links are
portable between clients:

- `/events/:slug`
- `/communities/:slug`

Unknown routes render a Cirqles-styled not-found screen rather than a red error
page. Onboarding is routed for but not built: `email_verified` and onboarding
state are not exposed by the session payload yet.

## 7. Local storage

One interface, two implementations:

| Store | Backing | Holds |
| --- | --- | --- |
| `SecureKeyValueStore` | Keychain / Keystore | the session cookie |
| `PreferencesKeyValueStore` | `SharedPreferences` | theme preference, intro completion, last sign-in email |
| `InMemoryKeyValueStore` | memory | tests |

Keys are constants in `storage_keys.dart`. Nothing sensitive is written to
preferences, and no user content is cached to disk in this phase — offline
support is a later, deliberate piece of work, not an accident of caching.

## 8. Error handling

`AppError` is a sealed hierarchy: `NetworkError`, `TimeoutError`,
`UnauthorizedError`, `ForbiddenError`, `NotFoundError`, `ValidationError`,
`ServerError`, `DecodingError`, `MissingBackendCapabilityError`,
`UnknownError`. Repositories return `Result<T>` (`Success` / `Failure`), so a
failure is a value a caller must handle rather than an exception that might
escape.

`error_messages.dart` is the only place an error becomes words. It answers three
questions — title, message, and whether retrying could possibly help — which is
why a missing endpoint never shows a “Try again” button. Debug detail lives in
`debugMessage`, is logged, and is never rendered;
`test/core/errors/error_messages_test.dart` asserts that.

`MissingBackendCapabilityError` is the deliberate centre of this design: the
absence of an endpoint is modelled as data, so it can be tested, rendered, and
counted rather than commented out.

## 9. Logging

`AppLogger` writes structured lines through `dart:developer`, scoped by
subsystem (`network`, `auth`, `router`). Debug and info are dropped unless
verbose logging is on, so production output is warnings and errors only.
Redaction of credential-bearing keys (`password`, `cookie`, `authorization`,
`csrfToken`, `email`, …) happens inside the logger, not at call sites, so a
future call site cannot leak a session cookie by passing the wrong map.

## 10. Design system

`DESIGN_SYSTEM.md` and `app/globals.css` define Cirqles in **OKLCH**. Rather
than eyeball hex approximations, `oklch.dart` converts OKLCH to sRGB at runtime
and the token files carry the same numbers as the web app — one source of truth
for brand colour, and a test that the conversion is right.

Tokens: `color_tokens.dart` (raw), `CirqlesColors` (a `ThemeExtension` carrying
Cirqles' semantic families — brand, support, featured, success, warning, info,
danger — which Material's `ColorScheme` has no slots for), `app_typography`,
`Spacing`, `Radii`, `Elevations`, `Motion`, `Sizing`. Widgets reference tokens
only.

Light mode is the primary experience, as the design system specifies. A dark
theme is defined and loads, but there is no user-facing switch yet, so the app
does not follow the system setting — shipping a half-reviewed dark mode is worse
than shipping none.

Accessibility is built in, not deferred: 48dp minimum touch targets in `Sizing`,
semantic labels on cards and icon buttons, text scaling clamped to 1.6× rather
than ignored, status always carried by text or icon and never by colour alone,
and skeletons that respect `disableAnimations`.

## 11. Testing strategy

`test/` mirrors `lib/`. The tests written for this phase are the ones that would
actually catch a regression:

- **model decoding** — wire enums, `snake_case` and `camelCase` keys, unknown
  enum values falling back safely, round trips, and schema semantics (null
  capacity means unlimited, null fee means free, counters that overshoot);
- **error copy** — no internal detail reaches the user; retry is offered only
  where it could help;
- **logging** — credentials are redacted;
- **validation** — the rules match `lib/schemas/auth.ts`;
- **repositories** — the pending implementations report the missing capability
  rather than pretending to work;
- **widgets** — empty and error states, including a 320dp phone at 1.6× text
  scale.

No mocking framework: fakes are hand-written, which keeps tests readable and
the dependency list short. No tests exist purely to raise coverage.

## 12. Environment management

Configuration is compiled in with `--dart-define` and read once into an
immutable `AppConfig`, which is injected at the root of the provider graph.
Nothing reads configuration from a global. `validate()` runs before the first
frame, and production builds force sample content off, so placeholder data
cannot reach a real user. The app ships no secrets: the only credential it ever
holds is the student's own session cookie, in platform secure storage.

---

## What the backend still needs to provide

In priority order. Each maps to an existing repository interface in this app, so
wiring is small once the endpoint exists.

1. **Session-authenticated JSON routes** under `app/api/mobile/*`, thin Route
   Handlers wrapping the existing `lib/services/*` functions and reusing the
   Auth.js session — no new auth, no duplicated logic:
   - `GET /api/mobile/feed` → `EventRepository.upcomingEvents`
   - `GET /api/mobile/events/:slug` → `EventRepository.eventBySlug`
   - `GET /api/mobile/communities` and `/:slug` → `CommunityRepository`
   - `GET /api/mobile/notifications` → `NotificationRepository.inbox`
   - `GET /api/mobile/me` → profile, university affiliation, verification
     state, interests, memberships
2. **Registration endpoint** wrapping `registerUser`, so sign-up stops being a
   web hand-off.
3. **Write endpoints** for event registration, community join and
   notification read state — the flows students most want on a phone.
4. **Device-token registration**, the prerequisite for push. Event reminders are
   the app's clearest push use case and the notification kinds already exist.
5. **Cursor pagination** on the list routes above, matching `PageRequest` /
   `Paginated<T>`.
