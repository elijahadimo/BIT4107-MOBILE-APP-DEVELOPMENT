import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Timer? _timer;

  ConnectivityProvider() {
    _startMonitoring();
  }

  void _startMonitoring() {
    // Check every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await checkConnectivity();
    });
  }

  Future<void> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _setOnline(true);
      }
    } on SocketException catch (_) {
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
