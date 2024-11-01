import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/models/request_model.dart';
import 'map_share_location_view.dart';
import 'package:provider/provider.dart';
import '../viewmodels/map_share_location_viewmodel.dart';

class ShowRequestView extends StatelessWidget {
  final RequestModel? requestModel;

  ShowRequestView({required this.requestModel});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "№ ${requestModel?.number}",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(requestModel?.status ?? ''),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusText(requestModel?.status ?? '', localizations),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  if (requestModel?.status == 'confirmed')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _handleLocationSharing(context); // Проверка перед переходом
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(localizations.startLocationSharing),
                      ),
                    ),

                  SizedBox(height: 20),

                  // Данные заявки
                  _buildRequestInfo(localizations.flightStartDate, '01.01.2023'),
                  _buildRequestInfo(localizations.requesterName, 'Наименование заявителя', isBold: true),
                  _buildRequestInfo(localizations.model, 'Модель'),
                  _buildRequestInfo(localizations.flightSign, 'Знак'),
                  _buildRequestInfo(localizations.flightTimes, '01.01.2023 15:03:26\n01.01.2023 15:03:26'),
                  _buildRequestInfo(localizations.region, 'Ташкент'),
                  _buildRequestInfo(localizations.coordinates, '41.40338, 2.17403', linkText: localizations.map, icon: Icons.visibility),
                  _buildRequestInfo(localizations.flightHeight, '130 м'),
                  _buildRequestInfo(localizations.flightRadius, '500 м'),
                  _buildRequestInfo(localizations.flightPurpose, 'Цель полета'),
                  _buildRequestInfo(localizations.operatorName, 'Закиров Аслиддин Темурович'),
                  _buildRequestInfo(localizations.operatorPhone, '+99899 111 2244'),
                  _buildRequestInfo(localizations.email, 'sample@gmail.com'),
                  _buildRequestInfo(localizations.specialPermit, '№ 123456   01.01.2023'),
                  _buildRequestInfo(localizations.contract, '№ 123456   01.01.2023'),
                  _buildRequestInfo(localizations.optional, 'Lorem ipsum pellentesque in cras tortor erat.'),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          if (requestModel?.status == 'pending')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Логика для отмены заявки
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(localizations.cancel),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleLocationSharing(BuildContext context) async {
    final locationVM = Provider.of<MapShareLocationViewModel>(context, listen: false);

    // Если уже есть активная задача, показываем диалоговое окно
    if (locationVM.currentRequestId != null) {
      final shouldStop = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Stop Existing Location Sharing?"),
            content: Text("A location sharing task is already active. Would you like to stop it and start a new one?"),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text("Stop & Start New"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
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

    // Выполняем переход на страницу с картой после остановки задачи или если задач не было
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapShareLocationView()),
    );
  }

  Widget _buildRequestInfo(String label, String value, {bool isBold = true, String? linkText, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              if (linkText != null)
                GestureDetector(
                  onTap: () {
                    // Логика перехода по ссылке
                  },
                  child: Row(
                    children: [
                      Text(linkText, style: TextStyle(color: Colors.blue)),
                      if (icon != null) Icon(icon, color: Colors.blue, size: 18),
                    ],
                  ),
                ),
            ],
          ),
        ],
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
