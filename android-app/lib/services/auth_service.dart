import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuition_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'api_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService();
  final fb_auth.FirebaseAuth _fbAuth = fb_auth.FirebaseAuth.instance;
  User? _currentUser;
  String? _verificationId;
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Send OTP via Backend (Fast2SMS/MSG91/Twilio)
  Future<void> sendOtp(String phone) async {
    await _api.post('auth/send-otp', {'phone': phone});
  }

  /// Send OTP via Firebase
  Future<void> sendFirebaseOtp(
    String phone, {
    required Function(String verificationId) onCodeSent,
    required Function(fb_auth.FirebaseAuthException e) onVerificationFailed,
  }) async {
    // Ensure phone has +91 or + country code
    String formattedPhone = phone;
    if (!phone.startsWith('+')) {
      formattedPhone = '+91$phone';
    }

    await _fbAuth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
        // Auto-resolution (on some Android devices)
        // We can handle this by automatically calling verifyFirebaseOtp
      },
      verificationFailed: onVerificationFailed,
      codeSent: (String verId, int? resendToken) {
        _verificationId = verId;
        onCodeSent(verId);
      },
      codeAutoRetrievalTimeout: (String verId) {
        _verificationId = verId;
      },
    );
  }

  /// Verify Firebase OTP and Login
  Future<Map<String, dynamic>> verifyFirebaseOtp(String otp) async {
    if (_verificationId == null) {
      throw Exception('Verification ID not found. Please resend code.');
    }

    fb_auth.PhoneAuthCredential credential = fb_auth.PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    // Sign in to Firebase to get the idToken
    final authResult = await _fbAuth.signInWithCredential(credential);
    final idToken = await authResult.user?.getIdToken();

    if (idToken == null) {
      throw Exception('Failed to retrieve Firebase ID Token');
    }

    // Send idToken to Backend to get Sanctum token
    final response = await _api.post('auth/verify-firebase', {
      'id_token': idToken,
      'phone': authResult.user?.phoneNumber,
    });

    if (response['token'] != null) {
      await _api.saveToken(response['token']);
      if (response['user'] != null) {
        _currentUser = User.fromJson(response['user']);
        notifyListeners();
      }
    }

    return response;
  }

  /// Verify OTP and login
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final response = await _api.post('auth/verify-otp', {
      'phone': phone,
      'otp': otp,
    });
    
    if (response['token'] != null) {
      await _api.saveToken(response['token']);
      if (response['user'] != null) {
        _currentUser = User.fromJson(response['user']);
        notifyListeners();
      }
    }
    
    return response;
  }

  /// Login with email/phone + password
  Future<Map<String, dynamic>> loginWithPassword(String login, String password) async {
    final response = await _api.post('auth/login', {
      'login': login,
      'password': password,
    });
    
    if (response['token'] != null) {
      await _api.saveToken(response['token']);
      if (response['user'] != null) {
        _currentUser = User.fromJson(response['user']);
        notifyListeners();
      }
    }
    
    return response;
  }

  /// Register new user
  Future<void> register(Map<String, dynamic> data) async {
    final response = await _api.post('auth/register', data);
    if (response['token'] != null) {
      await _api.saveToken(response['token']);
      if (response['user'] != null) {
        _currentUser = User.fromJson(response['user']);
        notifyListeners();
      }
    }
  }

  /// Set password (for authenticated users)
  Future<void> setPassword(String password, String passwordConfirmation) async {
    await _api.post('auth/set-password', {
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _api.post('auth/logout', {});
    } catch (_) {
      // Ignore errors if already logged out or token invalid
    } finally {
      await _api.clearToken();
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Check if user is already authenticated (on app launch)
  Future<bool> checkAuthStatus() async {
    await _api.init();
    try {
      final response = await _api.get('profile');
      if (response != null && response['id'] != null) {
        _currentUser = User.fromJson(response);
        notifyListeners();
        return true;
      }
    } catch (e) {
      await _api.clearToken();
    }
    return false;
  }

  /// Reload current user data
  Future<void> loadUser() async {
    try {
      final response = await _api.get('profile');
      if (response != null && response['id'] != null) {
        _currentUser = User.fromJson(response);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }
}
