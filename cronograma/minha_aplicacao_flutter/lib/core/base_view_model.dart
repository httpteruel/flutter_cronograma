// lib/core/base_view_model.dart

import 'package:flutter/material.dart';

enum ViewState { idle, busy, error }

class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _state == ViewState.busy;
  bool get hasError => _state == ViewState.error && _errorMessage != null;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    setState(ViewState.error);
  }

  void clearErrorMessage() {
    _errorMessage = null;
    if (_state == ViewState.error) {
      setState(ViewState.idle);
    }
  }
}
