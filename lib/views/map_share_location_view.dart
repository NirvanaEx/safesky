import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../viewmodels/map_share_location_viewmodel.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;

class MapShareLocationView extends StatefulWidget {
  @override
  _MapShareLocationViewState createState() => _MapShareLocationViewState();
}

class _MapShareLocationViewState extends State<MapShareLocationView> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    final locationVM = Provider.of<MapShareLocationViewModel>(context, listen: false);

    // Загружаем текущее местоположение при инициализации
    locationVM.loadCurrentLocation();

    // Добавляем слушатель изменений для автоматического перехода к местоположению при его загрузке
    locationVM.addListener(() {
      if (locationVM.currentLocation != null && !locationVM.isLoadingLocation) {
        _animateToUserLocation();
      }
    });
  }

  Future<void> _animateToUserLocation() async {
    final locationVM = Provider.of<MapShareLocationViewModel>(context, listen: false);

    if (locationVM.currentLocation == null) return;

    LatLng startLocation = _mapController.center;
    double startZoom = _mapController.zoom;
    double startRotation = _mapController.rotation;
    LatLng targetLocation = locationVM.currentLocation!;
    double targetZoom = locationVM.defaultZoom;
    double targetRotation = 0.0;

    const int steps = 30;
    const int delayMilliseconds = 16;

    for (int i = 0; i <= steps; i++) {
      final double lat = startLocation.latitude +
          (targetLocation.latitude - startLocation.latitude) * (i / steps);
      final double lng = startLocation.longitude +
          (targetLocation.longitude - startLocation.longitude) * (i / steps);
      final double zoom = startZoom + (targetZoom - startZoom) * (i / steps);
      final double rotation = startRotation +
          (targetRotation - startRotation) * (i / steps);

      _mapController.moveAndRotate(LatLng(lat, lng), zoom, rotation);
      await Future.delayed(Duration(milliseconds: delayMilliseconds));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationVM = Provider.of<MapShareLocationViewModel>(context);
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
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: locationVM.currentLocation ?? LatLng(41.2995, 69.2401),
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                tileProvider: FMTC.instance('openstreetmap').getTileProvider(),
              ),
              if (locationVM.currentLocation != null)
                flutter_map.MarkerLayer(
                  markers: [
                    flutter_map.Marker(
                      width: 25,
                      height: 25,
                      point: locationVM.currentLocation!,
                      builder: (ctx) => Lottie.asset(
                        'assets/json/my_position.json',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (locationVM.isLoadingLocation)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    localizations.searchingYourLocation,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          Positioned(
            bottom: locationVM.isSharingLocation ? 180 : 120,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => _animateToUserLocation(),
              mini: true,
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: locationVM.isSharingLocation
                ? _buildSharingMenu(localizations, locationVM)
                : _buildSlideToStart(localizations, locationVM),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideToStart(AppLocalizations localizations, MapShareLocationViewModel locationVM) {
    return SlideAction(
      text: localizations.startLocationSharing,
      textStyle: TextStyle(fontSize: 18, color: Colors.black),
      innerColor: Colors.black,
      outerColor: Colors.white,
      onSubmit: () {
        // Начинаем передачу местоположения без проверки, так как она выполняется в ShowRequestView
        locationVM.startLocationSharing();
      },
      sliderButtonIcon: Icon(Icons.play_arrow, color: Colors.white),
      borderRadius: 30,
    );
  }

  Widget _buildSharingMenu(AppLocalizations localizations, MapShareLocationViewModel locationVM) {
    return Column(
      children: [
        Container(
          height: 55,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!locationVM.isPaused)
                SizedBox(
                  width: 35,
                  height: 35,
                  child: Lottie.asset('assets/json/live.json', repeat: true, fit: BoxFit.contain),
                ),
              if (locationVM.isPaused)
                Icon(Icons.pause, color: Colors.red, size: 24),
              Text(
                locationVM.isPaused ? localizations.paused : localizations.sharingLocation,
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: locationVM.stopLocationSharing,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: Icon(Icons.stop, color: Colors.white, size: 28),
                label: Text(localizations.stop, style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: locationVM.togglePause,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: Icon(
                  locationVM.isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.black,
                  size: 28,
                ),
                label: Text(
                  locationVM.isPaused ? localizations.resume : localizations.pause,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}