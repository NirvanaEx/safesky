import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RequestsView extends StatefulWidget {
  @override
  _RequestsViewState createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> with SingleTickerProviderStateMixin {
  final List<Map<String, String>> _allRequests = [];
  List<Map<String, String>> _filteredRequests = [];
  String _searchQuery = "";

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _isFirstLoad = true;

  final int _loadBatchSize = 10;
  int _currentBatch = 0;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _loadMoreRequests();
    _scrollController.addListener(_onScroll);

    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoadingMore) _loadMoreRequests();
    }
  }

  Future<void> _loadMoreRequests() async {
    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(Duration(seconds: 2));

    List<Map<String, String>> newRequests = List.generate(
      _loadBatchSize,
          (index) => {
        "number": "№ ${135 + _currentBatch * _loadBatchSize + index}SW",
        "status": index % 3 == 0
            ? "confirmed"
            : index % 3 == 1
            ? "pending"
            : "rejected"
      },
    );

    setState(() {
      _isFirstLoad = false;
      _currentBatch++;
      _allRequests.addAll(newRequests);
      _applySearch();
      _isLoadingMore = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applySearch();
    });
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredRequests = _allRequests;
    } else {
      _filteredRequests = _allRequests
          .where((request) => request["number"]!.contains(_searchQuery))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: localizations.search,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
          ),
          if (_isFirstLoad)
            Expanded(child: _buildSkeletonList())
          else if (_filteredRequests.isEmpty && !_isLoadingMore)
            _buildNoDataContainer(localizations)
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _filteredRequests.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _filteredRequests.length) {
                    return _buildLoadingIndicator();
                  }

                  final request = _filteredRequests[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(request['number']!),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(request['status']!),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusText(request['status']!, localizations),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // Скелетон для отображения в виде списка
  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => _buildGradientSkeleton(),
    );
  }

  Widget _buildGradientSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
          stops: [
            _controller.value - 0.3,
            _controller.value,
            _controller.value + 0.3,
          ],
        ).createShader(bounds),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildNoDataContainer(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              localizations.noDataFound,
              style: TextStyle(fontSize: 18, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
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

  String _getStatusText(String status, AppLocalizations localizations) {
    switch (status) {
      case "confirmed":
        return localizations.confirmed;
      case "pending":
        return localizations.pending;
      case "rejected":
        return localizations.rejected;
      default:
        return status;
    }
  }
}
