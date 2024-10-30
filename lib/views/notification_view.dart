import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'my_custom_views/news_card.dart';
import 'my_custom_views/notification_card.dart';

class NotificationView extends StatefulWidget {
  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => context.read<NotificationViewModel>().refreshData(context));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Color(0xFF323955),
          tabs: [
            Tab(text: localizations.notifications),
            Tab(text: localizations.news),
          ],
        ),
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator()); // Индикатор загрузки
          } else {
            return TabBarView(
              controller: _tabController,
              children: [
                // Уведомления
                viewModel.notificationList.isEmpty
                    ? Center(child: Text(localizations.noNotifications)) // Сообщение, если уведомлений нет
                    : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: viewModel.notificationList.length,
                  itemBuilder: (context, index) {
                    final notification = viewModel.notificationList[index];
                    return NotificationCard(
                      dateTime: notification.dateTime,
                      shortDescription: notification.shortDescription,
                      description: notification.description,
                    );
                  },
                ),

                // Новости
                viewModel.newsList.isEmpty
                    ? Center(child: Text(localizations.noNews)) // Сообщение, если новостей нет
                    : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: viewModel.newsList.length,
                  itemBuilder: (context, index) {
                    final news = viewModel.newsList[index];
                    return NewsCard(
                      dateTime: news.dateTime,
                      shortDescription: news.shortDescription,
                      imageUrl: news.imageUrl,
                      description: news.description,
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
