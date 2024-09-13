import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taxi_driver/Services/AuthService.dart';

import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';

import '../model/ServiceModel.dart';
import '../model/UserDetailModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';
import 'DriverDashboardScreen.dart';
import 'TermsConditionScreen.dart';

class DriverRegisterScreen extends StatefulWidget {
  bool socialLogin;
  String? userName;
  bool isOtp;
  String? countryCode;
  String? privacyPolicyUrl;
  String? termsConditionUrl;
  String? userId;
  String? token;
  String? contactNo;

  DriverRegisterScreen({
    this.socialLogin = false,
    this.isOtp = false,
    this.countryCode,
    this.privacyPolicyUrl,
    this.termsConditionUrl,
    this.userId,
    this.token,
    this.contactNo
  });

  @override
  DriverRegisterScreenState createState() => DriverRegisterScreenState();
}

class DriverRegisterScreenState extends State<DriverRegisterScreen> {
  AuthServices authService = AuthServices();

  List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController firstController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  // TextEditingController passController = TextEditingController();
  TextEditingController carModelController = TextEditingController();
  TextEditingController carProductionController = TextEditingController();
  TextEditingController carPlateController = TextEditingController();
  TextEditingController carColorController = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();

  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  bool mIsCheck = false;
  bool isAcceptedTc = false;
  String countryCode = defaultCountryCode;
  int currentIndex = 0;
  List<ServiceList> listServices = [];
  List<String> gender = [MALE, FEMALE, OTHER];
  String selectGender = MALE;

  int vehicleTypeIndex = 0;

