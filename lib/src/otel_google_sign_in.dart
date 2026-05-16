// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'google_sign_in_suppression.dart';

const _tracerName = 'otel_google_sign_in';
const _authSystem = 'google_sign_in';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

Attributes _attrs({required String operation}) =>
    OTel.attributesFromMap(<String, Object>{
      'auth.system': _authSystem,
      'auth.operation': operation,
      'auth.provider': 'google.com',
    });

/// Generic helper. Opens a CLIENT span named
/// `google_sign_in <op>` with auth.* attributes and runs [invoke].
/// On `GoogleSignInAccount?` results, attaches `enduser.id` when
/// non-null (and [recordUserId] is true).
Future<R> tracedGoogleSignInCall<R>({
  required String operation,
  required Future<R> Function() invoke,
  bool recordUserId = true,
}) async {
  if (googleSignInInstrumentationSuppressed()) return invoke();
  final span = _tracer().startSpan(
    'google_sign_in $operation',
    kind: SpanKind.client,
    attributes: _attrs(operation: operation),
  );
  try {
    final result = await invoke();
    if (recordUserId && result is GoogleSignInAccount) {
      span.addAttributes(OTel.attributes([
        OTel.attributeString(Enduser.enduserId.key, result.id),
      ]));
    }
    return result;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

/// Traced operations on [GoogleSignIn].
extension OTelGoogleSignIn on GoogleSignIn {
  /// Traced `signIn`.
  Future<GoogleSignInAccount?> tracedSignIn({bool recordUserId = true}) {
    return tracedGoogleSignInCall<GoogleSignInAccount?>(
      operation: 'sign_in',
      invoke: signIn,
      recordUserId: recordUserId,
    );
  }

  /// Traced `signInSilently`.
  Future<GoogleSignInAccount?> tracedSignInSilently({
    bool recordUserId = true,
  }) {
    return tracedGoogleSignInCall<GoogleSignInAccount?>(
      operation: 'sign_in_silently',
      invoke: signInSilently,
      recordUserId: recordUserId,
    );
  }

  /// Traced `signOut`.
  Future<GoogleSignInAccount?> tracedSignOut() {
    return tracedGoogleSignInCall<GoogleSignInAccount?>(
      operation: 'sign_out',
      invoke: signOut,
      recordUserId: false,
    );
  }

  /// Traced `disconnect`.
  Future<GoogleSignInAccount?> tracedDisconnect() {
    return tracedGoogleSignInCall<GoogleSignInAccount?>(
      operation: 'disconnect',
      invoke: disconnect,
      recordUserId: false,
    );
  }
}
