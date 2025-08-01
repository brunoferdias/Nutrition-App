// lib/core/providers/message_provider.dart

import 'package:flutter/material.dart';

class MessageProvider with ChangeNotifier {
  String _productName = '';
  String get productName => _productName;
  void setProductName(String value) {
    _productName = value;
    notifyListeners();
  }
}