  XFile? imageProfile;
  int radioValue = -1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (sharedPref.getString(PLAYER_ID).validate().isEmpty) {
      await saveOneSignalPlayerId().then((value) {
        //
      });
    }
    await getServices().then((value) {
      print(value.data!.length.toString());
      listServices.addAll(value.data!);
      vehicleTypeIndex = listServices[0].id!;
      setState(() {});
    }).catchError((error) {
      log(error.toString());
    });
  }

  Future<void> registerDriver() async {

    hideKeyboard(context);
    if(widget.userId.toString()!='null'){

      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        if (isAcceptedTc) {
          appStoreClient.setLoading(true);

          sharedPref.setString(USER_ID, widget.userId.toString());
          await updateProfile(
            isRegister: true,
            token: widget.token.toString(),
            firstName: firstController.text.toString(),
            lastName: lastNameController.text,
            userEmail: emailController.text.toString(),
            gender: selectGender,
            id: widget.userId,
            contactNumber: widget.contactNo.toString()
          ).then((res) async {
            appStoreClient.setLoading(false);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  DriverDashboardScreen()),
            );
            //
          }).catchError((e) {
            appStoreClient.setLoading(false);
            toast(e.toString());
          });
        } else {
          toast(language.pleaseAcceptTermsOfServicePrivacyPolicy);
        }
      }
      ;
    }

  }

  Future<void> register() async {
    hideKeyboard(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (isAcceptedTc) {
        appStoreClient.setLoading(true);
        authService
            .signUpWithEmailPassword(
          context,
          name: firstController.text.trim(),
          mobileNumber: widget.socialLogin
              ? '$countryCode ${widget.userName}'
              : '$countryCode ${phoneController.text.trim()}',
          email: emailController.text.trim(),
          fName: firstController.text.trim(),
          lName: lastNameController.text.trim(),
          userName: widget.socialLogin
              ? widget.userName
              : userNameController.text.trim(),
          // password:
          //     widget.socialLogin ? widget.userName : passController.text.trim(),
          userType: 'driver',
          socialLoginName: widget.socialLogin,
          isOtp: widget.isOtp,
          serviceId: listServices[vehicleTypeIndex].id,
          gender: selectGender,
          userDetail: UserDetail(
            carModel: carModelController.text.trim(),
            carColor: carColorController.text.trim(),
            carPlateNumber: carPlateController.text.trim(),
            carProductionYear: carProductionController.text.trim(),
          ),
        )
            .then((res) async {
          appStoreClient.setLoading(false);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  DriverDashboardScreen()),
          );
          //
        }).catchError((e) {
          appStoreClient.setLoading(false);
          toast(e.toString());
        });
      } else {
        toast(language.pleaseAcceptTermsOfServicePrivacyPolicy);
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(250.0),
          child: AppBar(
            flexibleSpace: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(0, 52, 111, 1), // rgba(0, 52, 111, 1)
                      Color.fromRGBO(0, 112, 90, 1), // rgba(0, 112, 90, 1)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context, true);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Text("  " + language.createProfile,
                            style: boldTextStyle(color: Colors.white)),
                        Text('')
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "  Truck Driver",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              Text(
                                "  Sign Up",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5, top: 4),
                            child: Image.asset(
                              'images/ic_logo_white.png',
                              width: 75,
                              height: 75,
                              fit: BoxFit.cover,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
            iconTheme: IconThemeData(color: Colors.white),
            automaticallyImplyLeading: false,
          ),
        ),
        body: Stack(
          children: [
            Form(
              key: formKey,
              child: Stepper(
                controlsBuilder:
                    (BuildContext context, ControlsDetails controls) {
                  return Row(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: controls.onStepContinue,
                        child: Text('CONTINUE',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: borderColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: controls.onStepCancel,
                        child: Text('CANCEL',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  );
                },
                currentStep: currentIndex,
                connectorColor: MaterialStateProperty.all<Color>(borderColor),
                onStepCancel: () {
                  if (currentIndex > 0) {
                    currentIndex--;
                    setState(() {});
                  }
                },
                onStepContinue: ()async {
                  print('*clicked');
                  // Ensure that formKeys[currentIndex] and its currentState are not null
                  if (formKeys[currentIndex].toString() != "null" &&
                      formKeys[currentIndex].currentState != null &&
                      formKeys[currentIndex].currentState!.validate()) {
                    if (currentIndex == 1 && listServices.isEmpty) {
                      toast(language.pleaseSelectService);
                    } else if (currentIndex < 2) {
                      currentIndex++;
                    } else if (currentIndex == 2 && isAcceptedTc) {
                     await registerDriver();
                    }

                    setState(() {});
                  } else {
                    print('Error: Form key or its state is null.');
                  }
                },
                onStepTapped: (int index) {
                  currentIndex = index;
                  setState(() {});
                },
                steps: [
                  Step(
                    stepStyle: StepStyle(
                      connectorColor: borderColor,
                      color: borderColor,
                    ),
                    isActive: currentIndex == 0,
                    state: currentIndex > 0
                        ? StepState.complete
                        : StepState.indexed,
                    title: Text("Basic Information", style: boldTextStyle()),
                    content: Form(
                      key: formKeys[0],
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  textFieldType: TextFieldType.NAME,
                                  controller: firstController,
                                  focus: firstNameFocus,
                                  nextFocus: lastNameFocus,
                                  errorThisFieldRequired:
                                      language.thisFieldRequired,
                                  decoration: inputDecoration(
                                    context,
                                    label: language.firstName,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: AppTextField(
                                  textFieldType: TextFieldType.NAME,
                                  controller: lastNameController,
                                  focus: lastNameFocus,
                                  nextFocus: emailFocus,
                                  errorThisFieldRequired:
                                      language.thisFieldRequired,
                                  decoration: inputDecoration(
                                    context,
                                    label: language.lastName,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  textFieldType: TextFieldType.EMAIL,
                                  focus: emailFocus,
                                  controller: emailController,
                                  errorThisFieldRequired:
                                      language.thisFieldRequired,
                                  decoration: inputDecoration(
                                    context,
                                    label: language.email,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    isActive: currentIndex == 1,
                    state: currentIndex > 1
                        ? StepState.complete
                        : StepState.indexed,
                    title: Text('Select Service', style: boldTextStyle()),
                    content: Form(
                      key: formKeys[1],
                      child: listServices.isNotEmpty
                          ? Column(
                              children: listServices.map((e) {
                                return InkWell(
                                  onTap: () {
                                    vehicleTypeIndex = listServices.indexOf(e);
                                    setState(() {});
                                    print(listServices[vehicleTypeIndex].id);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 8,
                                      top: 4,
                                      bottom: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: vehicleTypeIndex ==
                                                listServices.indexOf(e)
                                            ? Colors.green
                                            : primaryColorD.withOpacity(0.5),
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(defaultRadius),
                                    ),
                                    child: Row(
                                      children: [
                                        commonCachedNetworkImage(
                                          e.serviceImage,
                                          fit: BoxFit.contain,
                                          height: 50,
                                          width: 50,
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            e.name.toString(),
                                            style: boldTextStyle(),
                                          ),
                                        ),
                                        Visibility(
                                          visible: vehicleTypeIndex ==
                                              listServices.indexOf(e),
                                          child: Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          : emptyWidget(),
                    ),
                  ),
                  Step(
                    isActive: currentIndex == 2,
                    state: currentIndex > 2
                        ? StepState.complete
                        : StepState.indexed,
                    title: Text('Gender', style: boldTextStyle()),
                    content: Form(
                      key: formKeys[2],
                      child: Column(
                        children: [
                          DropdownButtonFormField(
                            decoration: inputDecoration(context, label: ""),
                            value: selectGender,
                            onChanged: (String? value) {
                              setState(() {
                                selectGender = value!;
                              });
                            },
                            items: gender.map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(
                                  "${value.capitalizeFirstLetter()}",
                                  style: primaryTextStyle(),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 8),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: primaryColorD,
                            title: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${language.agreeToThe} ',
                                    style: secondaryTextStyle(),
                                  ),
                                  TextSpan(
                                    text: language.termsConditions,
                                    style: boldTextStyle(
                                      color: primaryColorD,
                                      size: 14,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        if (widget.termsConditionUrl != null &&
                                            widget.termsConditionUrl!
                                                .isNotEmpty) {
                                          launchScreen(
                                            context,
                                            TermsConditionScreen(
                                              title: language.termsConditions,
                                              subtitle:
                                                  widget.termsConditionUrl,
                                            ),
                                            pageRouteAnimation:
                                                PageRouteAnimation.Slide,
                                          );
                                        } else {
                                          toast(language.txtURLEmpty);
                                        }
                                      },
                                  ),
                                  TextSpan(
                                      text: ' & ', style: secondaryTextStyle()),
                                  TextSpan(
                                    text: language.privacyPolicy,
                                    style: boldTextStyle(
                                      color: primaryColorD,
                                      size: 14,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        if (widget.privacyPolicyUrl != null &&
                                            widget
                                                .privacyPolicyUrl!.isNotEmpty) {
                                          launchScreen(
                                            context,
                                            TermsConditionScreen(
                                              title: language.privacyPolicy,
                                              subtitle: widget.privacyPolicyUrl,
                                            ),
                                            pageRouteAnimation:
                                                PageRouteAnimation.Slide,
                                          );
                                        } else {
                                          toast(language.txtURLEmpty);
                                        }
                                      },
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.left,
                            ),
                            value: isAcceptedTc,
                            onChanged: (val) async {
                              isAcceptedTc = val!;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
      ),
    );
  }
}
