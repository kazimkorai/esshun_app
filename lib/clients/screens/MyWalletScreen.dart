import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../utils/Common.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';

import '../../main.dart';
import '../../model/WalletListModel.dart';
import '../../network/RestApis.dart';
import '../../screens/PaymentScreen.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_textfield.dart';

class MyWalletScreen extends StatefulWidget {
  @override
  MyWalletScreenState createState() => MyWalletScreenState();
}

class MyWalletScreenState extends State<MyWalletScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController addMoneyController = TextEditingController();
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  int totalPage = 1;
  int currentIndex = -1;

  List<WalletModel> walletData = [];

  num totalAmount = 0;

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          appStoreClient.setLoading(true);
          currentPage++;
          setState(() {});

          init();
        }
      }
    });
    afterBuildCreated(() => appStoreClient.setLoading(true));
  }

  void init() async {
    await getWalletList(pageData: currentPage, ).then((value) {
      appStoreClient.setLoading(false);

      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;
      totalAmount = value.walletBalance!.totalAmount ?? 0;
      if (currentPage == 1) {
        walletData.clear();
      }
      walletData.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStoreClient.setLoading(false);
      log(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration:  BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Color.fromRGBO(0, 52, 111, 1), // rgba(0, 52, 111, 1)
                  Color.fromRGBO(0, 112, 90, 1), // rgba(0, 112, 90, 1)
                ]),
          ),
        ),
        title: Text(language.myWallet, style: boldTextStyle(color: Colors.white)),
      ),
      body: Observer(builder: (context) {
        return Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(

                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(language.availableBalance, style: secondaryTextStyle(color: Colors.white)),
                            SizedBox(height: 8),
                            Text(appStoreClient.currencyPosition == LEFT ? '${appStoreClient.currencyCode} $totalAmount' : '$totalAmount ${appStoreClient.currencyCode}',
                                style: boldTextStyle(size: 22, color: Colors.white)),
                          ],
                        ),
                        AppButtonWidget(
                          text: language.addMoney,
                          textStyle: boldTextStyle(color: Colors.white),
                          color: Colors.white30,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius))),
                              builder: (_) {
                                return StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState) {
                                    return Form(
                                      key: formKey,
                                      child: Padding(
                                        padding: MediaQuery.of(context).viewInsets,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:  EdgeInsets.all(16),
                                                    child: Text(language.addMoney, style: boldTextStyle()),
                                                  ),
                                                  IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.close))
                                                ],
                                              ),
                                              Padding(
                                                padding:  EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    AppTextField(
                                                      controller: addMoneyController,
                                                      textFieldType: TextFieldType.PHONE,
                                                      keyboardType: TextInputType.number,
                                                      errorThisFieldRequired: language.thisFieldRequired,
                                                      onChanged: (val) {
                                                        //
                                                      },
                                                      validator: (String? val) {
                                                        if (appStoreClient.minAmountToAdd != null && int.parse(val!) < appStoreClient.minAmountToAdd!) {
                                                          addMoneyController.text = appStoreClient.minAmountToAdd.toString();
                                                          addMoneyController.selection = TextSelection.fromPosition(TextPosition(offset: appStoreClient.minAmountToAdd.toString().length));
                                                          return "Minimum ${appStoreClient.minAmountToAdd} required";
                                                        } else if (appStoreClient.maxAmountToAdd != null && int.parse(val!) > appStoreClient.maxAmountToAdd!) {
                                                          addMoneyController.text = appStoreClient.maxAmountToAdd.toString();
                                                          addMoneyController.selection = TextSelection.fromPosition(TextPosition(offset: appStoreClient.maxAmountToAdd.toString().length));
                                                          return "Maximum ${appStoreClient.maxAmountToAdd} required";
                                                        }
                                                        return null;
                                                      },
                                                      decoration: inputDecoration(context, label: language.amount),
                                                    ),
                                                    SizedBox(height: 16),
                                                    Wrap(
                                                      runSpacing: 8,
                                                      spacing: 8,
                                                      children: appStoreClient.walletPresetTopUpAmount.split('|').map((e) {
                                                        return inkWellWidget(
                                                          onTap: () {
                                                            currentIndex = appStoreClient.walletPresetTopUpAmount.split('|').indexOf(e);
                                                            if (appStoreClient.minAmountToAdd != null && int.parse(e) < appStoreClient.minAmountToAdd!) {
                                                              addMoneyController.text = appStoreClient.minAmountToAdd.toString();
                                                              addMoneyController.selection = TextSelection.fromPosition(TextPosition(offset: appStoreClient.minAmountToAdd.toString().length));
                                                              toast("Minimum ${appStoreClient.minAmountToAdd} required");
                                                            } else if (appStoreClient.minAmountToAdd != null && int.parse(e) < appStoreClient.minAmountToAdd! && appStoreClient.maxAmountToAdd != null && int.parse(e) > appStoreClient.maxAmountToAdd.toString().length) {
                                                              addMoneyController.text = appStoreClient.maxAmountToAdd.toString();
                                                              addMoneyController.selection = TextSelection.fromPosition(TextPosition(offset: e.length));
                                                              toast("Maximum ${appStoreClient.maxAmountToAdd} required");
                                                            } else {
                                                              addMoneyController.text = e;
                                                              addMoneyController.selection = TextSelection.fromPosition(TextPosition(offset: e.length));
                                                            }

                                                            setState(() {});
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.all(8),
                                                            decoration: BoxDecoration(
                                                              color: currentIndex == appStoreClient.walletPresetTopUpAmount.split('|').indexOf(e) ? primaryColor : Colors.white,
                                                              border: Border.all(color: currentIndex == appStoreClient.walletPresetTopUpAmount.split('|').indexOf(e) ? primaryColor : Colors.grey),
                                                              borderRadius: BorderRadius.circular(defaultRadius),
                                                            ),
                                                            child: Text(appStoreClient.currencyPosition == LEFT ? '${appStoreClient.currencyCode} $e' : '$e ${appStoreClient.currencyCode}',
                                                                style: boldTextStyle(color: currentIndex == appStoreClient.walletPresetTopUpAmount.split('|').indexOf(e) ? Colors.white : primaryColor)),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                    SizedBox(height: 16),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: AppButtonWidget(
                                                            text: language.cancel,
                                                            color: Colors.red,
                                                            textStyle: boldTextStyle(color: Colors.white),
                                                            width: MediaQuery.of(context).size.width,
                                                            onTap: () {
                                                              Navigator.pop(context);
                                                            },
                                                          ),
                                                        ),
                                                        SizedBox(width: 16),
                                                        Expanded(
                                                          child: AppButtonWidget(
                                                            text: language.addMoney,
                                                            textStyle: boldTextStyle(color: Colors.white),
                                                            width: MediaQuery.of(context).size.width,
                                                            color: primaryColor,
                                                            onTap: () {
                                                              if (formKey.currentState!.validate() && addMoneyController.text.isNotEmpty) {
                                                                Navigator.pop(context);
                                                               // launchScreen(context, PaymentScreen(amount: int.parse(addMoneyController.text)), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                                                              } else {
                                                                toast(language.pleaseSelectAmount);
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  Text(language.recentTransactions, style: primaryTextStyle()),
                  AnimationLimiter(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: walletData.length,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        WalletModel data = walletData[index];
                        return AnimationConfiguration.staggeredList(
                          delay: Duration(milliseconds: 200),
                          position: index,
                          duration: Duration(milliseconds: 375),
                          child: SlideAnimation(
                            child: Container(
                              margin: EdgeInsets.only(top: 8, bottom: 8),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.4)), borderRadius: BorderRadius.circular(defaultRadius)),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.grey.withOpacity(0.2)),
                                    padding: EdgeInsets.all(8),
                                    child: Icon(data.type == CREDIT ? Icons.add : Icons.remove, color: primaryColor),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data.type == CREDIT ? language.moneyDeposited : language.moneyDebit, style: boldTextStyle(size: 16)),
                                        SizedBox(height: 8),
                                        Text(printDate(data.createdAt!), style: secondaryTextStyle(size: 12)),
                                      ],
                                    ),
                                  ),
                                  Text(appStoreClient.currencyPosition == LEFT ? '${appStoreClient.currencyCode} ${data.amount}' : '${data.amount} ${appStoreClient.currencyCode}',
                                      style: secondaryTextStyle(color: data.type == CREDIT ? Colors.green : Colors.red))
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: appStoreClient.isLoading,
              child: loaderWidget(),
            ),
            !appStoreClient.isLoading && walletData.isEmpty ? emptyWidget() : SizedBox(),
          ],
        );
      }),

    );
  }
}
