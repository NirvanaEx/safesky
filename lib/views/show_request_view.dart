import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:safe_sky/models/request_model.dart';
import 'map/show_map_location_view.dart';
import 'map_share_location_view.dart';
import 'package:provider/provider.dart';
import '../viewmodels/map_share_location_viewmodel.dart';

class ShowRequestView extends StatelessWidget {
  final RequestModel? requestModel;

  ShowRequestView({required this.requestModel});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Формат для даты
    final dateFormat = DateFormat('dd.MM.yyyy');
    // Формат для даты и времени
    final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

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
                  _buildRequestInfo(localizations.flightStartDate,
                      requestModel?.flightStartDateTime != null
                          ? dateFormat.format(requestModel!.flightStartDateTime!)
                          : '-'),
                  _buildRequestInfo(localizations.requesterName,
                      requestModel?.requesterName ?? '-', isBold: true),
                  _buildRequestInfo(localizations.model,
                      requestModel?.model ?? '-'),
                  _buildRequestInfo(localizations.flightSign,
                      requestModel?.flightSign ?? '-'),
                  _buildRequestInfo(localizations.flightTimes,
                      '${requestModel?.flightStartDateTime != null
                          ? dateTimeFormat.format(requestModel!.flightStartDateTime!)
                          : '-'}\n${requestModel?.flightEndDateTime != null
                          ? dateTimeFormat.format(requestModel!.flightEndDateTime!)
                          : '-'}'),
                  _buildRequestInfo(localizations.region,
                      requestModel?.region ?? '-'),
                  _buildRequestInfo(localizations.coordinates,
                      '${requestModel?.latitude != null
                          ? requestModel!.latitude!.toStringAsFixed(5)
                          : '-'}, ${requestModel?.longitude != null
                          ? requestModel!.longitude!.toStringAsFixed(5)
                          : '-'}',
                      linkText: localizations.map, icon: Icons.visibility, context: context),
                  _buildRequestInfo(localizations.flightHeight,
                      '${requestModel?.flightHeight != null
                          ? requestModel!.flightHeight!.round()
                          : '-'} ${localizations?.m}'),
                  _buildRequestInfo(localizations.flightRadius,
                      '${requestModel?.radius != null
                          ? requestModel!.radius!.round()
                          : '-'} ${localizations?.m} '),
                  _buildRequestInfo(localizations.flightPurpose,
                      requestModel?.purpose ?? '-'),
                  _buildRequestInfo(localizations.operatorName,
                      requestModel?.operatorName ?? '-'),
                  _buildRequestInfo(localizations.operatorPhone,
                      requestModel?.operatorPhone ?? '-'),
                  _buildRequestInfo(localizations.email,
                      requestModel?.email ?? '-'),
                  _buildRequestInfo(localizations.specialPermit,
                      '№ ${requestModel?.permitNumber ?? '-'}   ${requestModel?.permitDate != null
                          ? dateFormat.format(requestModel!.permitDate!)
                          : '-'}'),
                  _buildRequestInfo(localizations.contract,
                      '№ ${requestModel?.contractNumber ?? '-'}   ${requestModel?.contractDate != null
                          ? dateFormat.format(requestModel!.contractDate!)
                          : '-'}'),
                  _buildRequestInfo(localizations.optional,
                      requestModel?.note ?? '-'),
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
            title: Text(AppLocalizations.of(context)!.stopExistingLocationSharing),
            content: Text(AppLocalizations.of(context)!.locationSharingActive),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.back),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.stop),
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

  Widget _buildRequestInfo( String label, String value, {bool isBold = true, String? linkText, IconData? icon, BuildContext? context}) {
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
              if (linkText != null && context!=null)
                GestureDetector(
                  onTap: () {
                    // Проверяем, что это нажатие на карту, и переходим на MapShowLocationView
                    if (label == AppLocalizations.of(context)!.coordinates) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapShowLocationView(
                            latitude: requestModel?.latitude ?? 0.0,
                            longitude: requestModel?.longitude ?? 0.0,
                            radius: requestModel?.radius ?? 0.0,
                          ),
                        ),
                      );
                    }
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
