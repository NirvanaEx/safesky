import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safe_sky/models/request_model.dart';
import 'package:safe_sky/models/request/status_model.dart';
import 'package:safe_sky/services/request_service.dart';
import 'package:safe_sky/utils/enums.dart';

class ShowRequestViewModel extends ChangeNotifier {
  final RequestModel? requestModel;
  bool isSharing = false;

  ShowRequestViewModel({required this.requestModel});

  // Форматы даты/времени
  final dateFormat = DateFormat('dd.MM.yyyy');
  final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

  /// Логика определения цвета статуса
  Color getStatusColor(String status) {
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

  /// Логика получения текста статуса (можно оставить без локализации,
  /// если локализация идёт напрямую из слоя UI)
  String getStatusText(String status) {
    switch (status) {
      case "confirmed":
        return "Подтверждено";
      case "pending":
        return "На рассмотрении";
      case "rejected":
        return "Отклонено";
      default:
        return status;
    }
  }

  /// Запуск/остановка шаринга локации
  Future<void> handleLocationSharing({
    required BuildContext context,
    required Future<bool?> Function(BuildContext) showStopDialog,
    required Function(BuildContext, String) navigateToMapShareLocationView,
  }) async {
    try {
      // При начале шаринга ставим флаг true
      isSharing = true;
      notifyListeners();

      // Проверим, неактивен ли уже другой процесс шаринга?
      // Тут предполагается, что у вас есть какой-то MapShareLocationViewModel,
      // который хранит currentRequestId. В прежнем коде это:
      // final locationVM = Provider.of<MapShareLocationViewModel>(context, listen: false);
      //
      // Если вам нужно, можете пробросить текущий requestId
      // из вне или из requestModel
      //
      // Пример диалога:
      final shouldStop = await showStopDialog(context);
      if (shouldStop != true) {
        // Если пользователь передумал — выходим
        isSharing = false;
        notifyListeners();
        return;
      }

      // Если надо остановить предыдущий шаринг — делаем это (ранее вы делали: await locationVM.stopLocationSharing();)

      // И переходим на экран шаринга
      navigateToMapShareLocationView(context, requestModel?.id ?? '');
    } catch (e) {
      debugPrint('Error in handleLocationSharing: $e');
    } finally {
      isSharing = false;
      notifyListeners();
    }
  }

  /// Получить статус из RequestService и перейти на экран
  Future<void> fetchRequestStatusAndNavigate({
    required BuildContext context,
    required String requestId,
    required Widget Function() mapShareLocationViewBuilder,
  }) async {
    try {
      RequestService requestService = RequestService();
      StatusModel status = await requestService.getRequestStatus(requestId);

      if (status.status == RequestStatus.active) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => mapShareLocationViewBuilder()),
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
    }
  }

  /// Отмена заявки (пример как это вызывалось на кнопке)
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
