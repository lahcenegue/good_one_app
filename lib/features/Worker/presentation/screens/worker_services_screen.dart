import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Infrastructure/Api/api_endpoints.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Error/error_widget.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/edit_service.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkerServicesScreen extends StatelessWidget {
  const WorkerServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        return Scaffold(
          backgroundColor: AppColors.lightGray,
          appBar: _buildModernAppBar(context),
          body: RefreshIndicator(
            onRefresh: workerManager.fetchMyServices,
            color: AppColors.primaryColor,
            backgroundColor: AppColors.backgroundCard,
            child: workerManager.isServiceLoading
                ? const LoadingIndicator()
                : workerManager.servicesError != null
                    ? AppErrorWidget(
                        message: workerManager.servicesError!,
                        onRetry: () {
                          workerManager.clearError('services');
                          workerManager.fetchMyServices();
                        },
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildAddServiceButton(context, workerManager),
                            _buildMyServicesList(context, workerManager),
                            SizedBox(height: context.getHeight(16)),
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Text(
        AppLocalizations.of(context)!.services,
        style: AppTextStyles.appBarTitle(context),
      ),
      centerTitle: true,
    );
  }

  Widget _buildAddServiceButton(
    BuildContext context,
    WorkerManagerProvider workerProvider,
  ) {
    return Padding(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: PrimaryButton(
          width: context.getWidth(160),
          text: AppLocalizations.of(context)!.addService,
          onPressed: () {
            workerProvider.clearError('services');
            NavigationService.navigateTo(AppRoutes.workerAddService);
          },
        ),
      ),
    );
  }

  Widget _buildMyServicesList(
    BuildContext context,
    WorkerManagerProvider workerManager,
  ) {
    if (workerManager.myServices.isEmpty) {
      return _ModernEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      itemCount: workerManager.myServices.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: context.getHeight(16)),
      itemBuilder: (BuildContext context, int index) {
        final service = workerManager.myServices[index];
        return ModernServiceCard(
          service: service,
          animationDelay: index * 100,
        );
      },
    );
  }
}

/// Modern empty state with beautiful illustration
class _ModernEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.getWidth(24)),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: context.getWidth(80),
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: context.getHeight(24)),
            Text(
              AppLocalizations.of(context)!.noServicesAvailable,
              style: AppTextStyles.title2(context).copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.getHeight(12)),
            Text(
              AppLocalizations.of(context)!.createFirstServicePrompt,
              style: AppTextStyles.text(context).copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern service card with enhanced design
class ModernServiceCard extends StatefulWidget {
  final dynamic service; // Replace with your actual service model type
  final int animationDelay;

  const ModernServiceCard({
    super.key,
    required this.service,
    this.animationDelay = 0,
  });

  @override
  State<ModernServiceCard> createState() => _ModernServiceCardState();
}

class _ModernServiceCardState extends State<ModernServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation with delay
    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.service.gallary.isNotEmpty;
    final (statusColor, statusText, statusIcon) = _getStatusDetails(context);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                // Status header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.getWidth(16)),
                  decoration: BoxDecoration(
                    color: statusColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        statusIcon,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: context.getWidth(8)),
                      Text(
                        statusText,
                        style: AppTextStyles.subTitle(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.white, size: 18),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditService(service: widget.service),
                              ),
                            );
                          },
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content
                Padding(
                  padding: EdgeInsets.all(context.getWidth(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service info with image
                      _ModernServiceInfo(
                        service: widget.service,
                        hasImage: hasImage,
                      ),
                      SizedBox(height: context.getHeight(20)),

                      // Details grid
                      _ModernServiceDetailsGrid(service: widget.service),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, String, IconData) _getStatusDetails(BuildContext context) {
    if (widget.service.active == 1) {
      return (
        Colors.green,
        AppLocalizations.of(context)!.active,
        Icons.check_circle,
      );
    } else {
      return (
        Colors.orange,
        AppLocalizations.of(context)!.inactive,
        Icons.pause_circle,
      );
    }
  }
}

/// Modern service info section
class _ModernServiceInfo extends StatelessWidget {
  final dynamic service;
  final bool hasImage;

  const _ModernServiceInfo({
    required this.service,
    required this.hasImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service image
        ClipRRect(
          borderRadius: BorderRadius.circular(context.getAdaptiveSize(16)),
          child: hasImage
              ? Image.network(
                  '${ApiEndpoints.imageBaseUrl}/${service.gallary.first}',
                  width: context.getWidth(100),
                  height: context.getWidth(100),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: context.getWidth(100),
                    height: context.getWidth(100),
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey.shade400,
                      size: context.getAdaptiveSize(40),
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: context.getWidth(100),
                      height: context.getWidth(100),
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  width: context.getWidth(100),
                  height: context.getWidth(100),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(context.getAdaptiveSize(16)),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey.shade400,
                    size: context.getAdaptiveSize(40),
                  ),
                ),
        ),
        SizedBox(width: context.getWidth(16)),

        // Service details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.service,
                style: AppTextStyles.title2(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: context.getHeight(8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.getWidth(12),
                  vertical: context.getHeight(6),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  service.subcategory.name,
                  style: AppTextStyles.text(context).copyWith(
                    color: AppColors.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: context.getHeight(12)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.getWidth(12),
                  vertical: context.getHeight(8),
                ),
                decoration: BoxDecoration(
                  color: _getPricingTypeColor(service.pricingType)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getPricingTypeColor(service.pricingType)
                        .withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  service.getPriceDisplay(),
                  style: AppTextStyles.text(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getPricingTypeColor(service.pricingType),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPricingTypeColor(String? pricingType) {
    switch (pricingType) {
      case 'hourly':
        return Colors.blue;
      case 'daily':
        return Colors.green;
      case 'fixed':
        return Colors.orange;
      default:
        return AppColors.primaryColor;
    }
  }
}

/// Modern service details grid
class _ModernServiceDetailsGrid extends StatelessWidget {
  final dynamic service;

  const _ModernServiceDetailsGrid({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_rounded,
                size: 16,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: context.getWidth(8)),
              Text(
                AppLocalizations.of(context)!.serviceDescription,
                style: AppTextStyles.text(context).copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(8)),
          Text(
            service.about,
            style: AppTextStyles.text(context).copyWith(
              color: Colors.grey.shade800,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
