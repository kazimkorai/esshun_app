// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:taxi_driver/screens/DriverDashboardScreen.dart';
// import 'package:taxi_driver/utils/Constants.dart';
// import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
//
// import '../../main.dart';
// import '../Services/AuthService.dart';
// import '../components/OTPDialog.dart';
// import '../model/UserDetailModel.dart';
// import '../network/RestApis.dart';
// import '../utils/Colors.dart';
// import '../utils/Common.dart';
// import '../utils/Extensions/AppButtonWidget.dart';
// import '../utils/Extensions/app_common.dart';
// import '../utils/Extensions/app_textfield.dart';
// import 'DriverRegisterScreen.dart';
// import 'ForgotPasswordScreen.dart';
// import 'PhoneOTPVerification.dart';
// import 'TermsConditionScreen.dart';
// import 'VerifyDeliveryPersonScreen.dart';
//
// class LoginDriverScreen extends StatefulWidget {
//   @override
//   LoginDriverScreenState createState() => LoginDriverScreenState();
// }
//
// class LoginDriverScreenState extends State<LoginDriverScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late UserData _userModel;
//
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   AuthServices authService = AuthServices();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passController = TextEditingController();
//
//   FocusNode emailFocus = FocusNode();
//   FocusNode passFocus = FocusNode();
//
//   bool mIsCheck = false;
//   bool isAcceptedTc = false;
//   String? privacyPolicy;
//   String? termsCondition;
//
//   @override
//   void initState() {
//     super.initState();
//     init();
//   }
//
//   void init() async {
//     appSetting();
//     if (sharedPref.getString(PLAYER_ID).validate().isEmpty) {
//       await saveOneSignalPlayerId().then((value) {
//         //
//       });
//     }
//     mIsCheck = sharedPref.getBool(REMEMBER_ME) ?? false;
//     if (mIsCheck) {
//       emailController.text = sharedPref.getString(USER_EMAIL).validate();
//       passController.text = sharedPref.getString(USER_PASSWORD).validate();
//     }
//   }
//
//   Future<void> logIn() async {
//     hideKeyboard(context);
//     if (formKey.currentState!.validate()) {
//       formKey.currentState!.save();
//       if (isAcceptedTc) {
//         appStoreClient.setLoading(true);
//
//         Map req = {
//           'email': emailController.text.trim(),
//           'password': passController.text.trim(),
//           "player_id": sharedPref.getString(PLAYER_ID).validate(),
//           'user_type': 'driver',
//         };
//         if (mIsCheck) {
//           await sharedPref.setBool(REMEMBER_ME, mIsCheck);
//           await sharedPref.setString(USER_EMAIL, emailController.text);
//           await sharedPref.setString(USER_PASSWORD, passController.text);
//         }
//         await logInApi(req).then((value) async {
//           _userModel = value.data!;
//
//           _auth
//               .signInWithEmailAndPassword(
//                   email: emailController.text, password: passController.text)
//               .then((value) {
//             if (sharedPref.getInt(IS_Verified_Driver) == 1) {
//               launchScreen(context, DriverDashboardScreen(),
//                   isNewTask: true,
//                   pageRouteAnimation: PageRouteAnimation.Slide);
//             } else {
//               launchScreen(context, VerifyDeliveryPersonScreen(isShow: true),
//                   isNewTask: true,
//                   pageRouteAnimation: PageRouteAnimation.Slide);
//             }
//             appStoreClient.isLoading = false;
//           }).catchError((e) {
//             if (e.toString().contains('user-not-found')) {
//               authService.signUpWithEmailPassword(
//                 context,
//                 name: _userModel.firstName,
//                 mobileNumber: _userModel.contactNumber,
//                 email: emailController.text,
//                 fName: _userModel.firstName,
//                 lName: _userModel.lastName,
//                 userName: _userModel.username,
//                 password: passController.text,
//                 userType: 'driver',
//                 isExist: false,
//                 gender: _userModel.gender,
//                 serviceId: _userModel.serviceId,
//                 userDetail: UserDetail(
//                   carModel: '',
//                   carColor: '',
//                   carPlateNumber: '',
//                   carProductionYear: '',
//                 ),
//               );
//             } else {
//               if (sharedPref.getInt(IS_Verified_Driver) == 1) {
//                 launchScreen(context, DriverDashboardScreen(),
//                     isNewTask: true,
//                     pageRouteAnimation: PageRouteAnimation.Slide);
//               } else {
//                 launchScreen(context, VerifyDeliveryPersonScreen(isShow: true),
//                     isNewTask: true,
//                     pageRouteAnimation: PageRouteAnimation.Slide);
//               }
//             }
//             //toast(e.toString());
//             log('${e.toString()}');
//             log(e.toString());
//           });
//         }).catchError((error) {
//           appStoreClient.setLoading(false);
//
//           toast(error.toString());
//           log('${error.toString()}');
//         });
//       } else {
//         toast(language.pleaseAcceptTermsOfServicePrivacyPolicy);
//       }
//     }
//   }
//
//   Future<void> appSetting() async {
//     await getAppSettingApi().then((value) {
//       if (value.privacyPolicyModel!.value != null)
//         privacyPolicy = value.privacyPolicyModel!.value;
//       if (value.termsCondition!.value != null)
//         termsCondition = value.termsCondition!.value;
//     }).catchError((error) {
//       log(error.toString());
//     });
//   }
//
//   @override
//   void setState(fn) {
//     if (mounted) super.setState(fn);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(250.0),
//         child: AppBar(
//           flexibleSpace: Container(
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color.fromRGBO(0, 52, 111, 1), // rgba(0, 52, 111, 1)
//                     Color.fromRGBO(0, 112, 90, 1), // rgba(0, 112, 90, 1)
//                   ],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Text("  " + language.logIn,
//                           style: boldTextStyle(color: Colors.white, size: 18)),
//                       Text('')
//                     ],
//                   ),
//                   SizedBox(
//                     height: 5,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "  Eshhun",
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 18),
//                             ),
//                             Text(
//                               "  Login",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(right: 5, top: 4),
//                           child: Image.asset(
//                             'images/ic_logo_white.png',
//                             width: 75,
//                             height: 75,
//                             fit: BoxFit.cover,
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               )),
//           iconTheme: IconThemeData(color: Colors.white),
//           automaticallyImplyLeading: false,
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: EdgeInsets.all(16),
//             child: Form(
//               key: formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 16),
//                   Text(language.welcomeBack, style: boldTextStyle(size: 22)),
//                   SizedBox(height: 8),
//                   Text(language.signInYourAccount, style: primaryTextStyle()),
//                   SizedBox(height: 32),
//                   AppTextField(
//                     controller: emailController,
//                     nextFocus: passFocus,
//                     autoFocus: false,
//                     textFieldType: TextFieldType.EMAIL,
//                     keyboardType: TextInputType.emailAddress,
//                     errorThisFieldRequired: language.thisFieldRequired,
//                     decoration: inputDecoration(context, label: language.email),
//                   ),
//                   SizedBox(height: 20),
//                   AppTextField(
//                     controller: passController,
//                     focus: passFocus,
//                     autoFocus: false,
//                     textFieldType: TextFieldType.PASSWORD,
//                     errorThisFieldRequired: language.thisFieldRequired,
//                     decoration:
//                         inputDecoration(context, label: language.password),
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     children: [
//                       SizedBox(
//                         height: 18.0,
//                         width: 18.0,
//                         child: Checkbox(
//                           materialTapTargetSize:
//                               MaterialTapTargetSize.shrinkWrap,
//                           activeColor: primaryColorD,
//                           value: mIsCheck,
//                           shape:
//                               RoundedRectangleBorder(borderRadius: radius(2)),
//                           onChanged: (v) async {
//                             mIsCheck = v!;
//                             if (!mIsCheck) {
//                               sharedPref.remove(REMEMBER_ME);
//                             }
//                             setState(() {});
//                           },
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       inkWellWidget(
//                           onTap: () async {
//                             mIsCheck = !mIsCheck;
//                             setState(() {});
//                           },
//                           child: Text(language.rememberMe,
//                               style: primaryTextStyle(size: 14))),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     children: [
//                       SizedBox(
//                         height: 18,
//                         width: 18,
//                         child: Checkbox(
//                           materialTapTargetSize:
//                               MaterialTapTargetSize.shrinkWrap,
//                           activeColor: primaryColorD,
//                           value: isAcceptedTc,
//                           shape:
//                               RoundedRectangleBorder(borderRadius: radius(2)),
//                           onChanged: (v) async {
//                             isAcceptedTc = v!;
//                             setState(() {});
//                           },
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: RichText(
//                           text: TextSpan(children: [
//                             TextSpan(
//                                 text: '${language.iAgreeToThe} ',
//                                 style: secondaryTextStyle()),
//                             TextSpan(
//                               text: language.termsConditions,
//                               style:
//                                   boldTextStyle(color: primaryColorD, size: 14),
//                               recognizer: TapGestureRecognizer()
//                                 ..onTap = () {
//                                   if (termsCondition != null &&
//                                       termsCondition!.isNotEmpty) {
//                                     launchScreen(
//                                         context,
//                                         TermsConditionScreen(
//                                             title: language.termsConditions,
//                                             subtitle: termsCondition),
//                                         pageRouteAnimation:
//                                             PageRouteAnimation.Slide);
//                                   } else {
//                                     toast(language.txtURLEmpty);
//                                   }
//                                 },
//                             ),
//                             TextSpan(text: ' & ', style: secondaryTextStyle()),
//                             TextSpan(
//                               text: language.privacyPolicy,
//                               style:
//                                   boldTextStyle(color: primaryColorD, size: 14),
//                               recognizer: TapGestureRecognizer()
//                                 ..onTap = () {
//                                   if (privacyPolicy != null &&
//                                       privacyPolicy!.isNotEmpty) {
//                                     launchScreen(
//                                         context,
//                                         TermsConditionScreen(
//                                             title: language.privacyPolicy,
//                                             subtitle: privacyPolicy),
//                                         pageRouteAnimation:
//                                             PageRouteAnimation.Slide);
//                                   } else {
//                                     toast(language.txtURLEmpty);
//                                   }
//                                 },
//                             ),
//                           ]),
//                           textAlign: TextAlign.left,
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   AppButtonWidget(
//                     width: MediaQuery.of(context).size.width,
//                     color: borderColor,
//                     textStyle: boldTextStyle(color: Colors.white),
//                     text: language.logIn,
//                     onTap: () async {
//                       logIn();
//                     },
//                   ),
//                   SizedBox(height: 16),
//                   Align(
//                     alignment: Alignment.topRight,
//                     child: inkWellWidget(
//                       onTap: () {
//                         hideKeyboard(context);
//                         launchScreen(context, ForgotPasswordScreen(),
//                             pageRouteAnimation:
//                                 PageRouteAnimation.SlideBottomTop);
//                       },
//                       child:
//                           Text(language.forgotPassword, style: boldTextStyle()),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Row(
//                       children: [
//                         Expanded(
//                             child:
//                                 Divider(color: primaryColorD.withOpacity(0.5))),
//                         Padding(
//                           padding: EdgeInsets.only(left: 16, right: 16),
//                           child: Text(language.orLogInWith,
//                               style: primaryTextStyle()),
//                         ),
//                         Expanded(
//                             child:
//                                 Divider(color: primaryColorD.withOpacity(0.5))),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Align(
//                     alignment: Alignment.center,
//                     child: inkWellWidget(
//                       onTap: () async {
//                         showDialog(
//                           context: context,
//                           builder: (_) {
//                             return AlertDialog(
//                               contentPadding: EdgeInsets.all(16),
//                               content: OTPDialog(),
//                             );
//                           },
//                         );
//                       },
//                       child: Image.asset('images/ic_mobile.png',
//                           fit: BoxFit.cover, height: 35, width: 35),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Align(
//                     alignment: Alignment.center,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(language.donHaveAnAccount,
//                             style: primaryTextStyle()),
//                         SizedBox(width: 8),
//                         inkWellWidget(
//                           onTap: () {
//                             hideKeyboard(context);
//                             launchScreen(context, OtpRegister(),
//                                 pageRouteAnimation:
//                                     PageRouteAnimation.SlideBottomTop);
//                           },
//                           child: Text(language.createProfile,
//                               style: boldTextStyle(color: primaryColorD)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Observer(
//             builder: (context) {
//               return Visibility(
//                 visible: appStoreClient.isLoading,
//                 child: loaderWidgetLogIn(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
