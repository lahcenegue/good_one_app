import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_assets.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Providers/User/booking_manager_provider.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

/// Allows users to select a location for the booking.
class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingManagerProvider>(
      builder: (context, bookingManager, _) {
        final initialLocation = bookingManager.selectedLocation ??
            const LatLng(51.0486, -114.0708); // Default to Calgary Alberta
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.location,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: bookingManager.isLocationSelected
              ? _buildSelectedLocationView(
                  context, bookingManager, initialLocation)
              : _buildSearchLocationView(
                  context, bookingManager, initialLocation),
        );
      },
    );
  }

  /// Displays the map for searching a location.
  Widget _buildSearchLocationView(BuildContext context,
      BookingManagerProvider bookingManager, LatLng initialLocation) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: bookingManager.mapController,
                options: MapOptions(
                  initialCenter: initialLocation,
                  initialZoom: 15.0,
                  onMapReady: () {
                    if (bookingManager.isLocationSelected &&
                        bookingManager.selectedLocation != null) {
                      bookingManager.mapController
                          .move(bookingManager.selectedLocation!, 15.0);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                ],
              ),
              const Center(
                  child: Icon(Icons.location_pin,
                      color: AppColors.primaryColor, size: 40)),
              Positioned(
                bottom: context.getHeight(16),
                right: context.getWidth(16),
                child: Container(
                  padding: EdgeInsets.all(context.getWidth(8)),
                  decoration: const BoxDecoration(
                      color: AppColors.primaryColor, shape: BoxShape.circle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => bookingManager.getCurrentLocation(context),
                    child: const Icon(Icons.my_location,
                        color: Colors.white, size: 24),
                  ),
                ),
              ),
              if (bookingManager.isLocationScreenLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(context.getHeight(12)),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: bookingManager.locationSearchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchCityOrPlace,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => bookingManager.searchLocation(context),
                  ),
                ),
                onSubmitted: (_) => bookingManager.searchLocation(context),
              ),
              SizedBox(height: context.getHeight(12)),
              PrimaryButton(
                text: AppLocalizations.of(context)!.confirmThisLocation,
                onPressed: () async =>
                    await bookingManager.confirmMapLocation(),
              ),
              SizedBox(height: context.getHeight(12)),
            ],
          ),
        ),
      ],
    );
  }

  /// Displays the confirmed location with a map marker.
  Widget _buildSelectedLocationView(BuildContext context,
      BookingManagerProvider bookingManager, LatLng initialLocation) {
    final location = bookingManager.mapController.camera.center;
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: bookingManager.mapController,
                options: MapOptions(
                  initialCenter: location,
                  initialZoom: 17.0,
                  onTap: (tapPosition, point) {
                    bookingManager.mapController.move(point, 17.0);
                    bookingManager.confirmMapLocation();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: location,
                        width: 80,
                        height: 80,
                        child: const Icon(Icons.location_on,
                            color: AppColors.primaryColor, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: context.getWidth(16),
                left: context.getWidth(16),
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: bookingManager.clearLocationSelection,
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(context.getAdaptiveSize(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(AppAssets.cityImageLink,
                        width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  SizedBox(width: context.getWidth(16)),
                  SizedBox(
                    width: context.getAdaptiveSize(260),
                    height: context.getAdaptiveSize(60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          bookingManager.locationAddress.isNotEmpty
                              ? bookingManager.locationAddress
                              : AppLocalizations.of(context)!
                                  .selectedLocationOnMap,
                          style: AppTextStyles.title2(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                          style: AppTextStyles.text(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.getHeight(20)),
              PrimaryButton(
                text: AppLocalizations.of(context)!.next,
                onPressed: () {
                  bookingManager.setLocation(
                    location,
                    bookingManager.locationAddress.isNotEmpty
                        ? bookingManager.locationAddress
                        : AppLocalizations.of(context)!.selectedLocationOnMap,
                  );

                  Navigator.of(context)
                      .pushNamed(AppRoutes.bookingSummaryScreen);
                },
              ),
              SizedBox(height: context.getHeight(20)),
            ],
          ),
        ),
      ],
    );
  }
}
