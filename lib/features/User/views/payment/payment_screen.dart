// import 'package:flutter/material.dart';
// import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
// import 'package:good_one_app/Features/User/services/stripe_service.dart';

// class PaymentScreen extends StatefulWidget {
//   const PaymentScreen({super.key});

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   String amount = '100';
//   String currency = 'CAD';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Payment',
//           style: AppTextStyles.appBarTitle(context),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   bool paymentSuccess =
//                       await StripeService.presentPaymentSheet(amount, currency);

//                   if (paymentSuccess) {
//                     // Show success message
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Payment completed successfully!'),
//                         backgroundColor: Colors.green,
//                         duration: Duration(seconds: 3),
//                       ),
//                     );
//                   } else {
//                     // Show failure message
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Payment failed. Please try again.'),
//                         backgroundColor: Colors.red,
//                         duration: Duration(seconds: 3),
//                       ),
//                     );
//                   }
//                 } catch (e) {
//                   print('Payment Error: $e');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Error: ${e.toString()}'),
//                       backgroundColor: Colors.red,
//                       duration: Duration(seconds: 3),
//                     ),
//                   );
//                 }
//               },
//               child: Text('Pay'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
