// // Using static methods
// Container(
//   width: SizeConfig.getProportionateScreenWidth(100, context),
//   height: SizeConfig.getProportionateScreenHeight(50, context),
//   padding: EdgeInsets.all(SizeConfig.adaptiveSize(16, context)),
// );

// // Using extension methods (more concise)
// Container(
//   width: context.getWidth(100),
//   height: context.getHeight(50),
//   padding: EdgeInsets.symmetric(
//     horizontal: context.getAdaptiveSize(16),
//     vertical: context.getAdaptiveSize(8),
//   ),
// );

// // Using responsive values
// Container(
//   padding: EdgeInsets.all(
//     context.responsiveValue(
//       small: 8,
//       medium: 16,
//       large: 24,
//     ),
//   ),
// );

// // Check platform and orientation
// if (context.isDarkMode) {
//   // Use dark theme colors
// }

// if (context.isLandscape) {
//   // Use landscape layout
// }

// // Handle safe areas and keyboard
// Padding(
//   padding: EdgeInsets.only(
//     bottom: context.bottomInset + context.safePadding.bottom,
//   ),
//   child: yourWidget,
// );