import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:safe_sky/models/plan_detail_model.dart';
import 'package:safe_sky/models/request_model.dart';
import 'package:safe_sky/services/request_service.dart';
import '../models/area_point_location_model.dart';
import '../models/request/status_model.dart';
import '../utils/enums.dart';
import '../viewmodels/show_request_viewmodel.dart';
import 'map/map_show_location_view.dart';
import 'map/map_share_location_view.dart';
import 'package:provider/provider.dart';
import '../viewmodels/map_share_location_viewmodel.dart';

class ShowRequestView extends StatefulWidget {
  final int? requestId;

  ShowRequestView({required this.requestId});

  @override
  _ShowRequestViewState createState() => _ShowRequestViewState();
}


class _ShowRequestViewState extends State<ShowRequestView> {
  bool _isSharing = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ShowRequestViewModel>(context, listen: false);
      if (widget.requestId != null) {
        viewModel.loadRequest(widget.requestId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final localizations = AppLocalizations.of(context)!;
    final viewModel = Provider.of<ShowRequestViewModel>(context);

    final dateFormat = DateFormat('dd.MM.yyyy');
    final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');


    String zoneInfo = '';

    if(viewModel.planDetailModel?.zoneTypeId == 1){
      zoneInfo = '${viewModel.planDetailModel?.coordList.first.latitude ?? '-'}, ${viewModel.planDetailModel?.coordList.first.longitude ?? '-'}';
    }

    // Если данные загружаются, показываем индикатор загрузки
    if (viewModel.isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
                        "№ ${viewModel.planDetailModel != null ? viewModel.planDetailModel!.applicationNum ?? 'N/A' : 'N/A'}",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: viewModel.getStatusColor(viewModel.planDetailModel?.stateId ?? 0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          viewModel.getStatusText(viewModel.planDetailModel?.stateId ?? 0, localizations),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (viewModel.planDetailModel?.stateId == 1)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSharing ? null : () async { // Отключаем кнопку, если идет загрузка
                          await _handleLocationSharing(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSharing
                            ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white, // Цвет индикатора
                            strokeWidth: 2,
                          ),
                        )
                            : Text(localizations.startLocationSharing),
                      ),
                    ),


                  SizedBox(height: 20),

                  // Данные заявки
                  _buildRequestInfo(localizations.flightStartDate,
                      viewModel.planDetailModel?.planDate != null
                          ? dateFormat.format(viewModel.planDetailModel!.planDate!)
                          : '-'),
                  _buildRequestInfo(localizations.requesterName,
                      viewModel.planDetailModel?.applicant ?? '-', isBold: true),
                  _buildRequestInfo(
                    localizations.model,
                    viewModel.planDetailModel?.bplaList.isNotEmpty ?? false
                        ? viewModel.planDetailModel!.bplaList
                        .asMap()
                        .entries
                        .map((entry) => "${entry.key + 1}. ${entry.value.name ?? '-'}")
                        .join('\n')
                        : '-',
                  ),

                  _buildRequestInfo(
                    localizations.flightSign,
                    viewModel.planDetailModel?.bplaList.isNotEmpty ?? false
                        ? viewModel.planDetailModel!.bplaList
                        .asMap()
                        .entries
                        .map((entry) => "${entry.key + 1}. ${entry.value.regnum ?? '-'}")
                        .join('\n')
                        : '-',
                  ),

                  _buildRequestInfo(
                  localizations.flightTimes,
                  '${viewModel.planDetailModel?.timeFrom ?? '-'}\n${viewModel.planDetailModel?.timeTo ?? '-'}',
                  ),

                  _buildRequestInfo(localizations.region,
                      viewModel.planDetailModel?.flightArea ?? '-'),

                  // Отображение координат AUTHORIZED ZONE
                  _buildRequestInfo(
                    localizations.coordinates,
                    zoneInfo,
                    linkText: localizations.map,
                    icon: Icons.visibility,
                    context: context,
                    planDetailModel: viewModel.planDetailModel
                  ),

                  // Отображение радиуса AUTHORIZED ZONE (если он есть)
                  if (viewModel.planDetailModel?.coordList.first.radius != null)
                    _buildRequestInfo(
                      localizations.flightRadius,
                      '${viewModel.planDetailModel?.coordList.first.radius} ${localizations.m}',
                    ),

                  _buildRequestInfo(localizations.flightHeight,
                      '${viewModel.planDetailModel?.mAltitude != null
                          ? viewModel.planDetailModel?.mAltitude
                          : '-'} ${localizations?.m}'),
                  _buildRequestInfo(localizations.flightPurpose,
                      viewModel.planDetailModel?.purpose ?? '-'),
                  _buildRequestInfo(
                    localizations.operatorName,
                    viewModel.planDetailModel?.operatorList.isNotEmpty ?? false
                        ? viewModel.planDetailModel!.operatorList
                        .asMap()
                        .entries
                        .map((entry) => "${entry.key + 1}. ${entry.value.surname ?? '-'} ${entry.value.name ?? '-'} ${entry.value.patronymic ?? ''}")
                        .join('\n')
                        : '-',
                  ),

                  _buildRequestInfo(
                    localizations.operatorPhone,
                    viewModel.planDetailModel?.operatorList.isNotEmpty ?? false
                        ? viewModel.planDetailModel!.operatorList
                        .asMap()
                        .entries
                        .map((entry) => "${entry.key + 1}. ${entry.value.phone ?? '-'}")
                        .join('\n')
                        : '-',
                  ),

                  _buildRequestInfo(localizations.email,
                      viewModel.planDetailModel?.email ?? '-'),
                  _buildRequestInfo(
                      localizations.specialPermit,
                      '${viewModel.planDetailModel?.permission?.orgName ?? '-'} '
                      '${viewModel.planDetailModel?.permission?.docNum ?? '-'} '
                      '${viewModel.planDetailModel?.permission?.docDate != null
                      ? dateFormat.format(viewModel.planDetailModel!.permission!.docDate!)
                          : '-'}'
                  ),
                  _buildRequestInfo(
                      localizations.contract,
                      '${viewModel.planDetailModel?.agreement?.docNum ?? '-'} '
                      '${viewModel.planDetailModel?.agreement?.docDate != null
                      ? dateFormat.format(viewModel.planDetailModel!.agreement!.docDate!)
                          : '-'}'
                  ),
                  _buildRequestInfo(localizations.optional,
                      viewModel.planDetailModel?.notes ?? '-'),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          if (viewModel.planDetailModel?.stateId == 2)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final response = await RequestService().cancelRequest(viewModel.planDetailModel?.planId.toString());
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
    try {
      final locationVM = Provider.of<MapShareLocationViewModel>(context, listen: false);

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

      navigateToMapShareLocationView(context, widget.requestId.toString() ?? '');
    } catch (e) {
      // Обработка возможных ошибок
      print('Error in _handleLocationSharing: $e');
    }
  }

  void navigateToMapShareLocationView(BuildContext context, String requestId) async {
    RequestService requestService = RequestService();

    setState(() {
      _isSharing = true; // Запуск индикатора загрузки
    });

    try {
      // Получаем статус запроса
      StatusModel status = await requestService.getRequestStatus(requestId);

      // Проверяем статус и выполняем навигацию или показываем сообщения для разных статусов
      if (status.status == RequestStatus.active) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapShareLocationView(
              key: ValueKey(requestId), // Используем уникальный ID запроса
            ),
          ),
        );
      } else if (status.status == RequestStatus.expired) {
        // Если статус "Просрочено", показываем соответствующее сообщение
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request has expired: ${status.message}')),
        );
      } else if (status.status == RequestStatus.notYetActive) {
        // Если статус "Еще не активна", показываем соответствующее сообщение
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request is not yet active: ${status.message}')),
        );
      } else {
        // Обработка других статусов, если они появятся
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown status: ${status.status}. ${status.message}')),
        );
      }
    } catch (e) {
      // Обработка ошибки, например, показываем сообщение об ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error retrieving status: $e')),
      );
    }
    finally {
      setState(() {
        _isSharing = false; // Остановка индикатора загрузки
      });
    }
  }


  Widget _buildRequestInfo(String label, String value, {bool isBold = true, String? linkText, IconData? icon, BuildContext? context, PlanDetailModel? planDetailModel}) {
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
                          detailModel: planDetailModel,
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

}
