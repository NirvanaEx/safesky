import 'dart:convert';

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
// Метод для определения цвета статуса
  Color getStatusColor(int stateId) {
    switch (stateId) {
      case 1:
        return Colors.orangeAccent;  // На рассмотрении
      case 2:
        return Colors.greenAccent;   // Подтверждён
      case 3:
        return Colors.blueAccent;    // Отменён (подходит синий оттенок, ассоциирующийся со спокойствием)
      case 4:
        return Colors.redAccent;     // Отклонён
      default:
        return Colors.grey;          // Неизвестный статус
    }
  }

// Метод для определения текстового значения статуса
  String getStatusText(int stateId, AppLocalizations localizations) {
    switch (stateId) {
      case 1:
        return localizations.pending;
      case 2:
        return localizations.confirmed;
      case 3:
        return localizations.canceled;  // Новый статус "Отменён"
      case 4:
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
              title: Text(AppLocalizations.of(context)!.location_sharing_title),
              content: Text(AppLocalizations.of(context)!.location_sharing_message),
              actions: <Widget>[
                TextButton(
                  child: Text(AppLocalizations.of(context)!.back),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.stop),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );

        if (shouldStop != true) {
          return;
        } else {
          await locationVM.stopLocationSharing(context);
        }
      }

      // Показ уведомления о начале передачи данных
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.location_sharing_started),
          duration: Duration(seconds: 3),
        ),
      );

      // Переход к MapShareLocationView
      await navigateToMapShareLocationView(context);
    } catch (e) {
      print('Error in handleLocationSharing: $e');
    }
  }


  Future<void> navigateToMapShareLocationView(BuildContext context) async {
    RequestService requestService = RequestService();
    final localizations = AppLocalizations.of(context)!;

    isSharing = true;
    notifyListeners();

    try {
      // Получаем статус заявки
      int? status = planDetailModel?.stateId;

      // Проверка статуса заявки и выполнение соответствующих действий
      if (status == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.request_pending}: ${planDetailModel?.state}')),
        );
      } else if (status == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapShareLocationView(
              planDetailModel: planDetailModel,
            ),
          ),
        );
      } else if (status == 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.request_canceled}: ${planDetailModel?.state}')),
        );
      } else if (status == 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.request_rejected}: ${planDetailModel?.state}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.unknown_status}: ${planDetailModel?.state}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations.error_retrieving_status}: $e')),
      );
    } finally {
      isSharing = false;
      notifyListeners();
    }
  }


  Future<void> cancelRequest(BuildContext context, {String? cancelReason}) async {
    if (planDetailModel?.planId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plan ID is missing')),
      );
      return;
    }

    try {
      final response = await RequestService().cancelRequest(planDetailModel!.planId!, cancelReason ?? '');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request canceled successfully')),
        );
        // Можно обновить состояние модели после отмены
        planDetailModel = null; // или обновить статус, если есть механизм
        notifyListeners();
      } else {
        var errorMessage = 'Failed to cancel request';
        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody['message'] != null) {
            errorMessage = responseBody['message'];
          }
        } catch (e) {
          // Игнорируем ошибки парсинга JSON
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> deleteRequest(BuildContext context) async {
    if (planDetailModel?.planId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plan ID is missing')),
      );
      return;
    }

    try {
      final response = await RequestService().deleteRequest(planDetailModel!.planId!);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request deleted successfully')),
        );
        // Можно обновить состояние модели после удаления
        planDetailModel = null; // или обновить статус, если есть механизм
        notifyListeners();
      } else {
        var errorMessage = 'Failed to delete request';
        try {
          final responseBody = jsonDecode(response.body);
          if (responseBody['message'] != null) {
            errorMessage = responseBody['message'];
          }
        } catch (e) {
          // Игнорируем ошибки парсинга JSON
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
