import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectionProvider with ChangeNotifier {
  bool _isConnected = true;
  bool _showBanner = false;
  bool _hasGoodSpeed = true;
  final Connectivity _connectivity = Connectivity();
  Timer? _autoHideTimer;
  
  static const double MIN_SPEED_KBPS = 1.0;

  bool get isConnected => _isConnected; 
  bool get showBanner => _showBanner;
  bool get hasGoodSpeed => _hasGoodSpeed;

  ConnectionProvider() {
    _init();
  }

  Future<void> _init() async {
    await _checkConnection();
    _connectivity.onConnectivityChanged.listen((_) => _checkConnection());
  }

  Future<void> _checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final newConnected = result != ConnectivityResult.none;
      
      bool newGoodSpeed = false;
      if (newConnected) {
        newGoodSpeed = await _checkConnectionSpeed();
      }
      
      if (newConnected != _isConnected || newGoodSpeed != _hasGoodSpeed) {
        _isConnected = newConnected;
        _hasGoodSpeed = newGoodSpeed;
        _updateBannerState();
        
        _autoHideTimer?.cancel();
        if (_isConnected && _hasGoodSpeed) {
          _autoHideTimer = Timer(const Duration(seconds: 3), () {
            if (_isConnected && _hasGoodSpeed && _showBanner) {
              _showBanner = false;
              notifyListeners();
            }
          });
        }
      }
    } catch (e) {
      _handleConnectionError();
    }
  }

  Future<bool> _checkConnectionSpeed() async {
    try {
      const timeoutDuration = Duration(seconds: 5);
      final stopwatch = Stopwatch()..start();
      
      final request = await HttpClient()
        .getUrl(Uri.parse('https://www.gstatic.com/generate_204'))
        .timeout(timeoutDuration);
      
      final response = await request.close();
      await response.drain();
      stopwatch.stop();

      const estimatedSizeKB = 2.0;
      final speed = estimatedSizeKB / (stopwatch.elapsedMilliseconds / 1000);
      
      return speed >= MIN_SPEED_KBPS;
    } catch (e) {
      return false;
    }
  }

  void _updateBannerState() {
    final newState = !_isConnected || !_hasGoodSpeed;
    if (_showBanner != newState) {
      _showBanner = newState;
      notifyListeners();
    }
  }

  void _handleConnectionError() {
    _isConnected = false;
    _hasGoodSpeed = false;
    _showBanner = true;
    notifyListeners();
  }

  Future<void> manualCheck() async {
    _showBanner = true;
    notifyListeners();
    await _checkConnection();
    
    _autoHideTimer?.cancel();
    if (_isConnected && _hasGoodSpeed) {
      _autoHideTimer = Timer(const Duration(seconds: 3), () {
        if (_isConnected && _hasGoodSpeed && _showBanner) {
          _showBanner = false;
          notifyListeners();
        }
      });
    }
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    super.dispose();
  }
}