import 'package:flutter/material.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ImagePickerWidget extends StatelessWidget {
  const ImagePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Images (please upload unique images to attract customers)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showImageSourceDialog(context, provider),
              child: const Text('Add Photos or Videos'),
            ),
            const SizedBox(height: 10),
            if (provider.galleryImages.isNotEmpty) ...[
              const Text('All Photos and Videos'),
              const SizedBox(height: 5),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.galleryImages.length,
                itemBuilder: (context, index) {
                  final image = provider.galleryImages[index];
                  return ListTile(
                    leading: image.image != null
                        ? Image.network(
                            image.image!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          )
                        : const Icon(Icons.image),
                    title: Text('Image ${index + 1}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => provider.removeServiceImage(image.id!),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  void _showImageSourceDialog(
      BuildContext context, WorkerManagerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // For simplicity, using a placeholder serviceId; this should be dynamic
              provider.uploadServiceImage(
                context,
                ImageSource.camera,
                "1",
              );
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // For simplicity, using a placeholder serviceId; this should be dynamic
              provider.uploadServiceImage(
                context,
                ImageSource.gallery,
                "1",
              );
            },
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
  }
}
