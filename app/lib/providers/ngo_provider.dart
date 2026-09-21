import 'package:flutter/material.dart';
import '../models/ngo_model.dart';
import '../models/user_model.dart';
import '../services/ngo_service.dart';
import '../services/user_service.dart';

class NgoProvider extends ChangeNotifier {
  final NgoService _ngoService = NgoService();
  final UserService _userService = UserService();

  List<NgoModel> _ngos = [];
  NgoModel? _currentNgo;
  bool _isLoading = false;

  List<NgoModel> get ngos => _ngos;
  NgoModel? get currentNgo => _currentNgo;
  bool get isLoading => _isLoading;

  /// Load NGO for the user based on their currentNgoId
  Future<void> loadNgoForUser(UserModel user) async {
    if (user.currentNgoId == null || user.currentNgoId!.isEmpty) {
      _currentNgo = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _currentNgo = await _ngoService.getNgo(user.currentNgoId!);

    _isLoading = false;
    notifyListeners();
  }

  /// Select an NGO and update the user's currentNgoId
  Future<bool> selectNgo(UserModel user, NgoModel ngo) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.updateUser(user.uid, {'currentNgoId': ngo.id});
      _currentNgo = ngo;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Deselect NGO (leave NGO space)
  Future<void> clearNgo(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.updateUser(user.uid, {'currentNgoId': null});
      _currentNgo = null;
    } catch (e) {
      // Ignore
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new NGO
  Future<NgoModel?> createNgo(NgoModel ngo) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newNgo = await _ngoService.createNgo(ngo);
      _isLoading = false;
      notifyListeners();
      return newNgo;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Fetch all NGOs
  Future<void> fetchAllNgos() async {
    _isLoading = true;
    notifyListeners();
    try {
      _ngos = await _ngoService.getAllNgos();
    } catch (e) {
      // ignore
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update NGO Status
  Future<bool> updateNgoStatus(String ngoId, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _ngoService.updateNgo(ngoId, {'status': status});
      final index = _ngos.indexWhere((n) => n.id == ngoId);
      if (index != -1) {
        _ngos[index] = NgoModel(
          id: _ngos[index].id,
          name: _ngos[index].name,
          description: _ngos[index].description,
          primaryColorHex: _ngos[index].primaryColorHex,
          logoUrl: _ngos[index].logoUrl,
          adminId: _ngos[index].adminId,
          status: status,
          features: _ngos[index].features,
          createdAt: _ngos[index].createdAt,
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update NGO Profile (Settings)
  Future<bool> updateNgoProfile(String ngoId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _ngoService.updateNgo(ngoId, data);

      // Update in local list
      final index = _ngos.indexWhere((n) => n.id == ngoId);
      if (index != -1) {
        final existing = _ngos[index];
        _ngos[index] = NgoModel(
          id: existing.id,
          name: data['name'] ?? existing.name,
          description: data['description'] ?? existing.description,
          primaryColorHex: data['primaryColorHex'] ?? existing.primaryColorHex,
          secondaryColorHex:
              data['secondaryColorHex'] ?? existing.secondaryColorHex,
          logoUrl: data['logoUrl'] ?? existing.logoUrl,
          bannerUrl: data['bannerUrl'] ?? existing.bannerUrl,
          adminId: existing.adminId,
          status: existing.status,
          features: existing.features,
          createdAt: existing.createdAt,
          welcomeText: data['welcomeText'] ?? existing.welcomeText,
          missionStatement:
              data['missionStatement'] ?? existing.missionStatement,
          websiteUrl: data['websiteUrl'] ?? existing.websiteUrl,
        );
      }

      // Update currentNgo if it's the one being modified
      if (_currentNgo?.id == ngoId) {
        _currentNgo = NgoModel(
          id: _currentNgo!.id,
          name: data['name'] ?? _currentNgo!.name,
          description: data['description'] ?? _currentNgo!.description,
          primaryColorHex:
              data['primaryColorHex'] ?? _currentNgo!.primaryColorHex,
          secondaryColorHex:
              data['secondaryColorHex'] ?? _currentNgo!.secondaryColorHex,
          logoUrl: data['logoUrl'] ?? _currentNgo!.logoUrl,
          bannerUrl: data['bannerUrl'] ?? _currentNgo!.bannerUrl,
          adminId: _currentNgo!.adminId,
          status: _currentNgo!.status,
          features: _currentNgo!.features,
          createdAt: _currentNgo!.createdAt,
          welcomeText: data['welcomeText'] ?? _currentNgo!.welcomeText,
          missionStatement:
              data['missionStatement'] ?? _currentNgo!.missionStatement,
          websiteUrl: data['websiteUrl'] ?? _currentNgo!.websiteUrl,
          geminiApiKey: data['geminiApiKey'] ?? _currentNgo!.geminiApiKey,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
