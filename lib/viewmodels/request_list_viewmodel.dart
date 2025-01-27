import 'package:flutter/material.dart';
import '../services/request_service.dart';
import '../models/request_model_main.dart';

class RequestListViewModel extends ChangeNotifier {
  final List<RequestModelMain> _allRequests = [];
  List<RequestModelMain> _filteredRequests = [];
  String _searchQuery = "";
  bool _isLoadingMore = false;
  bool _isFirstLoad = true;
  int _currentBatch = 0;

  final RequestService _requestService = RequestService(); // Инициализация сервиса здесь

  RequestListViewModel() {
    _initialize();
  }

  List<RequestModelMain> get requests => _filteredRequests;
  bool get isLoadingMore => _isLoadingMore;
  bool get isFirstLoad => _isFirstLoad;

  Future<void> _initialize() async {
    loadInitialRequests();
  }

  void loadInitialRequests() async {
    _isFirstLoad = true;
    notifyListeners();
    await _loadRequests();
    _isFirstLoad = false;
    notifyListeners();
  }

  Future<void> loadMoreRequests() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    await _loadRequests();

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> _loadRequests() async {
    try {
      final newRequests = await _requestService.fetchMainRequests(page: _currentBatch + 1, count: 20);
      print("Loaded requests: ${newRequests.length}");

      _allRequests.addAll(
        newRequests.where((newRequest) => !_allRequests.any((existingRequest) => existingRequest.planId == newRequest.planId)),
      );

      print("Total stored requests: ${_allRequests.length}");

      _currentBatch++;
      applySearch();
    } catch (e) {
      print('Error loading requests: $e');
    }
  }

  void refreshRequests() {
    _allRequests.clear();
    _filteredRequests.clear();
    _currentBatch = 0;
    loadInitialRequests();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    applySearch();
  }

  void applySearch() {
    _filteredRequests = _searchQuery.isEmpty
        ? List.from(_allRequests)
        : _allRequests
        .where((request) => request.applicationNum.contains(_searchQuery))
        .toList();
    notifyListeners();
  }

  Color getStatusColor(int stateId) {
    switch (stateId) {
      case 1:
        return Colors.orangeAccent; // На рассмотрении
      case 2:
        return Colors.greenAccent;  // Зарегистрирован
      case 3:
        return Colors.blueAccent;    // Отменён (подходит синий оттенок, ассоциирующийся со спокойствием)
      case 4:
        return Colors.redAccent; // Отклонён
      default:
        return Colors.grey;
    }
  }
}
