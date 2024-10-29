import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart'; // Импортируем LatLng для работы с координатами

import '../map_select_location_view.dart';

class AddRequestView extends StatefulWidget {
  @override
  _AddRequestViewState createState() => _AddRequestViewState();
}

class _AddRequestViewState extends State<AddRequestView> {
  final _requesterNameController = TextEditingController();
  final _operatorNameController = TextEditingController(text: "Закиров Аслиддин Темурович");
  final _operatorPhoneController = TextEditingController(text: "+998 ");
  final _emailController = TextEditingController(text: "sample@gmail.com");
  final _permitNumberController = TextEditingController();
  final _contractNumberController = TextEditingController();
  final _noteController = TextEditingController();
  final _phoneController = TextEditingController();

  // Добавляем контроллеры для отображения координат и радиуса
  final _latLngController = TextEditingController();
  final _radiusController = TextEditingController();

  // Остальные переменные и контроллеры для работы с датой и полями ввода
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _flightStartDate;
  DateTime? _flightEndDate;
  DateTime? _permitDate;
  DateTime? _contractDate;

  final __startDateController = TextEditingController();
  final _permitDateController = TextEditingController();
  final _contractDateController = TextEditingController();

  // Переменные состояния для выпадающих списков
  String? _selectedModel;
  String? _selectedRegion;
  String? _selectedPurpose;

  String _selectedCountryCode = "+998"; // Значение по умолчанию для кода страны

  final List<Map<String, String>> _countries = [
    {"code": "+998", "flag": "🇺🇿"},
    {"code": "+1", "flag": "🇺🇸"},
    {"code": "+44", "flag": "🇬🇧"},
    {"code": "+7", "flag": "🇷🇺"},
    {"code": "+997", "flag": "🇰🇿"},
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.text = formatPhoneNumber("+998 99 333 11 22");
  }

