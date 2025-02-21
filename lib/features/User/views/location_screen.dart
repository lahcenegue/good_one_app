import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../Core/presentation/Theme/app_text_styles.dart';
import '../../../Core/presentation/resources/app_colors.dart';
import '../../../Providers/user_manager_provider.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        // Initialize with provider data if available
        LatLng initialLocation = userManager.selectedLocation ??
            LatLng(43.6532, -79.3832); // Default to Toronto

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Location',
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: userManager.locationSelected
              ? _buildSelectedLocationView(
                  context, userManager, initialLocation)
              : _buildSearchLocationView(context, userManager, initialLocation),
        );
      },
    );
  }

  Widget _buildSearchLocationView(
    BuildContext context,
    UserManagerProvider userManager,
    LatLng initialLocation,
  ) {
    return Column(
      children: [
        // Map view for initial state
        Expanded(
          child: Stack(
            children: [
              // Map layer
              FlutterMap(
                mapController: userManager.mapController,
                options: MapOptions(
                  initialCenter: initialLocation,
                  initialZoom: 15.0,
                  onMapReady: () {
                    // If we have a stored location, let's use it
                    if (userManager.hasSelectedLocation &&
                        userManager.selectedLocation != null) {
                      userManager.mapController
                          .move(userManager.selectedLocation!, 15.0);
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

              // Existing UI elements...
              Center(
                child: Icon(
                  Icons.location_pin,
                  color: AppColors.primaryColor,
                  size: context.getAdaptiveSize(40),
                ),
              ),

              // GPS Location Button - top right
              Positioned(
                bottom: context.getHeight(16),
                right: context.getWidth(16),
                child: Container(
                  padding: EdgeInsets.all(context.getWidth(8)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => userManager.getCurrentLocation(context),
                    child: Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: context.getAdaptiveSize(24),
                    ),
                  ),
                ),
              ),

              // Loading indicator
              if (userManager.locationScreenIsLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Search box
        Container(
          padding: EdgeInsets.all(context.getHeight(12)),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: userManager.locationSearchController,
                decoration: InputDecoration(
                  hintText: 'Search city or place...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => userManager.searchLocation(context),
                  ),
                ),
                onSubmitted: (_) => userManager.searchLocation(context),
              ),

              SizedBox(height: context.getHeight(12)),

              // Confirm location button - bottom center
              PrimaryButton(
                text: 'Confirm This Location',
                onPressed: () => userManager.confirmMapLocation(),
              ),
              SizedBox(height: context.getHeight(12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedLocationView(
    BuildContext context,
    UserManagerProvider userManager,
    LatLng initialLocation,
  ) {
    LatLng location = userManager.mapController.camera.center;

    return Column(
      children: [
        // Map with location pin
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: userManager.mapController,
                options: MapOptions(
                  initialCenter: location,
                  initialZoom: 17.0,
                  onTap: (tapPosition, point) {
                    // Update map center
                    userManager.mapController.move(point, 17.0);
                    userManager.reverseGeocode(point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    //userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: location,
                        width: context.getAdaptiveSize(80),
                        height: context.getAdaptiveSize(80),
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primaryColor,
                          size: context.getAdaptiveSize(40),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Back to search button
              Positioned(
                top: context.getWidth(16),
                left: context.getWidth(16),
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => userManager.setLocationSelectedState(false),
                ),
              ),
            ],
          ),
        ),

        // Location card and next button
        Container(
          //color: Colors.white,
          padding: EdgeInsets.all(context.getAdaptiveSize(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location card
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1517090504586-fde19ea6066f?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                      width: context.getAdaptiveSize(60),
                      height: context.getAdaptiveSize(60),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    width: context.getWidth(16),
                  ),
                  SizedBox(
                    width: context.getAdaptiveSize(260),
                    height: context.getAdaptiveSize(60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          userManager.locationSearchController.text.isNotEmpty
                              ? userManager.locationSearchController.text
                              : 'Selected location on map',
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

              // Next button - Now saves to provider
              PrimaryButton(
                  text: 'Next',
                  onPressed: () {
                    userManager.setLocation(
                        location,
                        userManager.locationSearchController.text.isNotEmpty
                            ? userManager.locationSearchController.text
                            : 'Selected location on map');
                  }),

              SizedBox(height: context.getHeight(20)),
            ],
          ),
        ),
      ],
    );
  }
}
