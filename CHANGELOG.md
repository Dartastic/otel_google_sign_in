# Changelog

## [0.1.0] - 2026-08-10

### Added

- Extension methods on `GoogleSignIn` (v7 API): `tracedInitialize`,
  `tracedAuthenticate`, `tracedAttemptLightweightAuthentication`,
  `tracedSignOut`, `tracedDisconnect`.
  Each opens a CLIENT span named `google_sign_in <op>` with
  `auth.system=google_sign_in`, `auth.operation`,
  `auth.provider=google.com`.
- On successful authentication, the resulting account ID is attached
  as `enduser.id` (opt-out via `recordUserId: false`).
- `GoogleSignInSemantics` — typed attribute keys (no `auth.*`
  namespace exists in the semconv registry yet).
- `tracedGoogleSignInCall<R>` — generic helper.
- Zone-scoped suppression
  (`runWithoutGoogleSignInInstrumentation` / async variant).

### Changed

- `google_sign_in` floor raised to `^7.0.0`; the traced surface
  follows the v7 singleton API (`GoogleSignIn.instance`,
  `authenticate` / `attemptLightweightAuthentication` replace the
  removed v6 `signIn` / `signInSilently`).
