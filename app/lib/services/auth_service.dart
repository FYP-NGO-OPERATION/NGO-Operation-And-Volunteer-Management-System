import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Handles all Firebase Authentication operations.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Stream of auth state changes (login/logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register with email & password
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Login with email & password
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Change password (while logged in)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw 'Google sign-in was cancelled';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Google sign-in failed: $e';
    }
  }

  /// Logout
  Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  /// Delete account
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Verify Phone Number (Sends SMS OTP)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Verify OTP and Link/Sign In
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // If user is already signed in (e.g., via email), link the phone credential
      if (_auth.currentUser != null) {
        // Only link if not already linked
        bool isLinked = _auth.currentUser!.providerData.any(
          (info) => info.providerId == 'phone',
        );
        if (!isLinked) {
          return await _auth.currentUser!.linkWithCredential(credential);
        }
        // If already linked, just reauthenticate or return current user
        // We simulate returning UserCredential by just returning a dummy or throwing if needed.
        // Actually, signInWithCredential works even if already linked if we want to sign in.
      }

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Convert Firebase auth errors to user-friendly messages
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email. Please register.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact admin.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
