import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:taxi_driver/model/UserDetailModel.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';

import '../main.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';

class BankInfoScreen extends StatefulWidget {
  @override
  BankInfoScreenState createState() => BankInfoScreenState();
}

class BankInfoScreenState extends State<BankInfoScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankCodeController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();

  UserBankAccount? bankDetail;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStoreClient.setLoading(true);
    await getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) {
      if (value.data!.userBankAccount != null) {
        bankDetail = value.data!.userBankAccount!;
        bankNameController.text = bankDetail!.bankName.validate();
        bankCodeController.text = bankDetail!.bankCode.validate();
        accountHolderNameController.text = bankDetail!.accountHolderName.validate();
        accountNumberController.text = bankDetail!.accountNumber.validate();
        appStoreClient.setLoading(false);
        setState(() {});
      }
      appStoreClient.setLoading(false);
    }).catchError((error) {
      appStoreClient.setLoading(false);
      log(error.toString());
    });
  }

  Future<void> updateBankInfo() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStoreClient.setLoading(true);
      updateBankDetail(
        accountName: accountHolderNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        bankCode: bankCodeController.text.trim(),
        bankName: bankNameController.text.trim(),
      ).then((value) {
        appStoreClient.setLoading(false);

        Navigator.pop(context);
        toast(language.bankInfoUpdateSuccessfully);
      }).catchError((error) {
        appStoreClient.setLoading(false);
        log(error.toString());
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
      appBar: AppBar(
        backgroundColor: borderColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(language.bankInfo, style: boldTextStyle(color: Colors.white)),
      ),
      body: Form(
        key: formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  AppTextField(
                    controller: bankNameController,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(context, label: language.bankName),
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: bankCodeController,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: language.thisFieldRequired,
                    decoration: inputDecoration(context, label: language.bankCode),
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: accountHolderNameController,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: language.thisFieldRequired,
                    decoration: inputDecoration(context, label: language.accountHolderName),
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: accountNumberController,
                    textFieldType: TextFieldType.PHONE,
                    errorThisFieldRequired: language.thisFieldRequired,
                    decoration: inputDecoration(context, label: language.accountNumber),
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: AppButtonWidget(
          text: bankDetail != null ? language.updateBankDetail : language.addBankDetail,
          color: borderColor,
          textStyle: boldTextStyle(color: Colors.white),
          onTap: () {
            updateBankInfo();
          },
        ),
      ),
    );
  }
}
