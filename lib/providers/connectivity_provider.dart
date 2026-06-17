import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Timer? _timer;

  ConnectivityProvider() {
    _startMonitoring();
  }

  void _startMonitoring() {
    // Check every 10 seconds to save battery/bandwidth
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await checkConnectivity();
    });
  }

  Future<void> checkConnectivity() async {
    if (kIsWeb) {
      // On web, we assume online or you could use html.window.navigator.onLine
      // but to keep it simple and dependency-free:
      _setOnline(true);
      return;
    }

    try {
      // Mobile check using dart:io
      final result = await io.InternetAddress.lookup('google.com');
      _setOnline(result.isNotEmpty && result[0].rawAddress.isNotEmpty);
    } catch (_) {
      _setOnline(false);
    }
  }

  void _setOnline(bool status) {
    if (_isOnline != status) {
      _isOnline = status;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
