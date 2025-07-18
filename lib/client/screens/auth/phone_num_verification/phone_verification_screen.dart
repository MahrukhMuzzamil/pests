// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:pests247/client/screens/auth/sign_up/sign_up_page.dart';
// import 'package:pests247/client/screens/client_bottom_nav_bar.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_snackbar.dart';
//
// class PhoneVerificationScreen extends StatefulWidget {
//   final String verificationId;
//   final String phoneNo;
//
//   const PhoneVerificationScreen({super.key, required this.verificationId, required this.phoneNo});
//
//   @override
//   State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
// }
//
// class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
//   TextEditingController otpController = TextEditingController();
//   StreamController<ErrorAnimationType>? errorController;
//   String otpCode = "";
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     errorController = StreamController<ErrorAnimationType>();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     otpController.dispose();
//     errorController?.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Lottie.asset('assets/lottie/otp.json', height: 500, reverse: true),
//               const SizedBox(height: 20),
//               const Text(
//                 "Enter the 6-digit OTP sent to your phone number",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               PinCodeTextField(
//                 length: 6,
//                 obscureText: false,
//                 animationType: AnimationType.slide,
//                 keyboardType: TextInputType.number,
//                 pinTheme: PinTheme(
//                   shape: PinCodeFieldShape.circle,
//                   borderRadius: BorderRadius.circular(25),
//                   fieldHeight: 50,
//                   fieldWidth: 40,
//                   activeFillColor: Colors.white,
//                   selectedFillColor: Colors.white,
//                   inactiveFillColor: Colors.white,
//                   errorBorderColor: Colors.red,
//                   activeColor: Theme.of(context).colorScheme.secondary,
//                   inactiveColor: Theme.of(context).colorScheme.primary,
//                 ),
//                 animationDuration: const Duration(milliseconds: 350),
//                 enableActiveFill: true,
//                 errorAnimationController: errorController,
//                 controller: otpController,
//                 onCompleted: (v) {
//                   otpCode = v;
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     otpCode = value;
//                   });
//                 },
//                 beforeTextPaste: (text) {
//                   print("Allowing to paste $text");
//                   return true;
//                 },
//                 appContext: context,
//               ),
//               const SizedBox(height: 20),
//               CustomButton(
//                 onPressed: verifyOtp,
//                 text: 'Verify',
//                 isLoading: isLoading,
//                 tag: 'phone',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void verifyOtp() async {
//     if (otpCode.length != 6) {
//       errorController?.add(ErrorAnimationType.shake);
//       print("Invalid OTP");
//       return;
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       FirebaseAuth _auth = FirebaseAuth.instance;
//       FirebaseFirestore firestore = FirebaseFirestore.instance;
//       final credential = PhoneAuthProvider.credential(
//         verificationId: widget.verificationId,
//         smsCode: otpCode,
//       );
//
//       UserCredential userCredential = await _auth.signInWithCredential(credential);
//
//       if (userCredential.user != null) {
//         var id = _auth.currentUser!.uid;
//
//         await Future.delayed(const Duration(seconds: 2));
//         final userDoc = await firestore.collection('users').doc(id).get();
//
//         if(userDoc.exists){
//
//           // FirestoreServices.storeToken();
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setBool('isLoggedIn', true);
//
//           // FirestoreServices.storeToken();
//
//           Navigator.pushReplacement(
//               context, MaterialPageRoute
//             (builder: (context) =>
//           const ClientBottomNavBar()));
//         }else{
//           Navigator.pushReplacement(
//               context, MaterialPageRoute
//             (builder: (context) =>
//               const SignupPage()));
//         }
//
//       }
//     } catch (e) {
//       errorController?.add(ErrorAnimationType.shake);
//       CustomSnackbar.showSnackBar(
//         'OTP error',
//         'OTP is not correct.',
//         const Icon(Icons.error),
//         Theme.of(context).colorScheme.onPrimary,
//         context,
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
// }
