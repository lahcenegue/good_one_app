import 'package:flutter/material.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';
import 'package:provider/provider.dart';

class SummaryCardWidget extends StatelessWidget {
  const SummaryCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, provider, _) {
        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Service Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                    'Service: ${provider.selectedCategory?.name ?? "Not selected"}'),
                Text(
                    'Subcategory: ${provider.selectedSubcategory?.name ?? "Not selected"}'),
                Text(
                    'Service Price: \$${provider.servicePrice?.toStringAsFixed(2) ?? "Not set"}'),
                const Text(
                    'Payment Method: Cash'), // Assuming cash as per screenshot
                const SizedBox(height: 10),
                const Text(
                  'Images',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8.0,
                  children: provider.galleryImages.map((image) {
                    return image.image != null
                        ? Image.network(
                            image.image!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          )
                        : const Icon(Icons.image);
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
