import 'package:flutter/material.dart';

class WorkerMaganerProvider extends ChangeNotifier {
  int _currentIndex = 0;

  // Getters
  int get currentIndex => _currentIndex;

  WorkerMaganerProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {}

  // Navigation
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
