import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plan_detail_model.dart';
import '../models/request_model.dart';
import '../models/area_point_location_model.dart';
import '../services/request_service.dart';
import '../utils/enums.dart';
import '../views/map/map_share_location_view.dart';

import 'package:provider/provider.dart';
import '../viewmodels/map_share_location_viewmodel.dart';
import '../models/request/status_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ShowRequestViewModel extends ChangeNotifier {
  RequestModel? requestModel;
  PlanDetailModel? planDetailModel;
  bool isSharing = false;
  final requestService = RequestService();
  bool isLoading = false;  // Флаг загрузки

  // Загрузить данные о заявке (пример, если нужно)
  Future<void> loadRequest(int requestId) async {
    isLoading = true;
    notifyListeners();
    try {
      planDetailModel = await requestService.fetchPlanDetail(requestId);
    } catch (e) {
      print('Error loading request: $e');
    } finally {
      isLoading = false;
      notifyListeners(); // Обновление UI после загрузки
    }
  }

  // Пример метода для определения цвета статуса
  Color getStatusColor(int stateId) {
    switch (stateId) {
      case 1:
        return Colors.greenAccent;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(int stateId, AppLocalizations localizations) {
    switch (stateId) {
      case 1:
        return localizations.confirmed;
      case 2:
        return localizations.pending;
      case 3:
        return localizations.rejected;
      default:
        return '';
    }
  }

  // Метод, отвечающий за начало/завершение шаринга
  Future<void> handleLocationSharing(BuildContext context) async {
    try {
      final locationVM = Provider.of<MapShareLocationViewModel>(context, listen: false);

      if (locationVM.currentRequestId != null) {
        final shouldStop = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Тут ваш текст'), // тексты можно прокинуть через локализации
              content: Text('...'),
              actions: <Widget>[
                TextButton(
                  child: Text('Назад'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Остановить'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );

        if (shouldStop != true) {
          return;
        } else {
          await locationVM.stopLocationSharing();
        }
      }

      // Переход к MapShareLocationView
      await navigateToMapShareLocationView(context, requestModel?.id ?? '');
    } catch (e) {
      print('Error in handleLocationSharing: $e');
    }
  }

  Future<void> navigateToMapShareLocationView(BuildContext context, String requestId) async {
    RequestService requestService = RequestService();

    isSharing = true;
    notifyListeners();

    try {
      // Получаем статус
      StatusModel status = await requestService.getRequestStatus(requestId);

      // Логика проверки статуса
      if (status.status == RequestStatus.active) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapShareLocationView(
              key: ValueKey(requestId),
              requestModel: requestModel,
            ),
          ),
        );
      } else if (status.status == RequestStatus.expired) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request has expired: ${status.message}')),
        );
      } else if (status.status == RequestStatus.notYetActive) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request is not yet active: ${status.message}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown status: ${status.status}. ${status.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error retrieving status: $e')),
      );
    } finally {
      isSharing = false;
      notifyListeners();
    }
  }

  Future<void> cancelRequest(BuildContext context) async {
    try {
      final response = await RequestService().cancelRequest(requestModel?.id);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request canceled successfully')),
        );
      } else {
        throw Exception('Failed to cancel request');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
