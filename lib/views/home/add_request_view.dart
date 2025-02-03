
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:safe_sky/models/prepare_model.dart';
import '../../models/request.dart';
import '../../models/request/flight_sign_model.dart';
import '../../models/request/model_model.dart';
import '../../models/request/purpose_model.dart';
import '../../models/request/region_model.dart';
import '../../viewmodels/add_request_viewmodel.dart';
import '../map/map_select_location_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../my_custom_views/multi_select_dropdown.dart';

class AddRequestView extends StatefulWidget {
  @override
  _AddRequestViewState createState() => _AddRequestViewState();
}

class _AddRequestViewState extends State<AddRequestView> {

  @override
  void initState() {
    super.initState();
    // Выполняем установку даты после первого кадра, чтобы избежать ошибок контекста.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<AddRequestViewModel>(context, listen: false);
      if (viewModel.startDate == null) {
        // Устанавливаем завтрашнюю дату
        viewModel.updateStartDate(context, DateTime.now().add(Duration(days: 1)));
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddRequestViewModel>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                localizations.addRequestView_submit,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            _buildLabel(localizations.addRequestView_flightStartDate),
            _buildDateOnlyPickerField(
              date: viewModel.startDate,
              hintText: "01.01.2023",
              onDateSelected: (date) {
                if (date != null) {
                  viewModel.updateStartDate(context, date);
                }
              },
            ),
            // Если дата задана и форма не загружается, показываем оставшуюся форму.
            if (viewModel.startDate != null && !viewModel.isLoading)
              _formAfterGetStartDate(),
          ],
        ),
      ),
    );
  }

  Widget _formAfterGetStartDate(){
    final localizations = AppLocalizations.of(context)!;
    final viewModel = Provider.of<AddRequestViewModel>(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        _buildLabel(localizations.addRequestView_requesterName),
        _buildTextField(viewModel.requesterNameController, hintText: localizations.addRequestView_requesterName, readOnly: true),
        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_requestNum),
        _buildTextField(viewModel.requestNumController, hintText: localizations.addRequestView_requestNum, isDecimal: true),
        SizedBox(height: 16),
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

        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_flightTimes),
        Column(
          children: [
            _buildDatePickerField(
              date: viewModel.flightStartDateTime,
              hintText: "01.01.2023 15:00",
              onDateSelected: (date) => viewModel.updateFlightStartDateTime(date!),
            ),
            SizedBox(height: 16),
            _buildDatePickerField(
              date: viewModel.flightEndDateTime,
              hintText: "01.01.2023 17:00",
              onDateSelected: (date) => viewModel.updateFlightEndDateTime(date!),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_region),
        _buildTextField(viewModel.regionController, hintText: localizations.addRequestView_region, isText: true),

        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_coordinates),
        Row(
          children: [
            Expanded(
              child: _buildTextField(viewModel.latLngController, hintText: localizations.addRequestView_coordinates, readOnly: true),
            ),
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapSelectLocationView(),
                  ),
                );
                if (result != null && result is Map<String, dynamic>) {
                  LatLng coordinates = result['coordinates'];
                  double? radius = result['radius'];
                  viewModel.updateCoordinatesAndRadius(coordinates, radius);
                }
              },
              child: Text(localizations.addRequestView_map),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(localizations.addRequestView_flightHeight),
                  _buildTextField(viewModel.flightHeightController, hintText: '0', isDecimal: true)
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(localizations.addRequestView_flightRadius),
                  _buildTextField(viewModel.radiusController, hintText: '0', isDecimal: true)
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_flightPurpose),
        _buildDropdown<String>(
          items: viewModel.purposeList,
          selectedValue: viewModel.selectedPurpose,
          onChanged: (value) => viewModel.setPurpose(value!),
          hint: localizations.addRequestView_flightPurpose,
          getItemName: (purpose) => purpose,
        ),
        SizedBox(height: 16),
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
        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_operatorPhone),
        _buildPhoneField(viewModel, context),
        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_email),
        _buildTextField(viewModel.emailController, hintText: 'my@mail.com', isText: true),
        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_specialPermit),
        _buildTextField(viewModel.permitNumberController, hintText: '-', isText: true, readOnly: true),

        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_contract),
        _buildTextField(viewModel.contractNumberController, hintText: '-', isText: true, readOnly: true),

        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_note),
        _buildTextField(viewModel.noteController, hintText: localizations.addRequestView_optional, isText: true),
        SizedBox(height: 30),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              // Ожидание результата submitRequest с помощью await
              Map<String, String>? result = await viewModel.submitRequest(context);

              if (result != null) {
                // Получаем статус и сообщение из результата
                String status = result['status']!;
                String message = result['message']!;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: status == 'success' ? Colors.green : Colors.red,
                  ),
                );

                if (status == 'success') {
                  print("Запрос успешно отправлен!");
                  // Здесь можно добавить действия для успешного запроса
                }
              }
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              minimumSize: Size(double.infinity, 48),
            ),
            child: Text(localizations.addRequestView_submit, style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _buildTextField(

      TextEditingController controller, {
        required String hintText,
        bool readOnly = false,
        bool isDecimal = false, // Параметр для выбора типа чисел
        bool isText = false, // Новый параметр для текста
      }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isText
          ? TextInputType.text
          : (isDecimal ? TextInputType.numberWithOptions(decimal: true) : TextInputType.number),
      inputFormatters: isText
          ? [] // Для текста не требуется ограничений
          : [
        FilteringTextInputFormatter.allow(
          isDecimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*'), // Разрешает ввод с десятичными или без
        ),
      ],
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Widget _buildPhoneField(AddRequestViewModel viewModel, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: viewModel.selectedCountryCode,
              items: viewModel.countries.map((country) {
                return DropdownMenuItem<String>(
                  value: country['code'],
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Text(country['flag']!, style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(country['code']!, style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => viewModel.updateCountryCode(value!),
            ),
          ),
          Expanded(
            child: TextField(
              controller: viewModel.phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '991234567',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Обновленный метод для выпадающих списков моделей
  Widget _buildDropdown<T>({
    required List<T> items,
    required T? selectedValue,
    required ValueChanged<T?> onChanged,
    required String hint,
    required String Function(T) getItemName,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedValue,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(fontSize: 16)),
          items: items.map((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text(getItemName(value)), // Отображение имени из модели
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date == null ? hintText : DateFormat(dateFormat).format(date),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          Icon(Icons.calendar_today, color: Colors.grey),
        ],
      ),
    );
  }
}
