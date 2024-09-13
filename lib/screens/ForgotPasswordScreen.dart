import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';

import '../../main.dart';
import '../../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController forgotEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      Map req = {
        'email': forgotEmailController.text.trim(),
      };
      appStoreClient.setLoading(true);

      await forgotPassword(req).then((value) {
        toast(value.message.validate());

        appStoreClient.setLoading(false);

        Navigator.pop(context);
      }).catchError((error) {
        appStoreClient.setLoading(false);

        toast(error.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.arrow_back_rounded,color: Colors.white,),
                        ),
                      ),
                      Text("  " + language.forgotPassword,
                          style: boldTextStyle(color: Colors.white, size: 18)),
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
                              "  Forgot Password",
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.forgotPassword, style: boldTextStyle(size: 20)),
                  SizedBox(height: 16),
                  Text(language.enterTheEmailAssociatedWithYourAccount, style: primaryTextStyle(size: 14), textAlign: TextAlign.start),
                  SizedBox(height: 32),
                  AppTextField(
                    controller: forgotEmailController,
                    autoFocus: false,
                    textFieldType: TextFieldType.EMAIL,
                    errorThisFieldRequired: language.thisFieldRequired,
                    decoration: inputDecoration(context, label: language.email),
                  ),
                  SizedBox(height: 32),
                  AppButtonWidget(
                    width: MediaQuery.of(context).size.width,
                    color: borderColor,
                    textStyle: boldTextStyle(color: Colors.white),
                    text: language.submit,
                    onTap: () {
                      if (sharedPref.getString(USER_EMAIL) == 'mark80@gmail.com') {
                        toast(language.demoMsg);
                      } else {
                        submit();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Observer(
            builder: (context) {
              return Visibility(
                visible: appStoreClient.isLoading,
                child: loaderWidget(),
              );
            },
          ),
        ],
      ),
    );
  }
}
