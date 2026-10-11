// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'google_sign_in_semantics.dart';
import 'google_sign_in_suppression.dart';

const _tracerName = 'otel_google_sign_in';
const _authSystem = 'google_sign_in';
const _authProvider = 'google.com';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

Attributes _attrs({required String operation}) =>
    OTelAPI.attributesFromMap(<String, Object>{
      GoogleSignInSemantics.authSystem.key: _authSystem,
      GoogleSignInSemantics.authOperation.key: operation,
      GoogleSignInSemantics.authProvider.key: _authProvider,
    });

/// Generic helper. Opens a CLIENT span named
/// `google_sign_in <op>` with auth.* attributes and runs [invoke].
/// On [GoogleSignInAccount] results, attaches `enduser.id` when
/// [recordUserId] is true.
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
      span.addAttributes(OTelAPI.attributes([
        OTelAPI.attributeString(Enduser.enduserId.key, result.id),
      ]));
    }
    return result;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
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

/// Traced operations on [GoogleSignIn] (v7 API).
extension OTelGoogleSignIn on GoogleSignIn {
  /// Traced `initialize`. Configuration failures (e.g. a bad
  /// `clientId`) surface as error spans.
  Future<void> tracedInitialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) {
    return tracedGoogleSignInCall<void>(
      operation: 'initialize',
      invoke: () => initialize(
        clientId: clientId,
        serverClientId: serverClientId,
        nonce: nonce,
        hostedDomain: hostedDomain,
      ),
      recordUserId: false,
    );
  }

  /// Traced `authenticate` (the interactive sign-in flow).
  Future<GoogleSignInAccount> tracedAuthenticate({
    List<String> scopeHint = const <String>[],
    bool recordUserId = true,
  }) {
    return tracedGoogleSignInCall<GoogleSignInAccount>(
      operation: 'authenticate',
      invoke: () => authenticate(scopeHint: scopeHint),
      recordUserId: recordUserId,
    );
  }

  /// Traced `attemptLightweightAuthentication`.
  ///
  /// Mirrors the underlying nullable-`Future` contract: when the
  /// platform returns `null` (it will not attempt authentication),
  /// this returns `null` and no span is recorded.
  Future<GoogleSignInAccount?>? tracedAttemptLightweightAuthentication({
    bool reportAllExceptions = false,
    bool recordUserId = true,
  }) {
    final attempt = attemptLightweightAuthentication(
      reportAllExceptions: reportAllExceptions,
    );
    if (attempt == null) return null;
    return tracedGoogleSignInCall<GoogleSignInAccount?>(
      operation: 'attempt_lightweight_authentication',
      invoke: () => attempt,
      recordUserId: recordUserId,
    );
  }

  /// Traced `signOut`.
  Future<void> tracedSignOut() {
    return tracedGoogleSignInCall<void>(
      operation: 'sign_out',
      invoke: signOut,
      recordUserId: false,
    );
  }

  /// Traced `disconnect`.
  Future<void> tracedDisconnect() {
    return tracedGoogleSignInCall<void>(
      operation: 'disconnect',
      invoke: disconnect,
      recordUserId: false,
    );
  }
}
