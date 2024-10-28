import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'map_share_location_view.dart';

class ShowRequestView extends StatelessWidget {
  final Map<String, String> request;

  ShowRequestView({required this.request});

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
                        request['number']!,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(request['status']!),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusText(request['status']!, localizations),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  if (request['status'] == 'confirmed')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Переход на карту для трансляции
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MapShareLocationView()),
                          );
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

          if (request['status'] == 'pending')
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
