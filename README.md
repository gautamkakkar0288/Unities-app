# Cirqles mobile

The official Cirqles mobile client, written in Flutter.

Cirqles is a campus community platform: students join communities (“circles”),
discover and register for events, and get verified through their university
email domain. This repository contains **only the mobile client**. All
server-side business logic, data and authentication live in the web repository
[`gautamkakkar0288/Unities`](https://github.com/gautamkakkar0288/Unities),
which is the source of truth for product behaviour, data models, enums and
brand.

This app has no database, no business rules of its own, and no second auth
system. Where it appears to make a product decision, that decision was read out
of the web repository.

---

## Status

This is **Phase 1: foundation and architecture**. It is a real application
skeleton, not a demo, but most product surfaces are deliberately not
functional yet. What is and is not connected is stated per capability:

| Capability | Status |
| --- | --- |
| Sign in (email + password) | Connected to the real Auth.js credentials endpoints |
| Session restore / sign out | Connected to `/api/auth/session` and `/api/auth/signout` |
| Sign up | **Blocked** — registration is a server action with no HTTP contract; the app hands off to the web |
| Events, communities, notifications, profile detail, search | **Architecture-ready, blocked** — no JSON endpoints exist yet |
| Event registration, joining a community, marking notifications read | **Architecture-ready, blocked** — server actions with no HTTP contract |
| Push notifications | Not started — no device-token registration on the server |

Blocked capabilities are not faked. Each one has a typed repository interface, a
`Pending*` implementation that fails with a `MissingBackendCapabilityError`
naming the gap, and a UI state that tells the student it is not in the app yet.

---

## Requirements

- Flutter **3.24+** stable (Dart **3.4+**). Some APIs used here
  (`Color.withValues`, `MediaQuery.withClampedTextScaling`, Material 3 surface
  container roles) require a recent stable channel.
- Xcode for iOS, Android Studio / SDK for Android.
- A running Cirqles web app to talk to (`pnpm dev` in the `Unities` repository).

## First-time setup

The native shells are **not committed** — they are generated, machine-specific
and large. Generate them once after cloning:

```bash
flutter create --platforms=android,ios --project-name cirqles .
flutter pub get
```

This creates `android/`, `ios/`, and the `.metadata`/generated files. It will
not overwrite anything in `lib/`, `test/`, `pubspec.yaml` or the documentation.

## Configuration

Configuration is compiled in with `--dart-define`. There is no `.env` file read
at runtime, and **no secret is ever stored in this repository or in the app
bundle** — the app holds no API keys, and the session cookie lives only in the
platform keychain/keystore.

`.env.example` documents every supported key. Copy it for reference:

```bash
cp .env.example .env.local   # git-ignored; a notepad for your own values
```

| Key | Purpose | Default |
| --- | --- | --- |
| `CIRQLES_API_BASE_URL` | Base URL of the Cirqles web app | `http://10.0.2.2:3000` |
| `CIRQLES_ENV` | `development`, `staging` or `production` | `development` |
| `CIRQLES_VERBOSE_LOGGING` | Request/response and auth-lifecycle logging | `true` in debug |
| `CIRQLES_USE_SAMPLE_CONTENT` | Render clearly-labelled placeholder content on screens with no endpoint | `false` |
| `CIRQLES_FEATURE_SEARCH` | Enable the search input | `false` |
| `CIRQLES_FEATURE_COMMUNITIES` | Enable community surfaces beyond discovery | `false` |
| `CIRQLES_FEATURE_CREATE` | Enable organiser create flows | `false` |
| `CIRQLES_ANALYTICS_ENABLED` | Analytics opt-in (no provider wired yet) | `false` |
| `CIRQLES_PUSH_ENABLED` | Push opt-in (no provider wired yet) | `false` |

`10.0.2.2` is how the Android emulator reaches your host machine. On the iOS
simulator use `http://localhost:3000`. On a physical device use your machine's
LAN address, and make sure `NEXT_PUBLIC_APP_URL` in the web app matches, or
Auth.js will reject the callback.

`AppConfig.validate()` runs at startup; if the configuration is unusable the app
shows a configuration error screen instead of failing later with confusing
network errors. Sample content is force-disabled in production builds.

## Run

```bash
# Android emulator against a local web app
flutter run \
  --dart-define=CIRQLES_API_BASE_URL=http://10.0.2.2:3000 \
  --dart-define=CIRQLES_ENV=development \
  --dart-define=CIRQLES_VERBOSE_LOGGING=true

# iOS simulator, with placeholder content so empty screens are reviewable
flutter run \
  --dart-define=CIRQLES_API_BASE_URL=http://localhost:3000 \
  --dart-define=CIRQLES_USE_SAMPLE_CONTENT=true
```

## Test, analyse, format

```bash
flutter test
flutter analyze
dart format --set-exit-if-changed lib test
```

CI (`.github/workflows/ci.yml`) runs exactly these, plus
`flutter build apk --debug`, after generating the native shells.

## Project layout

```
lib/
  app/          config, theme and design tokens, router, DI providers
  core/         errors, logging, networking, storage, shared utilities
  features/     auth, home, explore, create, events, communities,
                notifications, profile — each split data / domain / presentation
  shared/       typed models mirroring the backend schema, component library
  main.dart
test/           mirrors lib/
```

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for how these fit together and why.

## Conventions

- **Never invent an endpoint.** If the backend cannot do it, add a repository
  method that fails with `MissingBackendCapabilityError` and surface it.
- **Enums and statuses come from the schema.** Add them to
  `lib/shared/models/enums.dart` with their exact wire value; never compare raw
  strings in a widget.
- **No magic values in widgets.** Use `Spacing`, `Radii`, `Sizing`, `Motion`,
  `Elevations` and the colour tokens.
- **Errors are typed.** Repositories return `Result<T>`; only
  `error_messages.dart` turns an error into words a student reads.
- **Never log credentials.** Pass structured `data` maps to `AppLogger`, which
  redacts credential-bearing keys.
- Single quotes, trailing commas, explicit return types — enforced by
  `analysis_options.yaml`.

## Backend dependency

The only HTTP endpoints this app can currently call are the Auth.js routes in
the web repository:

- `GET /api/auth/csrf`
- `POST /api/auth/callback/credentials`
- `GET /api/auth/session`
- `POST /api/auth/signout`

Everything else in Cirqles is a server action or a server-rendered page. The
highest-value next backend task is a mobile-facing JSON API; see
[`ARCHITECTURE.md`](ARCHITECTURE.md#what-the-backend-still-needs-to-provide).
