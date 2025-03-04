import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                    hintText: localizations.requestListView_search,
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    filled: true,
                  ),
                ),
              ),
              if (viewModel.isFirstLoad)
                Expanded(child: _buildSkeletonList())
              else if (viewModel.requests.isEmpty && !viewModel.isLoadingMore)
                Expanded(
                  child: SmartRefresher(
                    controller: _refreshController,
                    onRefresh: () {
                      viewModel.refreshRequests();
                      _refreshController.refreshCompleted();
                    },
                    enablePullDown: true,
                    child: _buildNoDataContainer(localizations),
                  ),
                )
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
                          return _buildLoadingIndicator();
                        }
                        final request = viewModel.requests[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ListTile(
                                title: Text("№ ${request.applicationNum}",
                                    style: Theme.of(context).textTheme.bodyLarge),
                                subtitle: Text(
                                  DateFormat('dd.MM.yyyy').format(DateTime.parse(request.planDate)),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: viewModel.getStatusColor(request.stateId),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getLocalizedStatus(request.stateId, localizations),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShowRequestView(
                                        requestId: request.planId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
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
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 50, color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
            const SizedBox(height: 10),
            Text(
              localizations.requestListView_noDataFound,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedStatus(int stateId, AppLocalizations localizations) {
    switch (stateId) {
      case 1:
        return localizations.pending;
      case 2:
        return localizations.confirmed;
      case 3:
        return localizations.canceled;
      case 4:
        return localizations.rejected;
      default:
        return "unknown";
    }
  }
}
