import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isOwner => _user?.isOwner ?? false;
  bool get isCashier => _user?.isCashier ?? false;
  bool get isManager => _user?.isManager ?? false;

  AuthProvider() {
    checkAuthState();
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _firebaseUser = user;
    if (user != null) {
      _loadUserData();
    } else {
      _user = null;
    }
    notifyListeners();
  }

  Future<void> checkAuthState() async {
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser != null) {
      await _loadUserData();
      await _updateLastLogin();
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        _setError('Please enter both email and password');
        return false;
      }

      if (!_isValidEmail(email)) {
        _setError('Please enter a valid email address');
        return false;
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _firebaseUser = credential.user;

      if (_firebaseUser != null) {
        await _loadUserData();
        await _updateLastLogin();

        // Save login session locally
        final box = Hive.box(AppConstants.settingsBox);
        await box.put('user_id', _firebaseUser!.uid);
        await box.put('user_email', _firebaseUser!.email);
        await box.put('last_login', DateTime.now().toIso8601String());
        await box.put('auto_login', true);

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      debugPrint('Sign in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String shopName,
    String phone = '',
    String role = 'owner',
    String shopAddress = '',
    String shopPhone = '',
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Validate inputs
      if (email.isEmpty ||
          password.isEmpty ||
          name.isEmpty ||
          shopName.isEmpty) {
        _setError('Please fill in all required fields');
        return false;
      }

      if (!_isValidEmail(email)) {
        _setError('Please enter a valid email address');
        return false;
      }

      if (password.length < 6) {
        _setError('Password must be at least 6 characters long');
        return false;
      }

      if (name.length < 2) {
        _setError('Name must be at least 2 characters long');
        return false;
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        _firebaseUser = credential.user;

        // Create user document in Firestore
        _user = UserModel(
          id: credential.user!.uid,
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          role: role,
          shopName: shopName.trim(),
          shopAddress: shopAddress.trim(),
          shopPhone: shopPhone.trim(),
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isActive: true,
          permissions: UserModel.getDefaultPermissions(role),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(_user!.id)
            .set(_user!.toMap());

        // Update Firebase Auth display name
        await _firebaseUser!.updateDisplayName(name.trim());

        // Send email verification
        if (!_firebaseUser!.emailVerified) {
          await _firebaseUser!.sendEmailVerification();
        }

        // Save login session
        final box = Hive.box(AppConstants.settingsBox);
        await box.put('user_id', _firebaseUser!.uid);
        await box.put('user_email', _firebaseUser!.email);
        await box.put('last_login', DateTime.now().toIso8601String());

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred during registration');
      debugPrint('Sign up error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);

      await _auth.signOut();
      _firebaseUser = null;
      _user = null;

      // Clear local data
      final box = Hive.box(AppConstants.settingsBox);
      await box.delete('user_id');
      await box.delete('user_email');
      await box.delete('last_login');
      await box.delete('auto_login');

      // Clear cache box
      final cacheBox = Hive.box(AppConstants.cacheBox);
      await cacheBox.clear();

      notifyListeners();
    } catch (e) {
      _setError('Error signing out. Please try again.');
      debugPrint('Sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      if (email.isEmpty) {
        _setError('Please enter your email address');
        return false;
      }

      if (!_isValidEmail(email)) {
        _setError('Please enter a valid email address');
        return false;
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      debugPrint('Reset password error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? shopEmail,
    String? gstNumber,
  }) async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updatedUser = _user!.copyWith(
        name: name?.trim(),
        phone: phone?.trim(),
        shopName: shopName?.trim(),
        shopAddress: shopAddress?.trim(),
        shopPhone: shopPhone?.trim(),
        shopEmail: shopEmail?.trim(),
        gstNumber: gstNumber?.trim(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_user!.id)
          .update(updatedUser.toMap());

      // Update Firebase Auth display name if name changed
      if (name != null && name.trim() != _user!.name) {
        await _firebaseUser?.updateDisplayName(name.trim());
      }

      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error updating profile. Please try again.');
      debugPrint('Update profile error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_firebaseUser == null) return false;

    try {
      _setLoading(true);
      _clearError();

      if (currentPassword.isEmpty || newPassword.isEmpty) {
        _setError('Please enter both current and new passwords');
        return false;
      }

      if (newPassword.length < 6) {
        _setError('New password must be at least 6 characters long');
        return false;
      }

      if (currentPassword == newPassword) {
        _setError('New password must be different from current password');
        return false;
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: _firebaseUser!.email!,
        password: currentPassword,
      );

      await _firebaseUser!.reauthenticateWithCredential(credential);

      // Update to new password
      await _firebaseUser!.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      debugPrint('Change password error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendEmailVerification() async {
    if (_firebaseUser == null) return false;

    try {
      _setLoading(true);

      if (_firebaseUser!.emailVerified) {
        _setError('Email is already verified');
        return false;
      }

      await _firebaseUser!.sendEmailVerification();
      return true;
    } catch (e) {
      _setError('Error sending verification email. Please try again.');
      debugPrint('Send email verification error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> reloadUser() async {
    if (_firebaseUser == null) return false;

    try {
      await _firebaseUser!.reload();
      _firebaseUser = _auth.currentUser;
      await _loadUserData();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Reload user error: $e');
      return false;
    }
  }

  Future<bool> deleteAccount(String password) async {
    if (_firebaseUser == null) return false;

    try {
      _setLoading(true);
      _clearError();

      // Re-authenticate before deletion
      final credential = EmailAuthProvider.credential(
        email: _firebaseUser!.email!,
        password: password,
      );

      await _firebaseUser!.reauthenticateWithCredential(credential);

      // Delete user document from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_firebaseUser!.uid)
          .delete();

      // Delete Firebase Auth account
      await _firebaseUser!.delete();

      // Clear local data
      await signOut();

      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Error deleting account. Please try again.');
      debugPrint('Delete account error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData() async {
    if (_firebaseUser == null) return;

    try {
      final doc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(_firebaseUser!.uid)
              .get();

      if (doc.exists) {
        _user = UserModel.fromDocument(doc);
      } else {
        // Create default user document if doesn't exist
        _user = UserModel(
          id: _firebaseUser!.uid,
          name: _firebaseUser!.displayName ?? 'User',
          email: _firebaseUser!.email ?? '',
          shopName: 'My Shop',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isEmailVerified: _firebaseUser!.emailVerified,
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(_user!.id)
            .set(_user!.toMap());
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _updateLastLogin() async {
    if (_user == null) return;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_user!.id)
          .update({
            'lastLoginAt': DateTime.now().toIso8601String(),
            'isEmailVerified': _firebaseUser?.emailVerified ?? false,
          });

      _user = _user!.copyWith(
        lastLoginAt: DateTime.now(),
        isEmailVerified: _firebaseUser?.emailVerified ?? false,
      );
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }

  // Permission checks
  bool hasPermission(String permission) {
    return _user?.hasPermission(permission) ?? false;
  }

  bool get canManageProducts => hasPermission('manage_products');
  bool get canViewReports => hasPermission('view_reports');
  bool get canManageCustomers => hasPermission('manage_customers');
  bool get canProcessRefunds => hasPermission('process_refunds');
  bool get canManageUsers => hasPermission('manage_users');
  bool get canManageSettings => hasPermission('manage_settings');
  bool get canDeleteSales => hasPermission('delete_sales');
  bool get canGiveDiscounts => hasPermission('give_discounts');

  // Auto login check
  Future<bool> hasAutoLoginEnabled() async {
    try {
      final box = Hive.box(AppConstants.settingsBox);
      return box.get('auto_login', defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  Future<void> setAutoLogin(bool enabled) async {
    try {
      final box = Hive.box(AppConstants.settingsBox);
      await box.put('auto_login', enabled);
    } catch (e) {
      debugPrint('Error setting auto login: $e');
    }
  }

  // Validation helpers
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address';
      case 'wrong-password':
        return 'Incorrect password. Please try again';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password should be at least 6 characters long';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled. Contact support';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'requires-recent-login':
        return 'Please sign out and sign in again to perform this action';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password';
      default:
        return 'Authentication failed. Please try again';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
