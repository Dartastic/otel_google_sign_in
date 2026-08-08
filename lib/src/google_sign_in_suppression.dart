// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'dart:async';

const Symbol _suppressKey = #otel_google_sign_in_suppress;

/// Whether Google Sign-In instrumentation is suppressed in the
/// current [Zone] (see [runWithoutGoogleSignInInstrumentation]).
bool googleSignInInstrumentationSuppressed() {
  return Zone.current[_suppressKey] == true;
}

/// Runs [body] with Google Sign-In instrumentation suppressed:
/// `traced*` calls inside it invoke the underlying operation
/// without opening spans.
T runWithoutGoogleSignInInstrumentation<T>(T Function() body) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}

/// Async variant of [runWithoutGoogleSignInInstrumentation].
Future<T> runWithoutGoogleSignInInstrumentationAsync<T>(
  Future<T> Function() body,
) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}
