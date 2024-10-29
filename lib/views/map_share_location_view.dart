import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

import '../viewmodels/location_viewmodel.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final locationVM = Provider.of<LocationViewModel>(context);
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
              center: LatLng(41.2995, 69.2401),
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                tileProvider: FMTC.instance('openstreetmap').getTileProvider(),
              ),
            ],
          ),
          Positioned(
            bottom: locationVM.isSharingLocation ? 180 : 120,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => locationVM.animateToUserLocation(_mapController),
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

  Widget _buildSlideToStart(AppLocalizations localizations, LocationViewModel locationVM) {
    return SlideAction(
      text: localizations.startLocationSharing,
      textStyle: TextStyle(fontSize: 18, color: Colors.black),
      innerColor: Colors.black,
      outerColor: Colors.white,
      onSubmit: () {
        locationVM.startLocationSharing();
      },
      sliderButtonIcon: Icon(Icons.play_arrow, color: Colors.white),
      borderRadius: 30,
    );
  }

  Widget _buildSharingMenu(AppLocalizations localizations, LocationViewModel locationVM) {
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
