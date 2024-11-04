import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:safe_sky/services/request_service.dart';
import 'package:safe_sky/views/map/map_share_location_view.dart';
import '../../models/request/status_model.dart';
import '../../viewmodels/map_share_location_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScanView extends StatefulWidget {
  @override
  _ScanViewState createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  bool _isFlashOn = false;
  bool isDialogOpen = false;
  bool isLoading = false;
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
    if (code.isNotEmpty && !isDialogOpen) {
      isDialogOpen = true;
      setState(() {
        isLoading = true;
      });

      try {
        final locationVM = Provider.of<MapShareLocationViewModel>(context, listen: false);

        if (locationVM.isSharingLocation) {
          final shouldStop = await _showStopDialog(context);
          if (shouldStop == true) {
            await locationVM.stopLocationSharing();
          } else {
            isDialogOpen = false;
            setState(() {
              isLoading = false;
            });
            return;
          }
        }

        StatusModel status = await RequestService().sendCodeAndGetStatus(code);

        if (status.status == 'success') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MapShareLocationView()),
          );
        } else {
          _showErrorDialog(context, status.message);
        }

      } catch (e) {
        _showErrorDialog(context, localizations.errorFetchingData);
      } finally {
        isDialogOpen = false;
        setState(() {
          isLoading = false;
        });
      }
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
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildMessage(AppLocalizations localizations) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          localizations.scanMessage,
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
          title: Text(localizations.stopExistingLocationSharing),
          content: Text(localizations.locationSharingActive),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.back),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(localizations.stop),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
