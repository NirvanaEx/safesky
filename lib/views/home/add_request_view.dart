import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:safe_sky/models/district_model.dart';
import 'package:safe_sky/models/region_model.dart';
import 'package:safe_sky/viewmodels/request_list_viewmodel.dart';
import '../../models/plan_detail_model.dart';
import '../../models/request.dart';
import '../../viewmodels/add_request_viewmodel.dart';
import '../map/map_select_location_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../my_custom_views/multi_select_dropdown.dart';
import '../my_custom_views/my_custom_dialog.dart';
import '../my_custom_views/skeleton_form.dart';

class AddRequestView extends StatefulWidget {
  final PlanDetailModel? planDetail;
  const AddRequestView({Key? key, this.planDetail}) : super(key: key);

  @override
  _AddRequestViewState createState() => _AddRequestViewState();
}

class _AddRequestViewState extends State<AddRequestView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<AddRequestViewModel>(context, listen: false);
      if (widget.planDetail != null && widget.planDetail!.planDate != null) {
        await viewModel.updateStartDate(context, widget.planDetail!.planDate!);
      } else if (viewModel.startDate == null) {
        await viewModel.updateStartDate(context, DateTime.now().add(Duration(days: 1)));
      }
      if (widget.planDetail != null) {
        await viewModel.autoFillWithPlanDetail(widget.planDetail!, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddRequestViewModel>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: widget.planDetail != null
          ? AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
      )
          : null,
      body: viewModel.isLoading
          ? const SkeletonForm()
          : RefreshIndicator(
        onRefresh: () async {
          viewModel.clearFields();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildLabel(localizations.addRequestView_flightStartDate),
              _buildDateOnlyPickerField(
                date: viewModel.startDate,
                hintText: "dd.mm.yyyy",
                onDateSelected: (date) {
                  if (date != null) {
                    viewModel.updateStartDate(context, date);
                  }
                },
              ),
              if (viewModel.startDate != null && !viewModel.isLoading) _formAfterGetStartDate(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formAfterGetStartDate() {
    final localizations = AppLocalizations.of(context)!;
    final viewModel = Provider.of<AddRequestViewModel>(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_requesterName),
        _buildTextField(viewModel.requesterNameController, hintText: localizations.addRequestView_requesterName, readOnly: true),
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_model),
        MultiSelectDropdown<Bpla>(
          items: viewModel.bplaList,
          selectedValues: viewModel.selectedBplas,
          onChanged: (selected) {
            viewModel.setBpla(selected);
          },
          itemLabel: (bpla) => "${bpla.name}",
          title: localizations.addRequestView_selectBpla,
          buttonText: localizations.addRequestView_chooseBpla,
        ),
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_flightTimes),
        Column(
          children: [
            _buildTimePickerField(
              time: viewModel.flightStartDateTime,
              hintText: "HH:mm",
              onTimeSelected: (date) => viewModel.updateFlightStartDateTime(date!),
            ),
            const SizedBox(height: 16),
            _buildTimePickerField(
              time: viewModel.flightEndDateTime,
              hintText: "HH:mm",
              onTimeSelected: (date) => viewModel.updateFlightEndDateTime(date!),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_flightOperationArea),
        _buildDropdown<RegionModel>(
          items: viewModel.regionList,
          selectedValue: viewModel.selectedRegion,
          onChanged: (value) => viewModel.setSelectedRegion(value!),
          hint: localizations.addRequestView_flightOperationArea,
          getItemName: (region) => region.name,
        ),
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_flightOperationDistrict),
        _buildDropdown<DistrictModel>(
          items: viewModel.districtList,
          selectedValue: viewModel.selectedDistrict,
          onChanged: (value) => viewModel.setSelectedDistrict(value!),
          hint: localizations.addRequestView_flightOperationDistrict,
          getItemName: (district) => district.name,
        ),
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_landmark),
        _buildTextField(viewModel.landmarkController, hintText: localizations.addRequestView_landmark, isText: true),
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_routeType),
        _buildDropdown<String>(
          items: viewModel.routeTypeOptions,
          selectedValue: viewModel.selectedRouteType,
          onChanged: (value) => viewModel.setSelectedRouteType(value!),
          hint: localizations.addRequestView_routeType,
          getItemName: (value) {
            switch (value) {
              case "circle":
                return localizations.addRequestView_routeCircle;
              case "polygon":
                return localizations.addRequestView_routePolygon;
              case "line":
                return localizations.addRequestView_routeLine;
              default:
                return value;
            }
          },
        ),
        const SizedBox(height: 16),
        if (viewModel.selectedRouteType != null) ...[
          _buildLabel(localizations.addRequestView_coordinates),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      viewModel.coordinatesExpanded = !viewModel.coordinatesExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      viewModel.latLngController.text,
                      maxLines: viewModel.coordinatesExpanded ? null : 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  viewModel.coordinatesExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  setState(() {
                    viewModel.coordinatesExpanded = !viewModel.coordinatesExpanded;
                  });
                },
              ),
              TextButton(
                onPressed: () async {
                  final initialCoordinates = viewModel.getCurrentCoordinates();
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapSelectLocationView(
                        routeType: viewModel.selectedRouteType,
                        initialCoordinates: initialCoordinates,
                      ),
                    ),
                  );
                  if (result != null && result is Map<String, dynamic>) {
                    viewModel.updateCoordinatesAndRadius(result['coordinates'], result['radius']);
                  }
                },
                child: Text(
                  localizations.addRequestView_map,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(localizations.addRequestView_flightHeight),
                    _buildTextField(viewModel.flightHeightController, hintText: '0', isDecimal: true),
                  ],
                ),
              ),
              if (viewModel.selectedRouteType == "circle") ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(localizations.addRequestView_flightRadius),
                      _buildTextField(viewModel.radiusController, hintText: '0', isDecimal: true),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_flightPurpose),
        _buildDropdown<String>(
          items: viewModel.purposeList,
          selectedValue: viewModel.selectedPurpose,
          onChanged: (value) => viewModel.setPurpose(value!),
          hint: localizations.addRequestView_flightPurpose,
          getItemName: (purpose) => purpose,
        ),
        if (viewModel.selectedPurpose == localizations.addRequestView_other) ...[
          const SizedBox(height: 16),
          _buildLabel(localizations.addRequestView_enterPurpose),
          _buildTextField(viewModel.customPurposeController, hintText: localizations.addRequestView_flightPurposeHint, isText: true),
        ],
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_operatorName),
        MultiSelectDropdown<Operator>(
          items: viewModel.operatorList,
          selectedValues: viewModel.selectedOperators,
          onChanged: (values) {
            viewModel.setOperators(values);
          },
          title: localizations.addRequestView_chooseOperator,
          hint: localizations.addRequestView_chooseOneOrMultiple,
          buttonText: localizations.addRequestView_selectOperator,
          itemLabel: (operator) => "${operator.surname} ${operator.name} ${operator.patronymic ?? ''}",
        ),
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_operatorPhone),
        _buildPhoneList(viewModel),
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_email),
        _buildTextField(viewModel.emailController, hintText: 'my@mail.com', isText: true),
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_specialPermit),
        _buildTextField(viewModel.permitNumberController, hintText: '-', isText: true, readOnly: true),
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_contract),
        _buildTextField(viewModel.contractNumberController, hintText: '-', isText: true, readOnly: true),
        const SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_note),
        _buildTextField(viewModel.noteController, hintText: localizations.addRequestView_optional, isText: true),
        const SizedBox(height: 30),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              Map<String, dynamic>? result = await viewModel.submitRequest(context);

              if (result != null) {
                String status = result['status'];
                String message = result['message'];

                if (status == 'success') {
                  String applicationNum = result['applicationNum'] ?? 'Unknown';
                  int planId = int.tryParse(result['planId']) ?? 0;
                  await MyCustomDialog.showApplicationNumberDialog(
                    context,
                    localizations.addRequestView_requestNum,
                    applicationNum,
                    planId,
                  );
                  context.read<RequestListViewModel>().refreshRequests();
                  print("Запрос успешно отправлен!");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message, style: Theme.of(context).textTheme.bodyLarge),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.black  // черный фон для светлой темы
                  : Theme.of(context).buttonTheme.colorScheme?.primary ?? Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              localizations.addRequestView_submit,
              style: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, color: Colors.white) // белый текст для светлой темы
                  : Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
            ),
          ),

        ),
      ],
    );
  }

  Widget _buildPhoneList(AddRequestViewModel viewModel) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...viewModel.operatorPhoneControllers.map((controller) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: localizations.addRequestView_operatorPhone,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        )),
        ...viewModel.manualPhoneControllers.map((controller) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: localizations.addRequestView_additionalPhone,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    viewModel.manualPhoneControllers.remove(controller);
                  });
                },
              )
            ],
          ),
        )),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                viewModel.manualPhoneControllers.add(TextEditingController());
              });
            },
            icon: const Icon(Icons.add),
            label: Text(
                localizations.addRequestView_addPhone,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                )
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, {
        required String hintText,
        bool readOnly = false,
        bool isDecimal = false,
        bool isText = false,
      }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isText
          ? TextInputType.text
          : (isDecimal ? TextInputType.numberWithOptions(decimal: true) : TextInputType.number),
      inputFormatters: isText
          ? []
          : [
        FilteringTextInputFormatter.allow(
          isDecimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*'),
        ),
      ],
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildDropdown<T>({
    required List<T> items,
    required T? selectedValue,
    required ValueChanged<T?> onChanged,
    required String hint,
    required String Function(T) getItemName,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedValue,
          isExpanded: true,
          hint: Text(
            hint,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          items: items.map((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text(getItemName(value), style: Theme.of(context).textTheme.bodyLarge),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePickerField({required DateTime? date, required String hintText, required ValueChanged<DateTime?> onDateSelected}) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
          if (pickedTime != null) {
            DateTime newDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
            onDateSelected(newDateTime);
          }
        }
      },
      child: _buildDateDisplay(date, hintText, dateFormat: 'dd.MM.yyyy HH:mm'),
    );
  }

  Widget _buildTimePickerField({required DateTime? time, required String hintText, required ValueChanged<DateTime?> onTimeSelected}) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
        if (pickedTime != null) {
          DateTime now = DateTime.now();
          DateTime newDateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
          onTimeSelected(newDateTime);
        }
      },
      child: _buildTimeDisplay(time, hintText),
    );
  }

  Widget _buildDateOnlyPickerField({required DateTime? date, required String hintText, required ValueChanged<DateTime?> onDateSelected}) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: _buildDateDisplay(date, hintText, dateFormat: 'dd.MM.yyyy'),
    );
  }

  Widget _buildDateDisplay(DateTime? date, String hintText, {required String dateFormat}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date == null ? hintText : DateFormat(dateFormat).format(date),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Icon(Icons.calendar_today, color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(DateTime? time, String hintText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              time == null ? hintText : DateFormat('HH:mm').format(time),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Icon(Icons.access_time, color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
        ],
      ),
    );
  }
}
