import 'package:flutter/material.dart';

class LoadingHandler with ChangeNotifier {
  static final LoadingHandler _loadingHandler = LoadingHandler._internal();

  bool loading = true;

  Future<void> finishLoading() {
    loading = false;
    return Future.delayed(const Duration(seconds: 2), () => notifyListeners());
  }

  factory LoadingHandler() {
    return _loadingHandler;
  }

  LoadingHandler._internal();
}
