// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:taxi_driver/clients/model/UserDetailModel.dart';
// import '../../Services/AuthService.dart';
// import '../model/LoginResponse.dart';
// import '../utils/Extensions/StringExtensions.dart';
//
// import '../../components/OTPDialog.dart';
// import '../../main.dart';
// import '../../network/RestApis.dart';
// import '../../screens/ForgotPasswordScreen.dart';
// import '../../utils/Colors.dart';
// import '../../utils/Common.dart';
// import '../../utils/Constants.dart';
// import '../../utils/Extensions/AppButtonWidget.dart';
// import '../../utils/Extensions/app_common.dart';
// import '../../utils/Extensions/app_textfield.dart';
// import '../service/AuthService.dart';
// import '../utils/images.dart';
// import 'PhoneOTPVerificationClient.dart';
// import 'RegisterScreen.dart';
// import 'RiderDashBoardScreen.dart';
// import 'TermsConditionScreen.dart';
//
// class LoginScreenClient extends StatefulWidget {
//   @override
//   LoginScreenClientState createState() => LoginScreenClientState();
// }
//
// late var _userModel;
//
// class LoginScreenClientState extends State<LoginScreenClient> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   AuthServices authService = AuthServices();
//   GoogleAuthServices googleAuthService = GoogleAuthServices();
//
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
//           'user_type': RIDER,
//         };
//
//         if (mIsCheck) {
//           await sharedPref.setBool(REMEMBER_ME, mIsCheck);
//           await sharedPref.setString(USER_EMAIL, emailController.text);
//           await sharedPref.setString(USER_PASSWORD, passController.text);
//         }
//         await logInApi(req).then((value) {
//           _userModel = value.data! ;
//
//           _auth.signInWithEmailAndPassword(email: emailController.text, password: passController.text).then((value) {
//             launchScreen(context, RiderDashBoardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
//           }).catchError((e) {
//             if (e.toString().contains('user-not-found')) {
//               authService.signUpWithEmailPassword(context,
//                   name: _userModel.firstName,
//                   mobileNumber: _userModel.contactNumber,
//                   email: _userModel.email,
//                   fName: _userModel.firstName,
//                   lName: _userModel.lastName,
//                   userName: _userModel.username,
//                   password: passController.text,
//                   userType: RIDER,
//                   isExist: false);
//             } else {
//               launchScreen(context, RiderDashBoardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
//             }
//             //toast(e.toString());
//             log(e.toString());
//           });
//           appStoreClient.setLoading(false);
//         }).catchError((error) {
//           appStoreClient.isLoading = false;
//           toast(error.toString());
//         });
//       } else {
//         toast(language.pleaseAcceptTermsOfServicePrivacyPolicy);
//       }
//     }
//   }
//
//   Future<void> appSetting() async {
//     await getAppSettingApi().then((value) {
//       if (value.privacyPolicyModel!.value != null) privacyPolicy = value.privacyPolicyModel!.value;
//       if (value.termsCondition!.value != null) termsCondition = value.termsCondition!.value;
//     }).catchError((error) {
//       log(error.toString());
//     });
//   }
//
//   void googleSignIn() async {
//     hideKeyboard(context);
//     appStoreClient.setLoading(true);
//
//     await googleAuthService.signInWithGoogle(context).then((value) async {
//       appStoreClient.setLoading(false);
//     }).catchError((e) {
//       appStoreClient.setLoading(false);
//       toast(e.toString());
//       print(e.toString());
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
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
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
//
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
//
//                             Text(
//                               "  Welcome",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               "  Eshhun App",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
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
//
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
//                     decoration: inputDecoration(context, label: language.password),
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     children: [
//                       SizedBox(
//                         height: 18.0,
//                         width: 18.0,
//                         child: Checkbox(
//                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           activeColor: primaryColorD,
//                           value: mIsCheck,
//                           shape: RoundedRectangleBorder(borderRadius: radius(2)),
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
//                           child: Text(language.rememberMe, style: primaryTextStyle(size: 14))),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     children: [
//                       SizedBox(
//                         height: 18,
//                         width: 18,
//                         child: Checkbox(
//                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           activeColor: primaryColorD,
//                           value: isAcceptedTc,
//                           shape: RoundedRectangleBorder(borderRadius: radius(2)),
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
//                             TextSpan(text: '${language.iAgreeToThe} ', style: secondaryTextStyle()),
//                             TextSpan(
//                               text: language.termsConditions,
//                               style: boldTextStyle(color: primaryColorD, size: 14),
//                               recognizer: TapGestureRecognizer()
//                                 ..onTap = () {
//                                   if (termsCondition != null && termsCondition!.isNotEmpty) {
//                                     launchScreen(context, TermsConditionScreen(title: language.termsConditions, subtitle: termsCondition), pageRouteAnimation: PageRouteAnimation.Slide);
//                                   } else {
//                                     toast(language.txtURLEmpty);
//                                   }
//                                 },
//                             ),
//                             TextSpan(text: ' & ', style: secondaryTextStyle()),
//                             TextSpan(
//                               text: language.privacyPolicy,
//                               style: boldTextStyle(color: primaryColorD, size: 14),
//                               recognizer: TapGestureRecognizer()
//                                 ..onTap = () {
//                                   if (privacyPolicy != null && privacyPolicy!.isNotEmpty) {
//                                     launchScreen(context, TermsConditionScreen(title: language.privacyPolicy, subtitle: privacyPolicy), pageRouteAnimation: PageRouteAnimation.Slide);
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
//                   SizedBox(height: 10),
//                   Align(
//                     alignment: Alignment.topRight,
//                     child: inkWellWidget(
//                       onTap: () {
//                         launchScreen(context, ForgotPasswordScreen(), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
//                       },
//                       child: Text(language.forgotPassword, style: boldTextStyle()),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Row(
//                       children: [
//                         Expanded(child: Divider(color: primaryColorD.withOpacity(0.5))),
//                         Padding(
//                           padding: EdgeInsets.only(left: 16, right: 16),
//                           child: Text(language.orLogInWith, style: primaryTextStyle()),
//                         ),
//                         Expanded(child: Divider(color: primaryColorD.withOpacity(0.5))),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       inkWellWidget(
//                         onTap: () async {
//                           googleSignIn();
//                         },
//                         child: Image.asset(ic_google, fit: BoxFit.cover, height: 35, width: 35),
//                       ),
//                       SizedBox(width: 16),
//                       inkWellWidget(
//                         onTap: () async {
//                           showDialog(
//                             context: context,
//                             builder: (_) {
//                               return AlertDialog(
//                                 contentPadding: EdgeInsets.all(16),
//                                 content: OTPDialog(),
//                               );
//                             },
//                           );
//                         },
//                         child: Image.asset(ic_mobile, fit: BoxFit.cover, height: 35, width: 35),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   Align(
//                     alignment: Alignment.center,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(language.donHaveAnAccount, style: primaryTextStyle()),
//                         SizedBox(width: 8),
//                         inkWellWidget(
//                           onTap: () {
//                             hideKeyboard(context);
//
//                             launchScreen(context,OtpRegisterClient());
//                           //  launchScreen(context, RegisterScreen(privacyPolicyUrl: privacyPolicy, termsConditionUrl: termsCondition), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
//                           },
//                           child: Text(language.signUp, style: boldTextStyle(color: primaryColorD)),
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
//                 child: loaderWidget(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
