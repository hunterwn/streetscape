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

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final loadingHandler = LoadingHandler();

  @override
  Widget build(BuildContext context) {
    if (loadingHandler.loading) {
      loadingHandler.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
    if (loadingHandler.loading) {
      return Container(
          color: Colors.black, child: const Center(child: Text("Loading...")));
    } else {
      return Container();
    }
  }
}
