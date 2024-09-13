import 'dart:convert';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../model/RideHistory.dart';
import '../../utils/Common.dart';
import '../screens/RiderDashBoardScreen.dart';
import '../utils/Common.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../utils/Extensions/app_common.dart';

import '../../main.dart';
import '../../model/CurrentRequestModel.dart';
import '../../model/RiderModel.dart';
import '../../network/RestApis.dart';
import '../../screens/RideHistoryScreen.dart';
import '../../utils/Colors.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/AppButtonWidget.dart';
import '../utils/images.dart';

class OrderDetailScreen extends StatefulWidget {
  final int? rideId;

  OrderDetailScreen({this.rideId});

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  List<RideHistory> rideHistory = [];

  CurrentRequestModel? currentData;
  bool isCashPayment = true;
  bool isShow = false;
  RiderModel? riderModel;
  Payment? paymentData;

  bool isPaymentDone = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStoreClient.setLoading(true);
    await getCurrentRideRequest().then((value) async {
      appStoreClient.setLoading(false);
      currentData = value;
      mqttForUser();
      await orderDetailApi();
      setState(() {});
    }).catchError((error) {
      appStoreClient.setLoading(false);
      log(error.toString());
    });
  }

  Future<void> savePaymentApi() async {
    appStoreClient.setLoading(true);
    Map req = {
      "id": currentData!.payment!.id,
      "rider_id": currentData!.payment!.riderId,
      "ride_request_id": currentData!.payment!.rideRequestId,
      "datetime": DateTime.now().toString(),
      "total_amount": currentData!.payment!.totalAmount,
      "payment_type": 'wallet',
      "txn_id": "",
      "payment_status": "paid",
      "transaction_detail": ""
    };
    await savePayment(req).then((value) {
      appStoreClient.setLoading(false);
      launchScreen(context, RiderDashBoardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
    }).catchError((error) {
      isShow = true;
      setState(() {});
      appStoreClient.setLoading(false);
      log(error.toString());
      toast(error.toString());
    });
  }

  Future<void> rideRequest() async {
    appStoreClient.setLoading(true);
    Map req = {
      "payment_type": isCashPayment ? 'cash' : 'wallet',
      "is_change_payment_type": 1,
    };
    log(req);
    await rideRequestUpdateClient(request: req, rideId: currentData!.payment!.rideRequestId).then((value) async {
      appStoreClient.setLoading(false);
      init();
    }).catchError((error) {
      appStoreClient.setLoading(false);
      log(error.toString());
    });
  }

  Future<void> orderDetailApi() async {
    appStoreClient.setLoading(true);
    await rideDetail(orderId: currentData!.payment!.rideRequestId).then((value) {
      appStoreClient.setLoading(false);
      riderModel = value.data;
      if (value.payment != null) {
        paymentData = value.payment;
      }
      rideHistory = value.rideHistory!;
      setState(() {});
    }).catchError((error) {
      appStoreClient.setLoading(false);
    });
  }

  mqttForUser() async {
    client.setProtocolV311();
    client.logging(on: true);
    client.keepAlivePeriod = 120;
    client.autoReconnect = true;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      debugPrint(e.toString());
      client.connect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      client.onSubscribed = onSubscribed;

      debugPrint('connected');
    } else {
      client.connect();
    }

    void onconnected() {
      debugPrint('connected');
    }

    client.subscribe('ride_request_status_' + sharedPref.getInt(USER_ID).toString(), MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (jsonDecode(pt)['success_type'] == 'payment_status_message') {
        setState(() {
          isPaymentDone = true;
        });
        Future.delayed(
          Duration(seconds: 5),
          () {
            setState(() {
              isPaymentDone = false;
            });
            launchScreen(context, RiderDashBoardScreen(), isNewTask: true);
          },
        );
      }
    });

    client.onConnected = onconnected;
  }

  void onConnected() {
    log('Connected');
  }

  void onSubscribed(String topic) {
    log('Subscription confirmed for topic $topic');
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
        title: Text(language.paymentDetail, style: boldTextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          currentData != null
              ? SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: appStoreClient.isDarkMode ? scaffoldSecondaryDark : primaryColorD.withOpacity(0.05),
                          borderRadius: radius(),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(language.rideId, style: boldTextStyle(size: 16)),
                                SizedBox(width: 8),
                                Text('#${riderModel!.id}', style: boldTextStyle(size: 16)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Ionicons.calendar, color: textSecondaryColorGlobal, size: 18),
                                SizedBox(width: 8),
                                Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Text('${printDate(riderModel!.createdAt.validate())}', style: primaryTextStyle(size: 14)),
                                ),
                              ],
                            ),
                            Divider(height: 30, thickness: 1),
                            Text('${language.lblDistance} ${riderModel!.distance.toString()} ${riderModel!.distanceUnit.toString()}', style: boldTextStyle(size: 14)),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Icon(Icons.near_me, color: Colors.green),
                                    SizedBox(height: 4),
                                    SizedBox(
                                      height: 34,
                                      child: DottedLine(
                                        direction: Axis.vertical,
                                        lineLength: double.infinity,
                                        lineThickness: 1,
                                        dashLength: 2,
                                        dashColor: primaryColorD,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Icon(Icons.location_on, color: Colors.red),
                                  ],
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(riderModel!.startAddress.validate(), style: primaryTextStyle(size: 14)),
                                      SizedBox(height: 22),
                                      Text(riderModel!.endAddress.validate(), style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 30, thickness: 1),
                            inkWellWidget(
                              onTap: () {
                                launchScreen(context, RideHistoryScreen(rideHistory: rideHistory), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(language.viewHistory, style: primaryTextStyle(color: primaryColorD)),
                                  Icon(Entypo.chevron_right, color: primaryColorD, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(color: appStoreClient.isDarkMode ? scaffoldSecondaryDark : primaryColorD.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.paymentDetails, style: boldTextStyle(size: 16)),
                            Divider(height: 30, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.paymentType, style: primaryTextStyle()),
                                Text(paymentStatus(riderModel!.paymentType.validate()), style: boldTextStyle()),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.paymentStatus, style: primaryTextStyle()),
                                Text(paymentStatus(riderModel!.paymentStatus.validate()), style: boldTextStyle()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(color: appStoreClient.isDarkMode ? scaffoldSecondaryDark : primaryColorD.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.priceDetail, style: boldTextStyle(size: 16)),
                            Divider(height: 30, thickness: 1),
                            totalCount(title: language.basePrice, description: '', subTitle: '${riderModel!.baseFare}'),
                            SizedBox(height: 8),
                            totalCount(title: language.distancePrice, description: '', subTitle: riderModel!.perDistanceCharge.toString()),
                            SizedBox(height: 8),
                            totalCount(title: language.duration, description: '', subTitle: '${riderModel!.perMinuteDriveCharge}'),
                            SizedBox(height: 8),
                            totalCount(title: language.waitTime, description: '', subTitle: '${riderModel!.perMinuteWaitingCharge}'),
                            SizedBox(height: 8),
                            if (paymentData != null) totalCount(title: language.tip, description: '', subTitle: paymentData!.driverTips.toString()),
                            if (paymentData != null) SizedBox(height: 8),
                            if (riderModel!.extraCharges!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.extraCharges, style: boldTextStyle()),
                                  SizedBox(height: 8),
                                  ...riderModel!.extraCharges!.map((e) {
                                    return Padding(
                                      padding: EdgeInsets.only(top: 4, bottom: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(e.key.validate().capitalizeFirstLetter(), style: primaryTextStyle()),
                                          Text(appStoreClient.currencyPosition == LEFT ? '${appStoreClient.currencyCode} ${e.value}' : '${e.value} ${appStoreClient.currencyCode}', style: primaryTextStyle()),
                                        ],
                                      ),
                                    );
                                  }).toList()
                                ],
                              ),
                            if (riderModel!.couponData != null && riderModel!.couponDiscount != 0) SizedBox(height: 8),
                            if (riderModel!.couponData != null && riderModel!.couponDiscount != 0)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(language.couponDiscount, style: primaryTextStyle(color: Colors.red)),
                                  Text(appStoreClient.currencyPosition == LEFT ? '-${appStoreClient.currencyCode} ${riderModel!.couponDiscount.toString()}' : '-${riderModel!.couponDiscount.toString()} ${appStoreClient.currencyCode}',
                                      style: primaryTextStyle(color: Colors.green)),
                                ],
                              ),
                            Divider(height: 30, thickness: 1),
                            totalCount(title: language.total, description: '', subTitle: '${riderModel!.subtotal}', isTotal: true),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      if (currentData!.payment != null && currentData!.payment!.paymentStatus != COMPLETED && isShow)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Text(language.payment, style: boldTextStyle()),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: inkWellWidget(
                                    onTap: () {
                                      isCashPayment = true;
                                      setState(() {});
                                    },
                                    child: scheduleOptionWidget(context, isCashPayment, 'images/ic_cash.png', language.cash),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: inkWellWidget(
                                    onTap: () {
                                      isCashPayment = false;
                                      setState(() {});
                                    },
                                    child: scheduleOptionWidget(context, !isCashPayment, 'images/ic_credit_card.png', language.wallet),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: AppButtonWidget(
                                text: language.updatePaymentStatus,
                                textStyle: boldTextStyle(color: Colors.white),
                                color: primaryColorD,
                                onTap: () {
                                  isShow = false;
                                  rideRequest();
                                },
                              ),
                            )
                          ],
                        ),
                      SizedBox(height: 8),
                      if (currentData!.payment != null)
                        AppButtonWidget(
                          text: getButtonText(),
                          textStyle: boldTextStyle(color: Colors.white,size: 14),
                          color: primaryColorD,
                          width: MediaQuery.of(context).size.width,
                          onTap: () {
                            if (currentData!.payment!.paymentStatus == COMPLETED) {
                              launchScreen(context, RiderDashBoardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                            } else if (currentData!.payment!.paymentStatus != COMPLETED && currentData!.payment!.paymentType == 'cash') {
                              toast(language.waitingForDriverConformation);
                            } else if (currentData!.payment!.paymentStatus != COMPLETED && currentData!.payment!.paymentType == 'wallet') {
                              savePaymentApi();
                            }
                          },
                        ),
                      if (currentData!.payment == null)
                        AppButtonWidget(
                          text: language.continueNewRide,
                          textStyle: boldTextStyle(color: Colors.white),
                          color: primaryColorD,
                          width: MediaQuery.of(context).size.width,
                          onTap: () {
                            launchScreen(context, RiderDashBoardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                          },
                        )
                    ],
                  ),
                )
              : Observer(builder: (context) {
                  return Visibility(
                    visible: appStoreClient.isLoading,
                    child: loaderWidget(),
                  );
                }),
          Visibility(
              visible: isPaymentDone,
              child: Center(
                  child: Container(
                    width: 250,height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(defaultRadius),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.4), blurRadius: 10, spreadRadius: 0, offset: Offset(0.0, 0.0)),
                        ],
                      ),
                      child: Lottie.asset(paymentSuccessful, width: 450, height: 450, fit: BoxFit.contain)))),
        ],
      ),
    );
  }

  String? getButtonText() {
    if (currentData!.payment!.paymentStatus == COMPLETED) {
      return language.continueNewRide;
    } else if (currentData!.payment!.paymentStatus != COMPLETED && currentData!.payment!.paymentType == 'cash') {
      return language.waitingForDriverConformation;
    } else if (currentData!.payment!.paymentStatus != COMPLETED && currentData!.payment!.paymentType == 'wallet') {
      return language.payToPayment;
    }
    return '';
  }
}
