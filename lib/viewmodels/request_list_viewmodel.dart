import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/request_service.dart';
import '../models/request_model.dart';

class RequestListViewModel extends ChangeNotifier {
  final List<RequestModel> _allRequests = [];
  List<RequestModel> _filteredRequests = [];
  String _searchQuery = "";
  bool _isLoadingMore = false;
  bool _isFirstLoad = true;
  int _currentBatch = 0;

  RequestModel? requestModel;

  final RequestService _requestService = RequestService(); // Инициализация сервиса здесь
  String? _token;

  RequestListViewModel() {
    _initialize();
  }

  List<RequestModel> get requests => _filteredRequests;
  bool get isLoadingMore => _isLoadingMore;
  bool get isFirstLoad => _isFirstLoad;

  Future<void> _initialize() async {
    _token = await _fetchToken(); // Получаем токен
    loadInitialRequests();
  }

  Future<String?> _fetchToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token'); // Получаем токен из SharedPreferences
    return token; // Возвращаем реальный токен, если он сохранен
  }

  void loadInitialRequests() async {
    if (_token == null) return; // Ждем токен перед началом загрузки
    _isFirstLoad = true;
    await _loadRequests();
    _isFirstLoad = false;
  }

  Future<void> loadMoreRequests() async {
    if (_isLoadingMore || _token == null) return; // Ждем токен
    _isLoadingMore = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 400));
    await _loadRequests();

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> _loadRequests() async {
    final newRequests = await _requestService.fetchRequests(_token!, batch: _currentBatch, batchSize: 20);
    _allRequests.addAll(
      newRequests.where((newRequest) => !_allRequests.any((existingRequest) => existingRequest.id == newRequest.id)),
    );
    _currentBatch++;
    applySearch();
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
        .where((request) => request.number?.contains(_searchQuery) ?? false)
        .toList();
    notifyListeners();
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case "confirmed":
        return Colors.greenAccent;
      case "pending":
        return Colors.orangeAccent;
      case "rejected":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
