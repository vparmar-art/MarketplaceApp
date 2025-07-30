import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

// Web-specific imports for cross-tab sync
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

// Web storage event handling - conditional import
import 'dart:html' as html;

class AuthService extends ChangeNotifier {
  final ApiService _apiService;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? _userProfile;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser;
  Map<String, dynamic>? get userProfile => _userProfile;

  AuthService(this._apiService) {
    _initialize();
    _setupCrossTabSync();
  }
  
  Future<void> _initialize() async {
    await _apiService.ensureInitialized();
    await _checkAuthStatus();
  }
  
  bool _authCheckComplete = false;
  
  Future<void> waitForAuthCheck() async {
    while (!_authCheckComplete) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null && token.isNotEmpty) {
        try {
          final userProfile = await _apiService.getUserProfile();
          _userProfile = userProfile;
          _currentUser = {
            'id': userProfile['user'],
            'username': userProfile['username'] ?? '',
            'email': userProfile['email'] ?? '',
          };
          _isAuthenticated = true;
          notifyListeners();
        } catch (e) {
          // Token is invalid or expired
          await logout();
        }
      }
    } catch (e) {
      await logout();
    } finally {
      _authCheckComplete = true;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);
      
      _currentUser = response['user'];
      await _fetchUserProfile();
      _isAuthenticated = true;
      _authCheckComplete = true;
      notifyListeners();
      
      // Trigger storage event for cross-tab sync
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final storedToken = prefs.getString('auth_token');
        if (storedToken != null) {
          await prefs.setString('auth_token', storedToken);
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      await _apiService.register(username, email, password);
      return await login(username, password);
    } catch (e) {
      if (kDebugMode) {
        print('Registration error: $e');
      }
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Handle logout error silently
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _userProfile = null;
      
      // Clear token and trigger cross-tab sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      
      notifyListeners();
    }
  }

  void _setupCrossTabSync() {
    if (!kIsWeb) return;
    
    try {
      // Listen for storage events to sync auth state across tabs
      html.window.onStorage.listen((event) {
        if (event.key == 'auth_token') {
          // Handle token changes from other tabs
          if (event.newValue != null && event.newValue!.isNotEmpty) {
            // Token was added/updated in another tab - revalidate
            _checkAuthStatus();
          } else if (event.newValue == null || event.newValue!.isEmpty) {
            // Token was removed in another tab - log out this tab
            if (_isAuthenticated) {
              _isAuthenticated = false;
              _currentUser = null;
              _userProfile = null;
              notifyListeners();
            }
          }
        }
      });
    } catch (e) {
      // Cross-tab sync setup error handled silently
    }
  }

  // Method to manually trigger cross-tab sync (for testing)
  void triggerCrossTabSync() {
    if (kIsWeb) {
      // Dispatch a custom event for testing
      final event = html.StorageEvent('storage', key: 'auth_token', newValue: 'sync');
      html.window.dispatchEvent(event);
    }
  }

  // Helper method to safely access html.window
  html.Window? get _window => kIsWeb ? html.window : null;

  Future<void> _fetchUserProfile() async {
    try {
      _userProfile = await _apiService.getUserProfile();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      _userProfile = await _apiService.updateUserProfile(data);
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      return false;
    }
  }
}