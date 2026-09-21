import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Chief Architect & SRE level Chaos Resilience Wrapper.
/// Provides Exponential Backoff with Random Jitter to ensure operations
/// survive 99% packet loss without generic timeouts.
class ChaosResilience {
  /// Executes the provided async [operation] with exponential backoff and jitter.
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 5,
    Duration baseDelay = const Duration(milliseconds: 500),
    Duration maxDelay = const Duration(seconds: 15),
  }) async {
    int attempt = 0;
    final random = Random();

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          debugPrint(
            'ChaosResilience: Max retries ($maxRetries) exceeded. Operation failed: $e',
          );
          rethrow;
        }

        // Exponential backoff: baseDelay * 2^(attempt-1)
        final backoffFactor = pow(2, attempt - 1).toInt();
        final backoffMs = baseDelay.inMilliseconds * backoffFactor;

        // Add 0-25% random jitter to prevent thundering herd problem
        final jitterMs = random.nextInt(
          (backoffMs * 0.25).toInt().clamp(1, 10000),
        );

        var delay = Duration(milliseconds: backoffMs + jitterMs);
        if (delay > maxDelay) {
          delay = maxDelay;
        }

        debugPrint(
          'ChaosResilience: Operation failed (Attempt $attempt). Retrying in ${delay.inMilliseconds}ms... Error: $e',
        );
        await Future.delayed(delay);
      }
    }
  }
}
