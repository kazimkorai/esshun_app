import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:taxi_driver/clients/service/AuthService1.dart';
import 'package:taxi_driver/clients/utils/Extensions/StringExtensions.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';

import '../../main.dart';

import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/AppButtonWidget.dart';
import '../../utils/Extensions/app_common.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../utils/Constants.dart';
import 'RiderDashBoardScreen.dart';
import 'TermsConditionScreen.dart';

class RegisterScreen extends StatefulWidget {
  final bool socialLogin;
  final String? userName;
  final bool isOtp;
  final String? countryCode;
  final String? privacyPolicyUrl;
  final String? termsConditionUrl;
  final String userId;
  final String token;
   String contactNo;

  RegisterScreen(
      {this.socialLogin = false,
      this.userName,
      this.isOtp = false,
      this.countryCode,
      this.privacyPolicyUrl,
      this.termsConditionUrl,
      required this.userId,
        required this.contactNo,
      required this.token});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthServices authService = AuthServices();

  TextEditingController firstController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  bool mIsCheck = false;
  bool isAcceptedTc = false;

  String countryCode = defaultCountryCode;
  String selectGender = MALE;

  List<String> gender = [MALE, FEMALE, OTHER];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    phoneController.text=widget.contactNo.toString();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> register(String userId, String userName, String token) async {
    if (formKey.currentState!.validate()) {

      formKey.currentState!.save();
      if(userId.toString()!='null'){
        if (isAcceptedTc) {
          appStoreClient.setLoading(true);
          // authService.signUpWithEmailPassword(
          //   token: widget.token.toString(),
          //   context,
          //   name: firstController.text.trim(),
          //   mobileNumber: widget.socialLogin
          //       ? '$countryCode ${widget.userName}'
          //       : '$countryCode ${phoneController.text.trim()}',
          //   email: emailController.text.trim(),
          //   fName: firstController.text.trim(),
          //   lName: lastNameController.text.trim(),
          //   userName: widget.socialLogin
          //       ? widget.userName
          //       : userNameController.text.trim(),
          //   password:
          //       widget.socialLogin ? widget.userName : passController.text.trim(),
          //   userType: RIDER,
          //   socialLoginName: widget.socialLogin,
          //   isOtp: widget.isOtp,
          //   gender: selectGender,

          print(sharedPref.get(TOKEN).toString() + "*token");


          if(widget.contactNo.toString()!='null'){
            await updateProfile(
                isRegister: true,
                address: "",
                firstName: firstController.text.trim(),
                lastName: lastNameController.text.trim(),
                userEmail: emailController.text.trim(),
                contactNumber: widget.contactNo.toString(),
                gender: selectGender,
                id: userId,
                userName: userName,

                token: token)
                .then((res) async {
              print(res);
              appStoreClient.setLoading(false);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RiderDashBoardScreen()),
              );
              //
            }).catchError((e) {
              appStoreClient.setLoading(false);
              toast(e.toString(), print: true);
            });
          } else {
            toast(language.pleaseAcceptTermsOfServicePrivacyPolicy);
          }
          }

      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Color.fromRGBO(0, 52, 111, 1), // rgba(0, 52, 111, 1)
                  Color.fromRGBO(0, 112, 90, 1), // rgba(0, 112, 90, 1)
                ]),
          ),
        ),
        backgroundColor: borderColor,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(language.createAccount, style: boldTextStyle(size: 22)),
                  SizedBox(height: 8),
                  Text(language.createYourAccountToContinue,
                      style: primaryTextStyle()),
                  SizedBox(height: 32),
                  AppTextField(
                    controller: firstController,
                    focus: firstNameFocus,
                    nextFocus: lastNameFocus,
                    autoFocus: false,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration:
                        inputDecoration(context, label: language.firstName),
                  ),
                  SizedBox(height: 20),
                  AppTextField(
                    controller: lastNameController,
                    focus: lastNameFocus,
                    nextFocus: userNameFocus,
                    autoFocus: false,
                    textFieldType: TextFieldType.OTHER,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration:
                        inputDecoration(context, label: language.lastName),
                  ),
                  if (widget.socialLogin != true) SizedBox(height: 20),
                  if (widget.socialLogin != true)
                    AppTextField(
                      controller: userNameController,
                      focus: userNameFocus,
                      nextFocus: emailFocus,
                      autoFocus: false,
                      textFieldType: TextFieldType.USERNAME,
                      errorThisFieldRequired: errorThisFieldRequired,
                      decoration:
                          inputDecoration(context, label: language.userName),
                    ),
                  SizedBox(height: 20),
                  Form(
                    child: AppTextField(
                      controller: emailController,
                      focus: emailFocus,
                      nextFocus: phoneFocus,
                      autoFocus: false,
                      textFieldType: TextFieldType.EMAIL,
                      keyboardType: TextInputType.emailAddress,
                      errorThisFieldRequired: errorThisFieldRequired,
                      decoration:
                          inputDecoration(context, label: language.email),
                    ),
                  ),
                  if (widget.socialLogin != true) SizedBox(height: 20),
                  if (widget.socialLogin != true)
                    AppTextField(
                      controller: phoneController,
                      textFieldType: TextFieldType.PHONE,
                      focus: phoneFocus,
                      enabled: false,
                      nextFocus: passFocus,
                      maxLength: 8,
                      decoration: inputDecoration(
                        context,
                        label: language.phoneNumber,
                        prefixIcon: IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CountryCodePicker(
                                padding: EdgeInsets.zero,
                                initialSelection: countryCode,
                                showCountryOnly: false,
                                dialogSize: Size(
                                    MediaQuery.of(context).size.width - 60,
                                    MediaQuery.of(context).size.height * 0.6),
                                showFlag: true,
                                showFlagDialog: true,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                                textStyle: primaryTextStyle(),
                                dialogBackgroundColor:
                                    Theme.of(context).cardColor,
                                barrierColor: Colors.black12,
                                dialogTextStyle: primaryTextStyle(),
                                searchDecoration: InputDecoration(
                                  iconColor: Theme.of(context).dividerColor,
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).dividerColor)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColorD)),
                                ),
                                searchStyle: primaryTextStyle(),
                                onInit: (c) {
                                  countryCode = c!.dialCode!;
                                },
                                onChanged: (c) {
                                  countryCode = c.dialCode!;
                                },
                              ),
                              VerticalDivider(
                                  color: Colors.grey.withOpacity(0.5)),
                            ],
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.trim().isEmpty)
                          return errorThisFieldRequired;
                        if (value.trim().length != 8)
                          return language.contactLength;
                        return null;
                      },
                    ),
                  if (widget.socialLogin != true) SizedBox(height: 1),
                  if (widget.socialLogin != true)
                    // AppTextField(
                    //   controller: passController,
                    //   focus: passFocus,
                    //   autoFocus: false,
                    //   textFieldType: TextFieldType.PASSWORD,
                    //   errorThisFieldRequired: errorThisFieldRequired,
                    //   decoration:
                    //       inputDecoration(context, label: language.password),
                    // ),
                    SizedBox(height: 16),
                  Text(language.selectGender, style: boldTextStyle()),
                  SizedBox(height: 10),
                  DropdownButtonFormField(
                    decoration: inputDecoration(context, label: ""),
                    value: selectGender,
                    onChanged: (String? value) {
                      setState(() {
                        selectGender = value!;
                      });
                    },
                    items: gender
                        .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              "${value}",
                              style: primaryTextStyle(),
                            )))
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        height: 18,
                        width: 18,
                        child: Checkbox(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          activeColor: primaryColorD,
                          value: isAcceptedTc,
                          shape:
                              RoundedRectangleBorder(borderRadius: radius(2)),
                          onChanged: (v) async {
                            isAcceptedTc = v!;
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: '${language.iAgreeToThe} ',
                                style: secondaryTextStyle()),
                            TextSpan(
                              text: language.termsConditions,
                              style:
                                  boldTextStyle(color: primaryColorD, size: 14),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  if (widget.termsConditionUrl != null &&
                                      widget.termsConditionUrl!.isNotEmpty) {
                                    launchScreen(
                                        context,
                                        TermsConditionScreen(
                                            title: language.termsConditions,
                                            subtitle: widget.termsConditionUrl),
                                        pageRouteAnimation:
                                            PageRouteAnimation.Slide);
                                  } else {
                                    toast(language.txtURLEmpty);
                                  }
                                },
                            ),
                            TextSpan(text: ' & ', style: secondaryTextStyle()),
                            TextSpan(
                              text: language.privacyPolicy,
                              style:
                                  boldTextStyle(color: primaryColorD, size: 14),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  if (widget.privacyPolicyUrl != null &&
                                      widget.privacyPolicyUrl!.isNotEmpty) {
                                    launchScreen(
                                        context,
                                        TermsConditionScreen(
                                            title: language.privacyPolicy,
                                            subtitle: widget.privacyPolicyUrl),
                                        pageRouteAnimation:
                                            PageRouteAnimation.Slide);
                                  } else {
                                    toast(language.txtURLEmpty);
                                  }
                                },
                            ),
                          ]),
                          textAlign: TextAlign.left,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  AppButtonWidget(
                    width: MediaQuery.of(context).size.width,
                    color: borderColor,
                    textStyle: boldTextStyle(color: Colors.white),
                    text: language.createProfile,
                    onTap: () async {

                      register(widget.userId,
                          userNameController.text.toString(), widget.token);
                    },
                  ),
                  SizedBox(height: 20),
                  // Align(
                  //   alignment: Alignment.center,
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Text(language.alreadyHaveAnAccount,
                  //           style: primaryTextStyle()),
                  //       SizedBox(width: 8),
                  //       inkWellWidget(
                  //         onTap: () {
                  //           Navigator.pop(context);
                  //         },
                  //         child: Text(language.logIn,
                  //             style: boldTextStyle(color: primaryColorD)),
                  //       ),
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
          ),
          Observer(builder: (context) {
            return Visibility(
              visible: appStoreClient.isLoading,
              child: loaderWidget(),
            );
          })
        ],
      ),
    );
  }
}

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String _verificationId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1 123 456 7890',
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPhoneNumber,
              child: Text('Verify Phone Number'),
            ),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signInWithPhoneNumber,
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Phone number automatically verified and signed in!'),
        ));
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to verify phone number: ${e.message}'),
        ));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Verification code sent to the phone number'),
        ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  void _signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codeController.text,
      );

      final User? user = (await _auth.signInWithCredential(credential)).user;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Successfully signed in UID: ${user?.uid}'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to sign in: ${e.toString()}'),
      ));
    }
  }
}
