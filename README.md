# otel_google_sign_in

OpenTelemetry instrumentation for
[`package:google_sign_in`](https://pub.dev/packages/google_sign_in).

```dart
final gsi = GoogleSignIn();

final account = await gsi.tracedSignIn();
await gsi.tracedSignOut();
```

Each call opens a CLIENT span named `google_sign_in <op>` with:
- `auth.system = google_sign_in`
- `auth.operation = sign_in` / `sign_out` / `disconnect` / `sign_in_silently`
- `auth.provider = google.com`
- `enduser.id` — the user's Google account ID, on success
  (opt-out via `recordUserId: false`)

Suppression: `runWithoutGoogleSignInInstrumentationAsync`.

## License

Apache 2.0
