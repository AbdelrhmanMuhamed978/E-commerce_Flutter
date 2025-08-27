import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/jwt_helper.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  User? _user;
  bool _isLoading = false;
  String? _token;

  AuthProvider(this._apiService, this._prefs) {
    _initializeAuth();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  String? get token => _token; // Add token getter for admin operations
  // Updated admin check to use userType ObjectId
  // Replace "68486185d89a99ebb571c241" with your actual admin userType ObjectId
  bool get isAdmin => _user?.userType == "68486185d89a99ebb571c241";

  Future<void> _initializeAuth() async {
    _token = _prefs.getString('token');
    if (_token != null) {
      _apiService.setToken(_token!);

      // Decode JWT token to get user information
      try {
        final jwtPayload = JwtHelper.decodeJWT(_token!);

        if (jwtPayload.isNotEmpty) {
          _user = User.fromJWT(jwtPayload);

          // Fetch user's avatar after loading from JWT
          await fetchUserAvatar();
        }
      } catch (e) {
        // If JWT decoding fails, clear the token
        _token = null;
        _prefs.remove('token');
      }
    }
    notifyListeners();
  }

  // Fetch current user's avatar
  Future<void> fetchUserAvatar() async {
    if (_user == null) return;

    try {
      final response = await _apiService.getUserAvatar();
      if (response['data'] != null && response['data']['avatar'] != null) {
        _user = User(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          role: _user!.role,
          userType: _user!.userType,
          avatar: response['data']['avatar'],
        );
        notifyListeners();
      }
    } catch (e) {
      // Avatar fetch failure shouldn't affect the user session
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);

      // Handle the nested response structure
      if ((response['status'] == 'success' ||
              response['status'] == 'success1') &&
          response['data'] != null) {
        _token = response['data']['data']; // The JWT token is in data.data

        // Decode JWT token to get real user information
        try {
          final jwtPayload = JwtHelper.decodeJWT(_token!);

          if (jwtPayload.isNotEmpty) {
            _user = User.fromJWT(jwtPayload);
          } else {
            // Fallback to basic user object if JWT doesn't contain user data
            _user = User(
              id: '',
              name: email.split('@')[0],
              email: email,
              role: 'user',
            );
          }
        } catch (e) {
          // Fallback to basic user object
          _user = User(
            id: '',
            name: email.split('@')[0],
            email: email,
            role: 'user',
          );
        }

        await _prefs.setString('token', _token!);
        _apiService.setToken(_token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.register({
        'name': name,
        'email': email,
        'password': password,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String password, // Current password is always required
    String? newPassword, // Optional new password
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.updateProfile(
        name: name,
        email: email,
        password: password, // Current password
        newPassword: newPassword, // Optional new password
      );

      // Update the local user object
      if (_user != null) {
        _user = User(
          id: _user!.id,
          name: name,
          email: email,
          role: _user!.role,
          avatar: _user!.avatar,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Profile update error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Avatar Management - Cross-platform avatar upload using bytes
  Future<bool> uploadAvatarBytes(
      Uint8List bytes, String fileName, String mimeType) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await _apiService.uploadAvatar(bytes, fileName, mimeType);

      // Update the local user object with new avatar
      if (_user != null && response['data'] != null) {
        final userData = response['data']['user'];
        _user = User(
          id: _user!.id,
          name: userData['name'] ?? _user!.name,
          email: userData['email'] ?? _user!.email,
          role: _user!.role,
          avatar: userData['avatar'],
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Avatar upload error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> getUserAvatar() async {
    try {
      final response = await _apiService.getUserAvatar();
      if (response['data'] != null && response['data']['avatar'] != null) {
        return response['data']['avatar'];
      }
      return null;
    } catch (e) {
      print('Get avatar error: $e');
      return null;
    }
  }

  Future<bool> deleteAvatar() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteAvatar();

      // Update the local user object to remove avatar
      if (_user != null) {
        _user = User(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          role: _user!.role,
          avatar: null,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Avatar delete error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String? getAvatarUrl() {
    if (_user?.avatar != null) {
      return _apiService.getAvatarUrl(_user!.avatar!);
    }
    return null;
  }

  void logout() {
    _token = null;
    _user = null;
    _prefs.remove('token');
    notifyListeners();
  }
}
