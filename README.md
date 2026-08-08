# otel_google_sign_in

OpenTelemetry instrumentation for
[`package:google_sign_in`](https://pub.dev/packages/google_sign_in)
(v7 API).

```dart
final gsi = GoogleSignIn.instance;

await gsi.tracedInitialize();
final account = await gsi.tracedAuthenticate();
await gsi.tracedSignOut();
```

Each call opens a CLIENT span named `google_sign_in <op>` with:
- `auth.system = google_sign_in`
- `auth.operation = initialize` / `authenticate` /
  `attempt_lightweight_authentication` / `sign_out` / `disconnect`
- `auth.provider = google.com`
- `enduser.id` — the user's Google account ID, on successful
  authentication (opt-out via `recordUserId: false`)

Failures record the exception and set span status to error
(`GoogleSignInException` included, so canceled and misconfigured
flows are visible in traces).

`tracedAttemptLightweightAuthentication` mirrors the underlying
nullable-`Future` contract: a `null` return means no authentication
attempt was possible, and no span is recorded.

Attribute keys are exposed as the `GoogleSignInSemantics` enum.
`tracedGoogleSignInCall<R>` is the generic helper behind the
extension methods, usable for custom operations.

Suppression: `runWithoutGoogleSignInInstrumentation` /
`runWithoutGoogleSignInInstrumentationAsync`.

## License

Apache 2.0
