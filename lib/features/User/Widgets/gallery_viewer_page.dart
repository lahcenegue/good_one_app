import 'package:flutter/material.dart';
import 'package:good_one_app/Providers/user_state_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

import '../../../Core/infrastructure/api/api_endpoints.dart';

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
    return Consumer<UserStateProvider>(
      builder: (context, userManager, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
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
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }
}
