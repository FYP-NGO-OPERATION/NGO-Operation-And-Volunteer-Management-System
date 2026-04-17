import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// Manages authentication state across the entire app.
/// Wraps AuthService + UserService together.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // ─── Getters ───
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _authService.isLoggedIn;
  bool get isAdmin => _user?.isAdmin ?? false;
  String? get userId => _authService.currentUserId;

  // ─── Set Loading State ───
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Check Auth State (on app start) ───
  Future<bool> checkAuthState() async {
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) return false;

      _user = await _userService.getUser(firebaseUser.uid);
      if (_user == null) return false;

      // Check if user is active
      if (!_user!.isActive) {
        await _authService.logout();
        _user = null;
        return false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Register ───
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // 1. Create Firebase Auth account
      final credential = await _authService.register(
        email: email,
        password: password,
      );

      // 2. Create user document in Firestore
      final newUser = UserModel(
        uid: credential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: 'volunteer', // Default role
        joinedAt: DateTime.now(),
      );

      await _userService.createUser(newUser);

      // 3. Set current user
      _user = newUser;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ─── Login ───
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // 1. Sign in with Firebase Auth
      final credential = await _authService.login(
        email: email,
        password: password,
      );

      // 2. Get user data from Firestore
      _user = await _userService.getUser(credential.user!.uid);

      if (_user == null) {
        _setError('User profile not found. Please contact admin.');
        _setLoading(false);
        return false;
      }

      // 3. Check if user is active
      if (!_user!.isActive) {
        await _authService.logout();
        _user = null;
        _setError('Your account has been deactivated. Contact admin.');
        _setLoading(false);
        return false;
      }

      // 4. Update last active time
      await _userService.updateUser(_user!.uid, {});

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ─── Forgot Password ───
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.resetPassword(email);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ─── Change Password ───
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ─── Update Profile ───
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    List<String>? skills,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name.trim();
      if (phone != null) updates['phone'] = phone.trim();
      if (address != null) updates['address'] = address.trim();
      if (skills != null) updates['skills'] = skills;

      await _userService.updateUser(_user!.uid, updates);

      // Update local user
      _user = _user!.copyWith(
        name: name,
        phone: phone,
        address: address,
        skills: skills,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ─── Logout ───
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }
}
