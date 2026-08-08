// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:otel_google_sign_in/otel_google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure OpenTelemetry once at startup.
  await OTel.initialize(serviceName: 'google-sign-in-example');

  final gsi = GoogleSignIn.instance;

  // Each traced* call opens a CLIENT span named `google_sign_in <op>`
  // with auth.system / auth.operation / auth.provider attributes.
  await gsi.tracedInitialize();

  // Try to resume an existing session without UI first...
  final lightweight = gsi.tracedAttemptLightweightAuthentication();
  var account = lightweight == null ? null : await lightweight;

  // ...and fall back to the interactive flow. On success the span
  // carries `enduser.id` (opt out with `recordUserId: false`).
  try {
    account ??= await gsi.tracedAuthenticate();
  } on GoogleSignInException {
    // Sign-in failed or was canceled; the span is already marked as
    // an error with the exception recorded.
  }
  debugPrint('Signed in as ${account?.email}');

  // Suppress instrumentation for calls that should not be traced.
  await runWithoutGoogleSignInInstrumentationAsync(gsi.tracedSignOut);

  await OTel.shutdown();
}
