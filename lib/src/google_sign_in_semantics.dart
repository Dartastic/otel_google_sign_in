// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

/// Typed attribute keys for Google Sign-In instrumentation.
///
/// The OpenTelemetry semantic-convention registry has no `auth.*`
/// namespace yet, so these live here as a package-local enum
/// implementing [OTelSemantic] until the registry (and then the API
/// package) adds an authentication convention. When that happens,
/// these can `@Deprecated`-pivot to the API enums.
///
/// The user identity attribute is not here on purpose: the registry
/// `enduser.id` key (the API's `Enduser.enduserId`) is used for that.
enum GoogleSignInSemantics implements OTelSemantic {
  /// The client-side authentication library in use.
  /// Always `google_sign_in`.
  authSystem('auth.system'),

  /// The logical auth operation, e.g. `authenticate`, `sign_out`.
  authOperation('auth.operation'),

  /// The identity provider. Always `google.com`.
  authProvider('auth.provider');

  const GoogleSignInSemantics(this.key);

  @override
  final String key;

  @override
  String toString() => key;
}
