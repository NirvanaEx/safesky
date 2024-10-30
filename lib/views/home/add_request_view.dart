import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/add_request_viewmodel.dart';
import '../map_select_location_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddRequestView extends StatefulWidget {
  @override
  _AddRequestViewState createState() => _AddRequestViewState();
}

class _AddRequestViewState extends State<AddRequestView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddRequestViewModel>(context, listen: true);
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
              date: viewModel.startDate,
              hintText: "01.01.2023",
              onDateSelected: (date) => viewModel.updateStartDate(date!),
            ),
            SizedBox(height: 16),
            _buildLabel(localizations.requesterName),
            _buildTextField(viewModel.requesterNameController, hintText: localizations.requesterName),
            SizedBox(height: 16),
            _buildLabel(localizations.model),
            _buildDropdown(viewModel.models, viewModel.selectedModel, (value) => viewModel.setModel(value!), hint: localizations.model),
            SizedBox(height: 16),
            _buildLabel(localizations.flightSign),
            _buildDropdown(viewModel.purposes, viewModel.selectedPurpose, (value) => viewModel.setPurpose(value!), hint: localizations.flightPurpose),
            SizedBox(height: 16),
            _buildLabel(localizations.flightTimes),
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
            _buildLabel(localizations.region),
            _buildDropdown(viewModel.regions, viewModel.selectedRegion, (value) => viewModel.setRegion(value!), hint: localizations.region),
            SizedBox(height: 16),
            _buildLabel(localizations.coordinates),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(viewModel.latLngController, hintText: localizations.coordinates, readOnly: true),
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
                  child: Text(localizations.map),
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
                      _buildLabel(localizations.flightHeight),
                      _buildTextField(viewModel.flightHeightController, hintText: '0', isDecimal: true)
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(localizations.flightRadius),
                      _buildTextField(viewModel.radiusController, hintText: '0', isDecimal: true)
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLabel(localizations.flightPurpose),
            _buildDropdown(viewModel.purposes, viewModel.selectedPurpose, (value) => viewModel.setPurpose(value!), hint: localizations.flightPurpose),
            SizedBox(height: 16),
            _buildLabel(localizations.operatorName),
            _buildTextField(viewModel.operatorNameController, hintText: localizations.operatorName),
            SizedBox(height: 16),
            _buildLabel(localizations.operatorPhone),
            _buildPhoneField(viewModel, context),
            SizedBox(height: 16),
            _buildLabel(localizations.email),
            _buildTextField(viewModel.emailController, hintText: 'my@mail.com'),
            SizedBox(height: 16),
            _buildLabel(localizations.specialPermit),
            Row(
              children: [
                Expanded(child: _buildTextField(viewModel.permitNumberController, hintText: localizations.permitNumber)),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDateOnlyPickerField(
                    date: viewModel.permitDate,
                    hintText: "05.09.2024",
                    onDateSelected: (date) => viewModel.updatePermitDate(date!),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLabel(localizations.contract),
            Row(
              children: [
                Expanded(child: _buildTextField(viewModel.contractNumberController, hintText: localizations.contractNumber)),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDateOnlyPickerField(
                    date: viewModel.contractDate,
                    hintText: "05.09.2024",
                    onDateSelected: (date) => viewModel.updateContractDate(date!),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLabel(localizations.note),
            _buildTextField(viewModel.noteController, hintText: localizations.optional),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => viewModel.submitRequest(),
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
        bool isDecimal = false, // Новый параметр для выбора типа чисел
      }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isDecimal ? TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
      inputFormatters: [
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
