# Changelog

## [0.1.0-beta.1-wip]

### Added

- Extension methods on `GoogleSignIn`: `tracedSignIn`,
  `tracedSignInSilently`, `tracedSignOut`, `tracedDisconnect`.
  Each opens a CLIENT span named `google_sign_in <op>` with
  `auth.system=google_sign_in`, `auth.operation`,
  `auth.provider=google.com`.
- On successful sign-in, the resulting account ID is attached as
  `enduser.id` (opt-out via `recordUserId: false`).
- `tracedGoogleSignInCall<R>` — generic helper.
- Zone-scoped suppression
  (`runWithoutGoogleSignInInstrumentation` / async variant).
- 3 tests via the generic helper.
