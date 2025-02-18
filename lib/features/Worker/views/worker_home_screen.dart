import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';
import 'package:provider/provider.dart';

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerMaganerProvider>(
      builder: (context, workerManager, _) {
        return RefreshIndicator(
          onRefresh: () async {},
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.getWidth(20),
              vertical: context.getHeight(10),
            ),
            child: Center(
              child: Text('comming soon'),
            ),
          ),
        );
      },
    );
  }
}
