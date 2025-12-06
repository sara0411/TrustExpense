import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/exceptions.dart' as app_exceptions;

/// Authentication service for Supabase Auth operations
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Register with email and password
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      if (response.user == null) {
        throw app_exceptions.AppAuthException(
          message: 'Registration failed. Please try again.',
        );
      }

      return response.user;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw app_exceptions.AppAuthException(
        message: 'Registration failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Sign in with email and password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw app_exceptions.AppAuthException(
          message: 'Sign in failed. Please check your credentials.',
        );
      }

      return response.user;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw app_exceptions.AppAuthException(
        message: 'Sign in failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw app_exceptions.AppAuthException(
        message: 'Sign out failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw app_exceptions.AppAuthException(
        message: 'Password reset failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update user profile
  Future<void> updateProfile({String? displayName}) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw app_exceptions.AppAuthException(message: 'No user signed in');
      }

      await _supabase.auth.updateUser(
        UserAttributes(
          data: {'display_name': displayName},
        ),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw app_exceptions.AppAuthException(
        message: 'Profile update failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw app_exceptions.AppAuthException(message: 'No user signed in');
      }

      // Note: Supabase doesn't have a direct delete user method in client SDK
      // This would typically be done via a server-side function or admin API
      // For now, we'll sign out and show a message
      await signOut();
      throw app_exceptions.AppAuthException(
        message: 'Account deletion requires admin action. Please contact support.',
      );
    } catch (e) {
      throw app_exceptions.AppAuthException(
        message: 'Account deletion failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Handle Supabase Auth exceptions
  app_exceptions.AppAuthException _handleAuthException(AuthException e) {
    String message;
    
    // Supabase error messages are usually clear, but we can customize them
    final errorMessage = e.message.toLowerCase();
    
    if (errorMessage.contains('invalid login credentials')) {
      message = 'Invalid email or password';
    } else if (errorMessage.contains('email already registered') ||
        errorMessage.contains('user already registered')) {
      message = 'An account already exists with this email';
    } else if (errorMessage.contains('invalid email')) {
      message = 'The email address is invalid';
    } else if (errorMessage.contains('password')) {
      message = 'Password must be at least 6 characters';
    } else if (errorMessage.contains('network')) {
      message = 'Network error. Please check your connection';
    } else if (errorMessage.contains('too many requests')) {
      message = 'Too many attempts. Please try again later';
    } else {
      message = e.message;
    }

    return app_exceptions.AppAuthException(
      message: message,
      code: e.statusCode,
      originalError: e,
    );
  }
}
