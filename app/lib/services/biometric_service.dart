import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate({String reason = 'Please authenticate to proceed'}) async {
    try {
      // Check if device supports biometrics
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        debugPrint('Biometrics not supported on this device.');
        return false; // Or true if you want to allow fallback when unsupported. We strictly return false for Finance locks.
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // fallback to device credentials
          stickyAuth: true,
        ),
      );
      
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Biometric Error: ${e.message}');
      return false;
    }
  }
}
