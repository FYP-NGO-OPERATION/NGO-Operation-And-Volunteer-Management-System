import 'package:flutter/foundation.dart';

class DisasterProvider with ChangeNotifier {
  bool _isEmergencyMode = false;

  bool get isEmergencyMode => _isEmergencyMode;

  void toggleEmergencyMode() {
    _isEmergencyMode = !_isEmergencyMode;
    notifyListeners();
  }
}
