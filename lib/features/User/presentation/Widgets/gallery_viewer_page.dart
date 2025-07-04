import 'package:flutter/material.dart';
import 'package:good_one_app/Core/infrastructure/api/api_endpoints.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class GalleryViewerPage extends StatefulWidget {
  final int initialIndex;

  const GalleryViewerPage({
    super.key,
    required this.initialIndex,
  });

  @override
  State<GalleryViewerPage> createState() => _GalleryViewerPageState();
}

class _GalleryViewerPageState extends State<GalleryViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        return Scaffold(
          backgroundColor: AppColors.blackText,
          appBar: AppBar(
            backgroundColor: AppColors.blackText,
            foregroundColor: AppColors.whiteText,
            title: Text(
                '${_currentIndex + 1} / ${userManager.selectedContractor!.gallery!.length}'),
          ),
          body: PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: userManager.selectedContractor!.gallery!.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(
                    '${ApiEndpoints.imageBaseUrl}/${userManager.selectedContractor!.gallery![index]}'),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(
              color: AppColors.blackText,
            ),
          ),
        );
      },
    );
  }
}
