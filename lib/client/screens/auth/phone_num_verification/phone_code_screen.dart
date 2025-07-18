// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
// import 'package:pests247/client/screens/auth/phone_verification_screen.dart';
// import 'package:phone_text_field/phone_text_field.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_snackbar.dart';
//
// class PhoneCodeScreen extends StatefulWidget {
//   const PhoneCodeScreen({super.key});
//
//   @override
//   State<PhoneCodeScreen> createState() => _PhoneCodeScreenState();
// }
//
// class _PhoneCodeScreenState extends State<PhoneCodeScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String phoneNo = '';
//   bool isLoading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     return Scaffold(
//       body: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Lottie.asset(
//                 'assets/lottie/phone.json',
//                 height: mediaQuery.size.height * 0.75,
//                 fit: BoxFit.contain,
//               ),
//               PhoneTextField(
//                 decoration: const InputDecoration(
//                   contentPadding: EdgeInsets.zero,
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                     borderSide: BorderSide(),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                     borderSide: BorderSide(),
//                   ),
//                   prefixIcon: Icon(CupertinoIcons.phone),
//                   labelText: "Phone number",
//                 ),
//                 searchFieldInputDecoration: const InputDecoration(
//                   filled: true,
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                     borderSide: BorderSide(),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                     borderSide: BorderSide(),
//                   ),
//                   suffixIcon: Icon(Icons.search),
//                   prefixIcon: Icon(FontAwesomeIcons.earthAmericas),
//                   hintText: "Search country",
//                 ),
//                 initialCountryCode: "PK",
//                 onChanged: (phone) {
//                   setState(() {
//                     phoneNo = phone.completeNumber;
//                   });
//                 },
//               ),
//               SizedBox(height: mediaQuery.size.height * 0.03),
//               CustomButton(
//                 onPressed: () => sendOtp(),
//                 text: 'Continue',
//                 isLoading: isLoading,
//                 tag: 'phone',
//                 height: 50,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void sendOtp() {
//     setState(() {
//       isLoading = true;
//     });
//
//     _auth.verifyPhoneNumber(
//       phoneNumber: phoneNo,
//       verificationCompleted: (PhoneAuthCredential credential) {
//         setState(() {
//           isLoading = false;
//         });
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         setState(() {
//           isLoading = false;
//           print('$e-----------------------------------------------');
//         });
//
//         if (e.code == 'invalid-phone-number') {
//           CustomSnackbar.showSnackBar(
//             'Invalid Phone Number',
//             'The provided phone number is not valid.',
//             const Icon(Icons.phone_disabled),
//             Theme.of(context).colorScheme.onPrimary,
//             context,
//           );
//         } else if (e.code == 'network-request-failed') {
//           CustomSnackbar.showSnackBar(
//             'Network Error',
//             'Please check your internet connection and try again.',
//             const Icon(Icons.wifi_off),
//             Theme.of(context).colorScheme.onPrimary,
//             context,
//           );
//         }else if (e.code == 'too-many-requests') {
//           CustomSnackbar.showSnackBar(
//             'Too Many Requests',
//             'You have made too many verification attempts. Please try again later.',
//             const Icon(Icons.block),
//             Theme.of(context).colorScheme.onPrimary,
//             context,
//           );
//         }else {
//           CustomSnackbar.showSnackBar(
//             'Error',
//             'An error occurred while verifying your phone number.',
//             const Icon(Icons.error),
//             Theme.of(context).colorScheme.onPrimary,
//             context,
//           );
//         }
//       },
//       codeSent: (String verificationId, int? resendToken) async {
//         setState(() {
//           isLoading = false;
//         });
//
//         await Future.delayed(const Duration(seconds: 2));
//         Get.to(PhoneVerificationScreen(
//           verificationId: verificationId,
//           phoneNo: phoneNo,
//         ));
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         setState(() {
//           isLoading = false;
//         });
//
//         CustomSnackbar.showSnackBar(
//           'Timeout',
//           'Verification code retrieval timed out. Please try again.',
//           const Icon(Icons.timer_off),
//           Theme.of(context).colorScheme.onPrimary,
//           context,
//         );
//       },
//     );
//   }
// }
