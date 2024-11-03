import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:safe_sky/models/request_model.dart';
import 'package:safe_sky/services/request_service.dart';
import '../models/area_point_location_model.dart';
import '../utils/enums.dart';
import 'map/map_show_location_view.dart';
import 'map/map_share_location_view.dart';
import 'package:provider/provider.dart';
import '../viewmodels/map_share_location_viewmodel.dart';

class ShowRequestView extends StatelessWidget {
  final RequestModel? requestModel;

  ShowRequestView({required this.requestModel});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd.MM.yyyy');
    final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

    // Поиск AUTHORIZED ZONE в area
    final authorizedZone = requestModel?.area?.firstWhere(
          (zone) => zone.tag == AreaType.authorizedZone,
      orElse: () => AreaPointLocationModel(),
    );

    String zoneInfo;
    if (authorizedZone != null) {
      if (authorizedZone.radius != null) {
        // Если это круг, показываем центральные координаты
        zoneInfo = '${authorizedZone.latitude?.toStringAsFixed(5) ?? '-'}, ${authorizedZone.longitude?.toStringAsFixed(5) ?? '-'}';
      } else if (authorizedZone.coordinates != null && authorizedZone.coordinates!.isNotEmpty) {
        // Если это полигон, отображаем список координат
        zoneInfo = authorizedZone.coordinates!
            .map((coord) => '${coord.latitude.toStringAsFixed(5)}, ${coord.longitude.toStringAsFixed(5)}')
            .join(';\n');
      } else {
        // На случай, если координаты отсутствуют
        zoneInfo = '-';
      }
    } else {
      // Если AUTHORIZED ZONE не найдена
      zoneInfo = '-';
    }

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
                          await _handleLocationSharing(context);
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

                  // Отображение координат AUTHORIZED ZONE
                  _buildRequestInfo(
                    localizations.coordinates,
                    zoneInfo,
                    linkText: localizations.map,
                    icon: Icons.visibility,
                    context: context,
                  ),

                  // Отображение радиуса AUTHORIZED ZONE (если он есть)
                  if (authorizedZone?.radius != null)
                    _buildRequestInfo(
                      localizations.flightRadius,
                      '${authorizedZone!.radius!.round()} ${localizations.m}',
                    ),

                  _buildRequestInfo(localizations.flightHeight,
                      '${requestModel?.flightHeight != null
                          ? requestModel!.flightHeight!.round()
                          : '-'} ${localizations?.m}'),
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
                          ? dateFormat.format(requestModel!.contractDate! )
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
                  onPressed: () async {
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
      MaterialPageRoute(
        builder: (context) => MapShareLocationView(
          key: ValueKey(requestModel?.id), // Используем уникальный ID из requestModel
          requestModel: requestModel,
        ),
      ),
    );
  }

  Widget _buildRequestInfo(String label, String value, {bool isBold = true, String? linkText, IconData? icon, BuildContext? context}) {
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
                  style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16),
                ),
              ),
              if (linkText != null && context != null)
                GestureDetector(
                  onTap: () {
                    debugPrint('Link tapped'); // проверка, сработал ли onTap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapShowLocationView(
                          requestModel: requestModel,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(linkText, style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
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
