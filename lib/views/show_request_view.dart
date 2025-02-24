import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:safe_sky/models/plan_detail_model.dart';
import '../viewmodels/show_request_viewmodel.dart';
import 'home/add_request_view.dart';
import 'map/map_show_location_view.dart';
import 'package:provider/provider.dart';
import 'my_custom_views/my_custom_dialog.dart';

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
            child: RefreshIndicator(
              onRefresh: () async {
                if (widget.requestId != null) {
                  await Provider.of<ShowRequestViewModel>(context, listen: false)
                      .loadRequest(widget.requestId!);
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "№ ${viewModel.planDetailModel != null ? viewModel.planDetailModel!.applicationNum ?? 'N/A' : 'N/A'}",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            // IconButton(
                            //   icon: Icon(Icons.edit),
                            //   onPressed: () {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => AddRequestView(planDetail: viewModel.planDetailModel),
                            //       ),
                            //     );
                            //   },
                            // ),
                          ],
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
                    if (viewModel.planDetailModel?.activity == 1)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSharing ? null : () async { // Отключаем кнопку, если идет загрузка
                            await viewModel.handleLocationSharing(context);
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
                              : Text(localizations.showRequestView_startLocationSharing),
                        ),
                      ),
                    if (viewModel.planDetailModel?.execStateId != null &&
                        (viewModel.planDetailModel?.activity == 1 || viewModel.planDetailModel?.execStateId == 4) &&
                        viewModel.planDetailModel?.stateId == 2
                    )
                      _buildExecStateText(viewModel.planDetailModel?.execStateId, localizations),


                    SizedBox(height: 20),

                    // Данные заявки
                    _buildRequestInfo(localizations.showRequestView_flightStartDate,
                        viewModel.planDetailModel?.planDate != null
                            ? dateFormat.format(viewModel.planDetailModel!.planDate!)
                            : '-'),
                    _buildRequestInfo(localizations.showRequestView_requesterName,
                        viewModel.planDetailModel?.applicant ?? '-', isBold: true),
                    _buildRequestInfo(
                      localizations.showRequestView_model,
                      viewModel.planDetailModel?.bplaList.isNotEmpty ?? false
                          ? viewModel.planDetailModel!.bplaList
                          .asMap()
                          .entries
                          .map((entry) => "${entry.key + 1}. ${entry.value.name ?? '-'}")
                          .join('\n')
                          : '-',
                    ),

                    _buildRequestInfo(
                      localizations.showRequestView_flightSign,
                      viewModel.planDetailModel?.bplaList.isNotEmpty ?? false
                          ? viewModel.planDetailModel!.bplaList
                          .asMap()
                          .entries
                          .map((entry) => "${entry.key + 1}. ${entry.value.regnum ?? '-'}")
                          .join('\n')
                          : '-',
                    ),

                    _buildRequestInfo(
                    localizations.showRequestView_flightTimes,
                    '${viewModel.planDetailModel?.timeFrom ?? '-'}\n${viewModel.planDetailModel?.timeTo ?? '-'}',
                    ),

                    _buildRequestInfo(localizations.showRequestView_flightOperationArea,
                        viewModel.planDetailModel?.region ?? '-'),

                    _buildRequestInfo(localizations.showRequestView_flightOperationDistrict,
                        viewModel.planDetailModel?.district ?? '-'),

                    _buildRequestInfo(localizations.showRequestView_landmark,
                        viewModel.planDetailModel?.flightArea ?? '-'),

                    // Отображение координат AUTHORIZED ZONE
                    _buildRequestInfo(
                      localizations.showRequestView_coordinates,
                      zoneInfo,
                      linkText: localizations.showRequestView_map,
                      icon: Icons.visibility,
                      context: context,
                      planDetailModel: viewModel.planDetailModel
                    ),

                    // Отображение радиуса AUTHORIZED ZONE (если он есть)
                    if (viewModel.planDetailModel?.coordList.first.radius != null)
                      _buildRequestInfo(
                        localizations.showRequestView_flightRadius,
                        '${viewModel.planDetailModel?.coordList.first.radius} ${localizations.m}',
                      ),

                    _buildRequestInfo(localizations.showRequestView_flightHeight,
                        '${viewModel.planDetailModel?.mAltitude != null
                            ? viewModel.planDetailModel?.mAltitude
                            : '-'} ${localizations?.m}'),
                    _buildRequestInfo(localizations.showRequestView_flightPurpose,
                        viewModel.planDetailModel?.purpose ?? '-'),
                    _buildRequestInfo(
                      localizations.showRequestView_operatorName,
                      viewModel.planDetailModel?.operatorList.isNotEmpty ?? false
                          ? viewModel.planDetailModel!.operatorList
                          .asMap()
                          .entries
                          .map((entry) => "${entry.key + 1}. ${entry.value.surname ?? '-'} ${entry.value.name ?? '-'} ${entry.value.patronymic ?? ''}")
                          .join('\n')
                          : '-',
                    ),

                    _buildRequestInfo(
                      localizations.showRequestView_operatorPhone,
                          () {
                        final operatorPhones = viewModel.planDetailModel?.operatorPhones;
                        if (operatorPhones == null || operatorPhones.isEmpty) return '-';

                        final phonesList = operatorPhones
                            .split(',')
                            .map((phone) => phone.trim())
                            .toList()
                            .reversed
                            .toList();

                        return phonesList
                            .asMap()
                            .entries
                            .map((entry) => "${entry.key + 1}. ${entry.value}")
                            .join("\n");
                      }(),
                    ),

                    _buildRequestInfo(localizations.showRequestView_email,
                        viewModel.planDetailModel?.email ?? '-'),
                    _buildRequestInfo(
                        localizations.showRequestView_specialPermit,
                        '${viewModel.planDetailModel?.permission?.orgName ?? '-'} '
                        '${viewModel.planDetailModel?.permission?.docNum ?? '-'} '
                        '${viewModel.planDetailModel?.permission?.docDate != null
                        ? dateFormat.format(viewModel.planDetailModel!.permission!.docDate!)
                            : '-'}'
                    ),
                    _buildRequestInfo(
                        localizations.showRequestView_contract,
                        '${viewModel.planDetailModel?.agreement?.docNum ?? '-'} '
                        '${viewModel.planDetailModel?.agreement?.docDate != null
                        ? dateFormat.format(viewModel.planDetailModel!.agreement!.docDate!)
                            : '-'}'
                    ),
                    _buildRequestInfo(localizations.showRequestView_optional,
                        viewModel.planDetailModel?.notes ?? '-'),
                    const SizedBox(height: 20),
                    viewModel.planDetailModel?.checkUrl != null && viewModel.planDetailModel!.checkUrl!.isNotEmpty
                        ? Column(
                          children: [
                            Center(
                              child: BarcodeWidget(
                                barcode: Barcode.qrCode(), // используем QR код
                                data: viewModel.planDetailModel!.checkUrl!,
                                width: 150,
                                height: 150,
                              ),
                            ),
                            const SizedBox(height: 50)
                          ],
                        )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),

          if (viewModel.planDetailModel?.stateId == 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await viewModel.deleteRequest(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(localizations.showRequestView_delete),
                ),
              ),
            )
          else if (viewModel.planDetailModel?.stateId == 2 &&
                   viewModel.planDetailModel?.activity == 0 &&
                   viewModel.planDetailModel?.execStateId != 4
          )
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Получаем причину отмены через кастомное диалоговое окно
                    String? cancelReason = await MyCustomDialog.showCancelReasonDialog(
                      context,
                      localizations.showRequestView_cancelRequestDialog, // Заголовок диалога
                      localizations.showRequestView_enterReasonDialog,   // Подсказка в TextField
                      cancelText: localizations.showRequestView_exitDialog,
                      okText: localizations.showRequestView_submit,
                    );

                    if (cancelReason != null && cancelReason.isNotEmpty) {
                      await viewModel.cancelRequest(context, cancelReason: cancelReason);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(localizations.showRequestView_cancel),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildExecStateText(int? execStateId, AppLocalizations localizations) {
    String text;
    switch (execStateId) {
      case 1:
        text = localizations.showRequestView_execState1;
        break;
      case 2:
        text = localizations.showRequestView_execState2;
        break;
      case 3:
        text = localizations.showRequestView_execState3;
        break;
      case 4:
        text = localizations.showRequestView_execState4;
        break;
      case 5:
        text = localizations.showRequestView_execState5;
        break;
      case 6:
        text = localizations.showRequestView_execState6;
        break;
      default:
        return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Align(
        alignment: Alignment.centerRight, // выравнивание вправо
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
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
