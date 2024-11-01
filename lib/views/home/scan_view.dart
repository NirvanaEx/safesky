import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:safe_sky/views/map/map_share_location_view.dart';

import '../../viewmodels/map_share_location_viewmodel.dart';
import 'package:provider/provider.dart';

class ScanView extends StatefulWidget {
  @override
  _ScanViewState createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  bool _isFlashOn = false;
  bool isDialogOpen = false; // Флаг для отслеживания состояния диалога
  final MobileScannerController _controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  _onQRCodeScanned(code);
                }
              }
            },
          ),
          _buildOverlay(),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                icon: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: _toggleFlash,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onQRCodeScanned(String code) async {
    if (code.isNotEmpty && !isDialogOpen) { // Проверяем флаг перед вызовом диалога
      isDialogOpen = true; // Устанавливаем флаг перед показом диалога

      final locationVM = Provider.of<MapShareLocationViewModel>(context, listen: false);

      // Проверяем, активна ли задача
      if (locationVM.isSharingLocation) {
        final shouldStop = await _showStopDialog(context);
        if (shouldStop == true) {
          await locationVM.stopLocationSharing(); // Останавливаем задачу, если пользователь подтвердил
        } else {
          isDialogOpen = false; // Сбрасываем флаг, если пользователь отменил
          return;
        }
      }

      // Переходим на страницу с картой
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MapShareLocationView()),
      );

      isDialogOpen = false; // Сбрасываем флаг после перехода
    }
  }

  Future<bool?> _showStopDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Stop Existing Location Sharing?"),
          content: Text("A location sharing task is already active. Would you like to stop it and start a new one?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false); // Пользователь выбрал отмену
              },
            ),
            TextButton(
              child: Text("Stop & Start New"),
              onPressed: () {
                Navigator.of(context).pop(true); // Пользователь выбрал остановку задачи
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleFlash() async {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _controller.toggleTorch();
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.5),
          width: double.infinity,
          height: double.infinity,
        ),
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

