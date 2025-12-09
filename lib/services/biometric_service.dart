import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> checkBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Por favor autentícate para iniciar sesión',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Biometrics not available
        return false;
      } else if (e.code == auth_error.notEnrolled) {
        // No biometrics enrolled
        return false;
      }
      return false;
    }
  }
}
