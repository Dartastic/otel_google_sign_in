// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otel_google_sign_in/otel_google_sign_in.dart';

class _MemorySpanExporter implements SpanExporter {
  final List<Span> spans = [];
  bool _shutdown = false;

  @override
  Future<void> export(List<Span> s) async {
    if (_shutdown) return;
    spans.addAll(s);
  }

  @override
  Future<void> forceFlush() async {}

  @override
  Future<void> shutdown() async {
    _shutdown = true;
  }
}

Map<String, Object> _attrs(Span span) =>
    {for (final a in span.attributes.toList()) a.key: a.value};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tracedGoogleSignInCall', () {
    late _MemorySpanExporter exporter;

    setUp(() async {
      await OTel.reset();
      exporter = _MemorySpanExporter();
      await OTel.initialize(
        serviceName: 'google-sign-in-otel-test',
        detectPlatformResources: false,
        spanProcessor: SimpleSpanProcessor(exporter),
      );
    });

    tearDown(() async {
      await OTel.shutdown();
      await OTel.reset();
    });

    test('emits CLIENT span with auth.* attrs', () async {
      await tracedGoogleSignInCall<void>(
        operation: 'sign_in',
        invoke: () async {},
      );

      final span = exporter.spans.single;
      expect(span.kind, equals(SpanKind.client));
      expect(span.name, equals('google_sign_in sign_in'));
      final attrs = _attrs(span);
      expect(attrs['auth.system'], equals('google_sign_in'));
      expect(attrs['auth.operation'], equals('sign_in'));
      expect(attrs['auth.provider'], equals('google.com'));
    });

    test('exception flips span to Error', () async {
      await expectLater(
        tracedGoogleSignInCall<void>(
          operation: 'sign_in',
          invoke: () async => throw StateError('canceled'),
        ),
        throwsStateError,
      );
      expect(exporter.spans.single.status, equals(SpanStatusCode.Error));
    });

    test('runWithoutGoogleSignInInstrumentationAsync bypasses spans', () async {
      await runWithoutGoogleSignInInstrumentationAsync(() async {
        await tracedGoogleSignInCall<void>(
          operation: 'sign_in',
          invoke: () async {},
        );
      });
      expect(exporter.spans, isEmpty);
    });

    test('runWithoutGoogleSignInInstrumentation (sync) bypasses spans',
        () async {
      final future = runWithoutGoogleSignInInstrumentation(
        () => tracedGoogleSignInCall<void>(
          operation: 'sign_out',
          invoke: () async {},
        ),
      );
      await future;
      expect(exporter.spans, isEmpty);
    });

    test('result value passes through unchanged', () async {
      final result = await tracedGoogleSignInCall<int>(
        operation: 'attempt_lightweight_authentication',
        invoke: () async => 42,
      );
      expect(result, equals(42));
      expect(
        exporter.spans.single.name,
        equals('google_sign_in attempt_lightweight_authentication'),
      );
    });
  });

  group('GoogleSignInSemantics', () {
    test('pins the wire-format attribute keys', () {
      expect(GoogleSignInSemantics.authSystem.key, equals('auth.system'));
      expect(GoogleSignInSemantics.authOperation.key, equals('auth.operation'));
      expect(GoogleSignInSemantics.authProvider.key, equals('auth.provider'));
    });
  });
}
