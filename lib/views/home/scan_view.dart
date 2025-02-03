import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:safe_sky/services/request_service.dart';
import 'package:safe_sky/views/map/map_share_location_view.dart';
import '../../viewmodels/map_share_location_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScanView extends StatefulWidget {
  @override
  _ScanViewState createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  bool _isFlashOn = false;
  bool isLoading = false;
  bool isProcessing = false;
  final MobileScannerController _controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              // Берём только первый найденный QR-код
              final Barcode? barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
              final String? code = barcode?.rawValue;
              if (code != null) {
                _onQRCodeScanned(code);
              }
            },
          ),
          _buildOverlay(),
          if (isLoading) _buildLoadingIndicator(),
          _buildMessage(localizations),
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
    final localizations = AppLocalizations.of(context)!;
    if (code.isEmpty || isProcessing) return;
    isProcessing = true;
    // Останавливаем сканер, чтобы не было повторных срабатываний
    _controller.stop();
    setState(() {
      isLoading = true;
    });

    try {
      final locationVM = Provider.of<MapShareLocationViewModel>(context, listen: false);

      if (locationVM.isSharingLocation) {
        final shouldStop = await _showStopDialog(context);
        if (shouldStop == true) {
          await locationVM.stopLocationSharing(context);
        } else {
          setState(() {
            isLoading = false;
          });
          // Если пользователь отказался от остановки, возобновляем сканирование
          _controller.start();
          return;
        }
      }

      // Получаем модель по uuid через наш сервис
      final planDetail = await RequestService().fetchPlanDetailByUuid(code);

      // Переходим на экран MapShareLocationView, передавая модель
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MapShareLocationView(planDetailModel: planDetail),
        ),
      );
    } catch (e) {
      // Преобразуем сообщение об ошибке из UTF-8, если необходимо
      final errorMsg = utf8.decode(utf8.encode(e.toString()));
      _showSnackBar(errorMsg);
      setState(() {
        isLoading = false;
      });
      // Возобновляем сканирование, если произошла ошибка
      _controller.start();
    } finally {
      isProcessing = false;
    }
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

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildMessage(AppLocalizations localizations) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          localizations.scanView_scanMessage,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<bool?> _showStopDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.scanView_stopExistingLocationSharing),
          content: Text(localizations.scanView_locationSharingActive),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.scanView_back),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(localizations.scanView_continue),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
