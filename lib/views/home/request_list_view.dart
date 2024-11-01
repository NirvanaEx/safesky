import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../viewmodels/request_list_viewmodel.dart';
import '../show_request_view.dart';

class RequestListView extends StatefulWidget {
  @override
  _RequestListViewState createState() => _RequestListViewState();
}

class _RequestListViewState extends State<RequestListView> {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final viewModel = Provider.of<RequestListViewModel>(context, listen: false);
    if (!_scrollController.hasClients || viewModel.isLoadingMore) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      viewModel.loadMoreRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Consumer<RequestListViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: viewModel.onSearchChanged,
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
              if (viewModel.isFirstLoad)
                Expanded(child: _buildSkeletonList())
              else if (viewModel.requests.isEmpty && !viewModel.isLoadingMore)
                _buildNoDataContainer(localizations)
              else
                Expanded(
                  child: SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () async {
                      viewModel.refreshRequests();
                      _refreshController.refreshCompleted();
                    },
                    enablePullDown: true,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: viewModel.requests.length + (viewModel.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= viewModel.requests.length) {
                          return _buildLoadingIndicator(); // Показ индикатора, если идет загрузка
                        }
                        final request = viewModel.requests[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              clipBehavior: Clip.antiAlias, // Обрезка содержимого по границам
                              child: ListTile(
                                title: Text("№ ${request.number}"),
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: viewModel.getStatusColor(request.status),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    request.status != null
                                        ? (request.status == 'confirmed'
                                        ? localizations.confirmed
                                        : request.status == 'pending'
                                        ? localizations.pending
                                        : localizations.rejected)
                                        : '',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShowRequestView(
                                        requestModel: request,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
}
