import 'package:flutter/foundation.dart';
import '../models/virtual_session_model.dart';
import '../services/virtual_session_service.dart';

class VirtualSessionProvider extends ChangeNotifier {
  final VirtualSessionService _service = VirtualSessionService();

  List<VirtualSessionModel> _sessions = [];
  bool _isLoading = false;
  String? _error;

  List<VirtualSessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clear() {
    _sessions = [];
    _error = null;
    notifyListeners();
  }

  // Real-time subscription
  void init(String ngoId) {
    _isLoading = true;
    notifyListeners();

    _service
        .streamSessionsByNgo(ngoId)
        .listen(
          (data) {
            _sessions = data;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<bool> addSession(VirtualSessionModel session) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.createSession(session);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSession(String sessionId) async {
    try {
      await _service.deleteSession(sessionId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleRSVP(
    String sessionId,
    String userId,
    String userName,
  ) async {
    try {
      await _service.toggleRSVP(sessionId, userId, userName);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> markAttendance(
    String sessionId,
    String userId,
    String userName,
  ) async {
    try {
      await _service.markAttendance(sessionId, userId, userName);
    } catch (e) {
      print("Error marking attendance: $e");
    }
  }
}
