import 'dart:async';
import 'package:flutter/material.dart';
import '../models/campaign_model.dart';
import '../services/campaign_service.dart';
import '../enums/app_enums.dart';

/// State management for campaigns.
class CampaignProvider extends ChangeNotifier {
  final CampaignService _campaignService = CampaignService();

  // ─── State ───
  List<CampaignModel> _campaigns = [];
  CampaignModel? _selectedCampaign;
  bool _isLoading = false;
  String? _error;
  CampaignStatus? _statusFilter;
  String _searchQuery = '';
  StreamSubscription? _campaignsSubscription;

  // ─── Getters ───
  List<CampaignModel> get campaigns => _filteredCampaigns;
  List<CampaignModel> get allCampaigns => _campaigns;
  CampaignModel? get selectedCampaign => _selectedCampaign;
  bool get isLoading => _isLoading;
  String? get error => _error;
  CampaignStatus? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  int get totalCampaigns => _campaigns.length;
  int get activeCampaigns => _campaigns.where((c) => c.isActive).length;
  int get completedCampaigns => _campaigns.where((c) => c.isCompleted).length;
  int get upcomingCampaigns => _campaigns.where((c) => c.isUpcoming).length;

  double get totalDonationsOverall => _campaigns.fold(0, (sum, c) => sum + c.totalDonationsAmount);
  int get totalBeneficiariesOverall => _campaigns.fold(0, (sum, c) => sum + c.beneficiaryCount);
  int get totalItemsDistributedOverall => _campaigns.fold(0, (sum, c) => sum + c.distributionCount);

  /// Filtered list based on status filter and search query
  List<CampaignModel> get _filteredCampaigns {
    var list = _campaigns.toList();

    // Apply status filter
    if (_statusFilter != null) {
      list = list.where((c) => c.status == _statusFilter).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) =>
          c.title.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  // ─── Initialize — subscribe to real-time updates ───
  void init() {
    _setLoading(true);
    _campaignsSubscription?.cancel();
    _campaignsSubscription = _campaignService.getCampaignsStream().listen(
      (campaigns) {
        _campaigns = campaigns;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ─── Filter & Search ───
  void setStatusFilter(CampaignStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  // ─── Create Campaign ───
  Future<bool> createCampaign(CampaignModel campaign) async {
    try {
      _setLoading(true);
      await _campaignService.createCampaign(campaign);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to create campaign: $e');
      return false;
    }
  }

  // ─── Update Campaign ───
  Future<bool> updateCampaign(CampaignModel campaign) async {
    try {
      _setLoading(true);
      await _campaignService.updateCampaign(campaign);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update campaign: $e');
      return false;
    }
  }

  // ─── Update Status ───
  Future<bool> updateStatus(String campaignId, CampaignStatus status) async {
    try {
      await _campaignService.updateCampaignStatus(campaignId, status);
      return true;
    } catch (e) {
      _setError('Failed to update status: $e');
      return false;
    }
  }

  // ─── Delete Campaign ───
  Future<bool> deleteCampaign(String campaignId) async {
    try {
      _setLoading(true);
      await _campaignService.deleteCampaign(campaignId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete campaign: $e');
      return false;
    }
  }

  // ─── Select Campaign (for detail view) ───
  void selectCampaign(CampaignModel campaign) {
    _selectedCampaign = campaign;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCampaign = null;
    notifyListeners();
  }

  // ─── Helpers ───
  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _campaignsSubscription?.cancel();
    super.dispose();
  }
}