  // Метод для форматирования номера телефона (отделение кода страны)
  String formatPhoneNumber(String phoneNumber) {
    final countryCode = '+998';
    if (phoneNumber.startsWith(countryCode)) {
      return phoneNumber.replaceFirst(countryCode, '').trim();
    }
    return phoneNumber;
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                localizations.submitRequest,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            _buildLabel(localizations.flightStartDate),
            _buildDateOnlyPickerField(
              date: _startDate,
              hintText: "05.09.2024",
              onDateSelected: (date) {
                setState(() {
                  _startDate = date;
                  __startDateController.text = DateFormat('dd.MM.yyyy').format(date!);
                });
              },
            ),
            SizedBox(height: 16),
            _buildLabel(localizations.requesterName),
            _buildTextField(_requesterNameController, hintText: localizations.requesterName),
            SizedBox(height: 16),
            _buildLabel(localizations.model),
            _buildDropdown(["Модель 1", "Модель 2", "Модель 3"], _selectedModel, (value) {
              setState(() {
                _selectedModel = value;
              });
            }, hint: localizations.model),
            SizedBox(height: 16),
            _buildLabel(localizations.flightSign),
            _buildDropdown(["Знак 1", "Знак 2", "Знак 3"], _selectedModel, (value) {
              setState(() {
                _selectedModel = value;
              });
            }, hint: localizations.flightSign),
            SizedBox(height: 16),
            _buildLabel(localizations.flightTimes),
            Column(
              children: [
                _buildDatePickerField(
                  date: _flightStartDate,
                  hintText: "01.01.2023 15:03",
                  onDateSelected: (date) {
                    setState(() {
                      _flightStartDate = date;
                    });
                  },
                ),
                SizedBox(height: 16),
                _buildDatePickerField(
                  date: _flightEndDate,
                  hintText: "01.01.2023 17:06",
                  onDateSelected: (date) {
                    setState(() {
                      _flightEndDate = date;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLabel(localizations.region),
            _buildDropdown(["Ташкент", "Самарканд", "Бухара"], _selectedRegion, (value) {
              setState(() {
                _selectedRegion = value;
              });
            }, hint: localizations.region),
            SizedBox(height: 16),
            _buildLabel(localizations.coordinates),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _latLngController,
                    hintText: localizations.coordinates,
                    readOnly: true,
                  ),
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
                      // Извлекаем координаты и радиус из result
                      LatLng coordinates = result['coordinates'];
                      double? radius = result['radius'];

                      print("Location sharing started");
                      // Обновляем соответствующие текстовые поля
                      setState(() {
                        _latLngController.text = '${coordinates.latitude.toStringAsFixed(5)} ${coordinates.longitude.toStringAsFixed(5)}';
                        _radiusController.text = radius != null ? radius.toStringAsFixed(0) : '';
                      });

                    }
                  },
                  child: Text(localizations.map),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(localizations.flightHeight),
                        _buildTextField(
                          TextEditingController(text: "130"),
                          hintText: localizations.height,
                        ),
                      ],
                    )
                ),
                SizedBox(width: 16),
                Expanded(
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(localizations.flightRadius),
                        _buildTextField(
                          _radiusController,
                          hintText: localizations.radius,
                        ),
                      ],
                    )
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLabel(localizations.flightPurpose),
            _buildDropdown(["Туризм", "Научные исследования", "Грузоперевозки"], _selectedPurpose, (value) {
              setState(() {
                _selectedPurpose = value;
              });
            }, hint: localizations.flightPurpose),
            SizedBox(height: 16),
            _buildLabel(localizations.operatorName),
            _buildTextField(_operatorNameController, hintText: localizations.operatorName),
            SizedBox(height: 16),
            _buildLabel(localizations.operatorPhone),
            _buildPhoneField(),
            SizedBox(height: 16),
            _buildLabel(localizations.email),
            _buildTextField(_emailController, hintText: localizations.email),
            SizedBox(height: 16),
            _buildLabel(localizations.specialPermit),
            Row(
              children: [
                Expanded(child: _buildTextField(_permitNumberController, hintText: localizations.permitNumber)),
                SizedBox(width: 16),
                Expanded(
                  child:_buildDateOnlyPickerField(
                    date: _permitDate,
                    hintText: "05.09.2024",
                    onDateSelected: (date) {
                      setState(() {
                        _permitDate = date;
                        _permitDateController.text = DateFormat('dd.MM.yyyy').format(date!);
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLabel(localizations.contract),
            Row(
              children: [
                Expanded(child: _buildTextField(_contractNumberController, hintText: localizations.contractNumber)),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDateOnlyPickerField(
                    date: _contractDate,
                    hintText: "05.09.2024",
                    onDateSelected: (date) {
                      setState(() {
                        _contractDate = date;
                        _contractDateController.text = DateFormat('dd.MM.yyyy').format(date!);
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLabel(localizations.note),
            _buildTextField(_noteController, hintText: localizations.optional),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(

                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text(localizations.submit, style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  // Метод для поля с телефоном
  Widget _buildPhoneField() {
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
              value: _selectedCountryCode,
              items: _countries.map((country) {
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
              onChanged: (value) {
                setState(() {
                  _selectedCountryCode = value!;
                  _phoneController.text = ""; // Сбрасываем номер после смены кода страны
                });
              },
            ),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: localizations.phone,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Label widget
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  // Date Picker field
  // Date Picker field
  Widget _buildDatePickerField({
    required DateTime? date,
    required String hintText,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            DateTime newDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            onDateSelected(newDateTime);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date == null
                    ? hintText
                    : DateFormat('dd.MM.yyyy HH:mm').format(date),
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Dropdown field
  Widget _buildDropdown(List<String> items, String? selectedValue, ValueChanged<String?> onChanged, {required String hint}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(fontSize: 16)),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Text Field
  Widget _buildTextField(TextEditingController controller, {required String hintText, bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
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

  // Date Picker field только с выбором даты
  Widget _buildDateOnlyPickerField({
    required DateTime? date,
    required String hintText,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date == null ? hintText : DateFormat('dd.MM.yyyy').format(date),
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

}
