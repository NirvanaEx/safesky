
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:safe_sky/models/district_model.dart';
import 'package:safe_sky/models/region_model.dart';
import '../../models/request.dart';
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
            SizedBox(height: 16),
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
        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_requesterName),
        _buildTextField(viewModel.requesterNameController, hintText: localizations.addRequestView_requesterName, readOnly: true),
        // SizedBox(height: 16),
        // _buildLabel(localizations.addRequestView_applicationNum),
        // _buildTextField(viewModel.applicationNumController, hintText: localizations.addRequestView_applicationNum, readOnly: true),
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
            _buildTimePickerField(
              time: viewModel.flightStartDateTime,
              hintText: "HH:mm",
              onTimeSelected: (date) => viewModel.updateFlightStartDateTime(date!),
            ),
            SizedBox(height: 16),
            _buildTimePickerField(
              time: viewModel.flightEndDateTime,
              hintText: "HH:mm",
              onTimeSelected: (date) => viewModel.updateFlightEndDateTime(date!),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_flightOperationArea),
        _buildDropdown<RegionModel>(
          items: viewModel.regionList,
          selectedValue: viewModel.selectedRegion,
          onChanged: (value) => viewModel.setSelectedRegion(value!),
          hint: localizations.addRequestView_flightOperationArea,
          getItemName: (region) => region.name ,
        ),

        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_flightOperationDistrict),
        _buildDropdown<DistrictModel>(
          items: viewModel.districtList,
          selectedValue: viewModel.selectedDistrict,
          onChanged: (value) => viewModel.setSelectedDistrict(value!),
          hint: localizations.addRequestView_flightOperationDistrict,
          getItemName: (district) => district.name,
        ),

        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_landmark),
        _buildTextField(viewModel.landmarkController, hintText: localizations.addRequestView_landmark, isText: true),

        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_routeType),
        _buildDropdown<String>(
          items: viewModel.routeTypeOptions,
          selectedValue: viewModel.selectedRouteType,
          onChanged: (value) => viewModel.setSelectedRouteType(value!),
          hint: localizations.addRequestView_routeType,
          getItemName: (value) {
            switch (value) {
              case "circle":
                return localizations.addRequestView_routeCircle; // например: "По кругу"
              case "polygon":
                return localizations.addRequestView_routePolygon; // например: "По Квадрату/Полигону"
              case "line":
                return localizations.addRequestView_routeLine; // например: "По линии"
              default:
                return value;
            }
          },
        ),
        SizedBox(height: 16),
        if (viewModel.selectedRouteType != null) ...[
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
                      builder: (context) => MapSelectLocationView(
                        routeType: viewModel.selectedRouteType, // Передаём выбранный тип маршрута
                      ),
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
                    _buildTextField(viewModel.flightHeightController, hintText: '0', isDecimal: true),
                  ],
                ),
              ),
              // Показываем поле радиуса только если выбран тип "По кругу"
              if (viewModel.selectedRouteType == "circle") ...[
                SizedBox(width: 16),
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
        SizedBox(height: 16),
        _buildLabel(localizations.addRequestView_flightPurpose),
        _buildDropdown<String>(
          items: viewModel.purposeList,
          selectedValue: viewModel.selectedPurpose,
          onChanged: (value) => viewModel.setPurpose(value!),
          hint: localizations.addRequestView_flightPurpose,
          getItemName: (purpose) => purpose,
        ),
        if (viewModel.selectedPurpose == "Другое") ...[
          SizedBox(height: 16),
          _buildLabel("Введите цель полёта"), // Можно заменить на локализованную строку
          _buildTextField(viewModel.customPurposeController, hintText: "Цель полёта", isText: true),
        ],

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
        _buildPhoneList(viewModel),
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
              backgroundColor: Colors.black,
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

  Widget _buildPhoneList(AddRequestViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Отображение номеров телефонов от выбранных операторов
        ...viewModel.operatorPhoneControllers.map((controller) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Номер телефона оператора',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        )),
        // Отображение вручную добавленных номеров
        ...viewModel.manualPhoneControllers.map((controller) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Дополнительный номер телефона',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    viewModel.manualPhoneControllers.remove(controller);
                  });
                },
              )
            ],
          ),
        )),
        // Кнопка для добавления нового номера телефона
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                viewModel.manualPhoneControllers.add(TextEditingController());
              });
            },
            icon: Icon(Icons.add),
            label: Text("Добавить номер телефона"),
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

  Widget _buildTimePickerField({required DateTime? time, required String hintText, required ValueChanged<DateTime?> onTimeSelected}) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
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

  Widget _buildTimeDisplay(DateTime? time, String hintText) {
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
              time == null ? hintText : DateFormat('HH:mm').format(time),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          Icon(Icons.access_time, color: Colors.grey),
        ],
      ),
    );
  }
}
