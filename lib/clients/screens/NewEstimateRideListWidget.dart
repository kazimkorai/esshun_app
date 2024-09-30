import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:taxi_driver/clients/components/CouPonWidget.dart';
import 'package:taxi_driver/clients/network/RestApis.dart';
import 'package:taxi_driver/utils/Colors.dart';
import '../../model/new_service_model.dart';
import '../components/RideAcceptWidget.dart';
import '../main.dart';
import '../screens/ReviewScreen.dart';
import '../utils/Colors.dart';
import '../utils/Extensions/StringExtensions.dart';

import '../../main.dart';
import '../../network/RestApis.dart';

import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/AppButtonWidget.dart';
import '../../utils/Extensions/app_common.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../components/BookingWidget.dart';
import '../components/CarDetailWidget.dart';
import '../model/CurrentRequestModel.dart';
import '../model/EstimatePriceModel.dart';
import '../utils/Extensions/ConformationDialog.dart';
import '../utils/images.dart';
import 'RiderDashBoardScreen.dart';

class NewEstimateRideListWidget extends StatefulWidget {
  final LatLng sourceLatLog;
  final LatLng destinationLatLog;
  final String sourceTitle;
  final String destinationTitle;
  bool isCurrentRequest;
  final int? servicesId;
  final int? id;

  NewEstimateRideListWidget({
    required this.sourceLatLog,
    required this.destinationLatLog,
    required this.sourceTitle,
    required this.destinationTitle,
    this.isCurrentRequest = false,
    this.servicesId,
    this.id,
  });

  @override
  NewEstimateRideListWidgetState createState() =>
      NewEstimateRideListWidgetState();
}

class NewEstimateRideListWidgetState extends State<NewEstimateRideListWidget> {
  List<ListServicesModel> subServiceList = [];
  ListServicesModel? dropDownSubCat;
  List<ListServicesModel> newServicesModel = [];

  int? selectedIndexSubcat;
  List<String> goodsTypes = [
    'Food',
    'Building Materials',
    'Auto Parts',
    'Tools and Equipment',
    'Other',
  ];

  String? selectedGoodsType;
  bool isOtherSelected = false;
  bool showListView = false;
  bool isLoadingMain = false;
  bool isLoadingSublist = false;
  TextEditingController textEditingController = new TextEditingController();

  ///
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> markers = {};
  Set<Polyline> _polyLines = Set<Polyline>();
  late PolylinePoints polylinePoints;
  late Marker sourceMarker;
  late Marker destinationMarker;
  late LatLng userLatLong;
  late DateTime scheduleData;
  TextEditingController promoCode = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isBooking = false;
  bool isRideSelection = false;
  bool isOther = true;
  int selectedIndex = 0;
  int rideRequestId = 0;
  int? mTotalAmount;
  String? mSelectServiceAmount;
  List<String> cashList = ['cash', 'wallet'];
  List<ServicesListDataEstimate> serviceList = [];
  List<LatLng> polylineCoordinates = [];
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  late BitmapDescriptor driverIcon;
  LatLng? driverLatitudeLocation;
  String paymentMethodType = '';
  ServicesListDataEstimate? servicesListData;
  OnRideRequest? rideRequest;
  Driver? driverData;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    mGetServices();
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), SourceIcon);
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), DestinationIcon);
    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), DriverIcon);
    getServiceList();
    getCurrentRequest();
    mqttForUser();
    if (!widget.isCurrentRequest) getNewService();
    isBooking = widget.isCurrentRequest;
    // await  getWalletData().then((value) {
    //     mTotalAmount = value.totalAmount;
    //   });
  }

  Future<void> getCurrentRequest() async {
    await getCurrentRideRequestClient().then((value) {
      if (value.rideRequest != null || value.onRideRequest != null) {
        rideRequest = value.rideRequest ?? value.onRideRequest;
      }
      if (value.driver != null) {
        driverData = value.driver!;
      }

      if (rideRequest != null) {
        //getUserDetailLocation();
        setState(() {});
        if (driverData != null) {
          timer = Timer.periodic(
              Duration(seconds: 10), (Timer t) => getUserDetailLocation());
        }
      }
      if (rideRequest!.status == COMPLETED &&
          rideRequest != null &&
          driverData != null) {
        launchScreen(context,
            ReviewScreen(rideRequest: rideRequest!, driverData: driverData),
            pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
            isNewTask: true);
      }
    }).catchError((error) {
      log(error.toString());
    });
  }

  mGetServices() async {
    await getServicesRiderNew().then((value) {
      newServicesModel.addAll(value);
    });
  }

  Future<void> getServiceList() async {
    markers.clear();
    polylinePoints = PolylinePoints();
    setPolyLines(
      sourceLocation:
          LatLng(widget.sourceLatLog.latitude, widget.sourceLatLog.longitude),
      destinationLocation: LatLng(widget.destinationLatLog.latitude,
          widget.destinationLatLog.longitude),
      driverLocation: driverLatitudeLocation,
    );
    MarkerId id = MarkerId('Source');
    markers.add(
      Marker(
        markerId: id,
        position:
            LatLng(widget.sourceLatLog.latitude, widget.sourceLatLog.longitude),
        infoWindow: InfoWindow(title: widget.sourceTitle),
        icon: sourceIcon,
      ),
    );
    MarkerId id2 = MarkerId('DriverLocation');
    markers.remove(id2);

    MarkerId id3 = MarkerId('Destination');
    markers.remove(id3);
    rideRequest != null &&
            (rideRequest!.status == ACCEPTED ||
                rideRequest!.status == ARRIVING ||
                rideRequest!.status == ARRIVED)
        ? markers.add(
            Marker(
              markerId: id2,
              position: driverLatitudeLocation!,
              icon: driverIcon,
            ),
          )
        : markers.add(
            Marker(
              markerId: id3,
              position: LatLng(widget.destinationLatLog.latitude,
                  widget.destinationLatLog.longitude),
              infoWindow: InfoWindow(title: widget.destinationTitle),
              icon: destinationIcon,
            ),
          );
    setState(() {});
  }

  Future<void> getNewService({bool coupon = false}) async {
    appStoreClient.setLoading(true);
    Map req = {
      "pick_lat": widget.sourceLatLog.latitude,
      "pick_lng": widget.sourceLatLog.longitude,
      "drop_lat": widget.destinationLatLog.latitude,
      "drop_lng": widget.destinationLatLog.longitude,
      if (coupon) "coupon_code": promoCode.text.trim(),
    };
    await estimatePriceList(req).then((value) {
      appStoreClient.setLoading(false);
      serviceList.clear();
      serviceList.addAll(value.data!);

      serviceList[0];

      getSubServicesByIdRider(serviceList[0].id.toString());

      if (serviceList.isNotEmpty) servicesListData = serviceList[0];
      if (serviceList.isNotEmpty)
        paymentMethodType = serviceList[0].paymentMethod!;
      if (serviceList.isNotEmpty)
        cashList = paymentMethodType == 'cash_wallet'
            ? cashList = ['cash', 'wallet']
            : cashList = [paymentMethodType];
      if (serviceList.isNotEmpty) {
        if (serviceList[0].discountAmount != 0) {
          mSelectServiceAmount =
              serviceList[0].subtotal!.toStringAsFixed(fixedDecimal);
        } else {
          mSelectServiceAmount =
              serviceList[0].totalAmount!.toStringAsFixed(fixedDecimal);
        }
      }
      setState(() {});
    }).catchError((error) {
      appStoreClient.setLoading(false);
      toast(error.toString());
    });
  }

  Future<void> getCouponNewService() async {
    appStoreClient.setLoading(true);
    Map req = {
      "pick_lat": widget.sourceLatLog.latitude,
      "pick_lng": widget.sourceLatLog.longitude,
      "drop_lat": widget.destinationLatLog.latitude,
      "drop_lng": widget.destinationLatLog.longitude,
      "coupon_code": promoCode.text.trim(),
    };
    await estimatePriceList(req).then((value) {
      appStoreClient.setLoading(false);
      serviceList.clear();
      serviceList.addAll(value.data!);
      if (serviceList.isNotEmpty) servicesListData = serviceList[selectedIndex];
      if (serviceList.isNotEmpty)
        cashList = paymentMethodType == 'cash_wallet'
            ? cashList = ['cash', 'wallet']
            : cashList = [paymentMethodType];
      if (serviceList.isNotEmpty) {
        if (serviceList[selectedIndex].discountAmount != 0) {
          mSelectServiceAmount = serviceList[selectedIndex]
              .subtotal!
              .toStringAsFixed(fixedDecimal);
        } else {
          mSelectServiceAmount = serviceList[selectedIndex]
              .totalAmount!
              .toStringAsFixed(fixedDecimal);
        }
      }
      setState(() {});
      Navigator.pop(context);
    }).catchError((error) {
      promoCode.clear();
      Navigator.pop(context);

      appStoreClient.setLoading(false);
      toast(error.toString());
    });
  }

  Future<void> setPolyLines(
      {required LatLng sourceLocation,
      required LatLng destinationLocation,
      LatLng? driverLocation}) async {
    _polyLines.clear();
    polylineCoordinates.clear();
    // var result = await polylinePoints.getRouteBetweenCoordinates(
    //   googleMapAPIKey,
    //   PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
    //   rideRequest != null && (rideRequest!.status == ACCEPTED || rideRequest!.status == ARRIVING || rideRequest!.status == ARRIVED)
    //       ? PointLatLng(driverLocation!.latitude, driverLocation.longitude)
    //       : PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
    // );
    var result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleMapAPIKey,
      request: PolylineRequest(
        origin: servicesListData!.status != IN_PROGRESS
            ? PointLatLng(
                double.parse(servicesListData!.startLatitude.validate()),
                double.parse(servicesListData!.startLongitude.validate()))
            : PointLatLng(
                double.parse(servicesListData!.endLatitude.validate()),
                double.parse(servicesListData!.endLongitude.validate())),
        destination: servicesListData!.status != IN_PROGRESS
            ? PointLatLng(
                double.parse(servicesListData!.startLatitude.validate()),
                double.parse(servicesListData!.startLongitude.validate()))
            : PointLatLng(
                double.parse(servicesListData!.endLatitude.validate()),
                double.parse(servicesListData!.endLongitude.validate())),
        mode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
      ),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((element) {
        polylineCoordinates.add(LatLng(element.latitude, element.longitude));
      });
      _polyLines.add(Polyline(
        visible: true,
        width: 5,
        polylineId: PolylineId('poly'),
        color: Color.fromARGB(255, 40, 122, 198),
        points: polylineCoordinates,
      ));
      setState(() {});
    }
  }

  onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future<void> saveBookingData() async {
    if (isOther == false && nameController.text.isEmpty) {
      return toast(language.nameFieldIsRequired);
    } else if (isOther == false && phoneController.text.isEmpty) {
      return toast(language.phoneNumberIsRequired);
    }
    appStoreClient.setLoading(true);
    Map req = {
      "rider_id": sharedPref.getInt(USER_ID).toString(),
      "service_id": servicesListData!.id.toString(),
      "datetime": DateTime.now().toString(),
      "start_latitude": widget.sourceLatLog.latitude.toString(),
      "start_longitude": widget.sourceLatLog.longitude.toString(),
      "start_address": widget.sourceTitle,
      "end_latitude": widget.destinationLatLog.latitude.toString(),
      "end_longitude": widget.destinationLatLog.longitude.toString(),
      "end_address": widget.destinationTitle,
      "seat_count": servicesListData!.capacity.toString(),
      "status": NEW_RIDE_REQUESTED,
      "payment_type": isOther == false
          ? 'cash'
          : paymentMethodType == 'cash_wallet'
              ? 'cash'
              : paymentMethodType,
      if (promoCode.text.isNotEmpty) "coupon_code": promoCode.text,
      "is_schedule": 0,
      if (isOther == false) "is_ride_for_other": 1,
      if (isOther == false)
        "other_rider_data": {
          "name": nameController.text.trim(),
          "contact_number": phoneController.text.trim(),
        }
    };

    log('$req');
    await saveRideRequest(req).then((value) async {
      rideRequestId = value.rideRequestId!;
      widget.isCurrentRequest = true;
      isBooking = true;
      appStoreClient.setLoading(false);
      setState(() {});
    }).catchError((error) {
      appStoreClient.setLoading(false);
      toast(error.toString());
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

    client.subscribe(
        'ride_request_status_' + sharedPref.getInt(USER_ID).toString(),
        MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print("jsonDecode(pt)['success_type']" +
          jsonDecode(pt)['success_type'].toString());

      if (jsonDecode(pt)['success_type'] == ACCEPTED ||
          jsonDecode(pt)['success_type'] == ARRIVING ||
          jsonDecode(pt)['success_type'] == ARRIVED ||
          jsonDecode(pt)['success_type'] == IN_PROGRESS) {
        isBooking = true;
        getCurrentRequest();
      } else if (jsonDecode(pt)['success_type'] == CANCELED) {
        launchScreen(context, RiderDashBoardScreen(), isNewTask: true);
      } else if (jsonDecode(pt)['success_type'] == COMPLETED) {
        if (timer != null) timer!.cancel();
        getCurrentRequest();
        // } else if (appStore.isRiderForAnother == "1" &&
        //     jsonDecode(pt)['success_type'] == SUCCESS) {
        //   if (timer != null) timer!.cancel();
        //   launchScreen(context, RiderDashBoardScreen(), isNewTask: true);

        if (timer != null) timer!.cancel();
        launchScreen(context, RiderDashBoardScreen(), isNewTask: true);
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

  Future<void> getUserDetailLocation() async {
    getUserDetail(userId: driverData!.id).then((value) {
      driverLatitudeLocation = LatLng(double.parse(value.data!.latitude!),
          double.parse(value.data!.longitude!));
      getServiceList();
    }).catchError((error) {
      log(error.toString());
    });
  }

  Future<void> cancelRequest() async {
    Map req = {
      "id": rideRequestId == 0 ? widget.id : rideRequestId,
      "cancel_by": 'rider',
      "status": CANCELED,
    };
    await rideRequestUpdate(
            request: req,
            rideId: rideRequestId == 0 ? widget.id : rideRequestId)
        .then((value) async {
      launchScreen(context, RiderDashBoardScreen(), isNewTask: true);

      toast(value.message);
    }).catchError((error) {
      log(error.toString());
    });
  }

  @override
  void dispose() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      polylineSource = LatLng(value.latitude, value.longitude);
    });
    if (timer != null) timer!.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget mSomeOnElse() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child:
                    Text(language.lblRideInformation, style: boldTextStyle()),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close)),
              ),
            ],
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppTextField(
              controller: nameController,
              autoFocus: false,
              isValidationRequired: false,
              textFieldType: TextFieldType.NAME,
              keyboardType: TextInputType.name,
              errorThisFieldRequired: language.thisFieldRequired,
              decoration: inputDecoration(context, label: language.enterName),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppTextField(
              controller: phoneController,
              autoFocus: false,
              isValidationRequired: false,
              textFieldType: TextFieldType.PHONE,
              keyboardType: TextInputType.number,
              errorThisFieldRequired: language.thisFieldRequired,
              decoration:
                  inputDecoration(context, label: language.enterContactNumber),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: AppButtonWidget(
              width: MediaQuery.of(context).size.width,
              text: language.done,
              textStyle: boldTextStyle(color: Colors.white),
              color: primaryColorD,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 50,
        leading: inkWellWidget(
          onTap: () {
            if (isBooking) {
              showConfirmDialogCustom(context,
                  primaryColor: primaryColorD,
                  title: language.areYouSureYouWantToCancelThisRide,
                  dialogType: DialogType.CONFIRMATION, onAccept: (_) {
                sharedPref.remove(REMAINING_TIME);
                sharedPref.remove(IS_TIME);
                cancelRequest();
              });
            } else {
              launchScreen(context, RiderDashBoardScreen(), isNewTask: true);
            }
          },
          child: Container(
            margin: EdgeInsets.only(left: 8),
            padding: EdgeInsets.all(0),
            decoration:
                BoxDecoration(color: primaryColorD, shape: BoxShape.circle),
            child: Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GoogleMap(
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: onMapCreated,
            initialCameraPosition:
                CameraPosition(target: widget.sourceLatLog, zoom: 11.0),
            markers: markers,
            mapType: MapType.normal,
            polylines: _polyLines,
          ),
          !isBooking
              ? Stack(
                  children: [
                    Visibility(
                      visible: newServicesModel.isNotEmpty,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(defaultRadius),
                                topRight: Radius.circular(defaultRadius))),
                        child: SingleChildScrollView(
                          child: isRideSelection == false &&
                                  appStoreClient.isRiderForAnotherClient == "1"
                              ? Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(bottom: 16),
                                          height: 5,
                                          width: 70,
                                          decoration: BoxDecoration(
                                              color: primaryColorD,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      defaultRadius)),
                                        ),
                                      ),
                                      Text(language.lblWhoRiding,
                                          style: primaryTextStyle(size: 18)),
                                      SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          inkWellWidget(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        height: 70,
                                                        width: 70,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color:
                                                                    textSecondaryColorGlobal,
                                                                width: 1)),
                                                        padding:
                                                            EdgeInsets.all(12),
                                                        child: Image.asset(
                                                            ic_add_user,
                                                            fit: BoxFit.fill),
                                                      ),
                                                      if (!isOther)
                                                        Container(
                                                          height: 70,
                                                          width: 70,
                                                          decoration:
                                                              BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .black54),
                                                          child: Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(language.lblSomeoneElse,
                                                      style:
                                                          primaryTextStyle()),
                                                ],
                                              ),
                                              onTap: () {
                                                isOther = false;
                                                showDialog(
                                                  context: context,
                                                  builder: (_) {
                                                    return StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            StateSetter
                                                                setState) {
                                                      return AlertDialog(
                                                        contentPadding:
                                                            EdgeInsets.all(0),
                                                        content: mSomeOnElse(),
                                                      );
                                                    });
                                                  },
                                                ).then((value) {
                                                  setState(() {});
                                                });
                                                setState(() {});
                                              }),
                                          SizedBox(width: 30),
                                          inkWellWidget(
                                              child: Column(
                                                children: [
                                                  Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(40),
                                                        child:
                                                            commonCachedNetworkImage(
                                                                appStoreClient
                                                                    .userProfile
                                                                    .validate(),
                                                                height: 70,
                                                                width: 70,
                                                                fit: BoxFit
                                                                    .cover),
                                                      ),
                                                      if (isOther)
                                                        Container(
                                                          height: 70,
                                                          width: 70,
                                                          decoration:
                                                              BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .black54),
                                                          child: Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(language.lblYou,
                                                      style:
                                                          primaryTextStyle()),
                                                ],
                                              ),
                                              onTap: () {
                                                isOther = true;
                                                setState(() {});
                                              })
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Text(language.lblWhoRidingMsg,
                                          style: secondaryTextStyle()),
                                      SizedBox(height: 8),
                                      AppButtonWidget(
                                        color: primaryColorD,
                                        onTap: () async {
                                          if (!isOther) {
                                            if (nameController
                                                    .text.isEmptyOrNull ||
                                                phoneController
                                                    .text.isEmptyOrNull) {
                                              showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return StatefulBuilder(
                                                      builder:
                                                          (BuildContext context,
                                                              StateSetter
                                                                  setState) {
                                                    return AlertDialog(
                                                      contentPadding:
                                                          EdgeInsets.all(0),
                                                      content: mSomeOnElse(),
                                                    );
                                                  });
                                                },
                                              ).then((value) {
                                                setState(() {});
                                              });
                                            } else {
                                              isRideSelection = true;
                                            }
                                          } else {
                                            isRideSelection = true;
                                          }
                                          setState(() {});
                                        },
                                        text: language.lblNext,
                                        textStyle:
                                            boldTextStyle(color: Colors.white),
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ///this is top horiz scrool main cat
                                      SingleChildScrollView(
                                        padding:
                                            EdgeInsets.only(left: 8, right: 8),
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: newServicesModel.map((e) {
                                            return GestureDetector(
                                              onTap: () {
                                                getSubServices(e.id.toString());

                                                // if (e.discountAmount != 0) {
                                                //   mSelectServiceAmount = e
                                                //       .subtotal!
                                                //       .toStringAsFixed(
                                                //           fixedDecimal);
                                                // } else {
                                                //   mSelectServiceAmount = e
                                                //       .totalAmount!
                                                //       .toStringAsFixed(
                                                //           fixedDecimal);
                                                // }
                                                // selectedIndex =
                                                //     serviceList.indexOf(e);
                                                // servicesListData = e;
                                                // paymentMethodType =
                                                //     e.paymentMethod!;
                                                // cashList = paymentMethodType ==
                                                //         'cash_wallet'
                                                //     ? cashList = [
                                                //         'cash',
                                                //         'wallet'
                                                //       ]
                                                //     : cashList = [
                                                //         paymentMethodType
                                                //       ];
                                                setState(() {});
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5,
                                                    horizontal: 12),
                                                margin: EdgeInsets.only(
                                                    top: 12, left: 8, right: 8),
                                                decoration: BoxDecoration(
                                                  color: selectedIndex ==
                                                          newServicesModel
                                                              .indexOf(e)
                                                      ? primaryColorD
                                                      : Colors.white,
                                                  border: Border.all(
                                                      color: Color(0xFFD3D3D3)),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          defaultRadius),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 8),
                                                    commonCachedNetworkImage(
                                                        e.imageUrl.toString(),
                                                        height: 45,
                                                        width: 80,
                                                        fit: BoxFit.cover,
                                                        alignment:
                                                            Alignment.center),
                                                    SizedBox(height: 8),
                                                    Text(e.name.toString(),
                                                        style: boldTextStyle(
                                                            color: selectedIndex ==
                                                                    newServicesModel
                                                                        .indexOf(
                                                                            e)
                                                                ? Colors.white
                                                                : primaryColorD)),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(language.capacity,
                                                            style: secondaryTextStyle(
                                                                size: 12,
                                                                color: selectedIndex ==
                                                                    newServicesModel
                                                                            .indexOf(
                                                                                e)
                                                                    ? Colors
                                                                        .white
                                                                    : primaryColorD)),
                                                        SizedBox(width: 4),
                                                        Text(
                                                            e.capacity
                                                                    .toString() +
                                                                " + 1",
                                                            style: secondaryTextStyle(
                                                                color: selectedIndex ==
                                                                        newServicesModel
                                                                            .indexOf(
                                                                                e)
                                                                    ? Colors
                                                                        .white
                                                                    : primaryColorD)),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        // Text(
                                                        //   appStoreClient
                                                        //               .currencyPosition ==
                                                        //           LEFT
                                                        //       ? '${appStoreClient.currencyCode} ${e.totalAmount!.toStringAsFixed(fixedDecimal)}'
                                                        //       : '${e.totalAmount!.toStringAsFixed(fixedDecimal)} ${appStoreClient.currencyCode}',
                                                        //   style: boldTextStyle(
                                                        //     color: selectedIndex ==
                                                        //             serviceList
                                                        //                 .indexOf(
                                                        //                     e)
                                                        //         ? Colors.white
                                                        //         : primaryColorD,
                                                        //     // textDecoration: e.discountAmount != 0 ? TextDecoration.lineThrough : null,
                                                        //   ),
                                                        // ),
                                                        SizedBox(width: 8),
                                                        inkWellWidget(
                                                          onTap: ()
                                                          {
                                                            // showModalBottomSheet(
                                                            //   backgroundColor:
                                                            //       primaryColorD,
                                                            //   context: context,
                                                            //   shape: RoundedRectangleBorder(
                                                            //       borderRadius: BorderRadius.only(
                                                            //           topRight:
                                                            //               Radius.circular(
                                                            //                   defaultRadius),
                                                            //           topLeft: Radius
                                                            //               .circular(
                                                            //                   defaultRadius))),
                                                            //   builder: (_) {
                                                            //     return CarDetailWidget(
                                                            //         service: e);
                                                            //   },
                                                            // );
                                                          },
                                                          child: Icon(
                                                              Icons
                                                                  .info_outline_rounded,
                                                              size: 18,
                                                              color: selectedIndex ==
                                                                  newServicesModel
                                                                          .indexOf(
                                                                              e)
                                                                  ? Colors.white
                                                                  : primaryColorD),
                                                        ),
                                                      ],
                                                    ),
                                                    // if (e.discountAmount != 0)
                                                    //   SizedBox(height: 8),
                                                    // if (e.discountAmount != 0)
                                                    //   Text(
                                                    //     appStoreClient
                                                    //                 .currencyPosition ==
                                                    //             LEFT
                                                    //         ? '${appStoreClient.currencyCode} ${e.subtotal!.toStringAsFixed(fixedDecimal)}'
                                                    //         : '${e.subtotal!.toStringAsFixed(fixedDecimal)} ${appStoreClient.currencyCode}',
                                                    //     style: boldTextStyle(
                                                    //       color: selectedIndex ==
                                                    //               serviceList
                                                    //                   .indexOf(
                                                    //                       e)
                                                    //           ? Colors.white
                                                    //           : primaryColorD,
                                                    //     ),
                                                    //   ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      SizedBox(height: 8),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 12),
                                          dropDownSubCat.toString() == "null"
                                              ? SizedBox.shrink()
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        showListView =
                                                            !showListView; // Toggle ListView visibility
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(7.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        border: Border.all(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5)),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              dropDownSubCat !=
                                                                      null
                                                                  ? Image
                                                                      .network(
                                                                      dropDownSubCat!
                                                                          .imageUrl
                                                                          .toString(),
                                                                      width: 32,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      height:
                                                                          32,
                                                                    )
                                                                  : SizedBox
                                                                      .shrink(),
                                                              Text("  " +
                                                                  dropDownSubCat!
                                                                      .name
                                                                      .toString()),
                                                            ],
                                                          ),
                                                          SizedBox(width: 8.0),
                                                          Icon(Icons
                                                              .keyboard_arrow_down),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12, right: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              // Adjust alignment as needed
                                              children: [
                                                // First container
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      _showBottomModalSheet(
                                                          context);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(7),
                                                      // Add padding inside the container
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        // Background color of the container
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        // Rounded corners
                                                        border: Border.all(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            width:
                                                                1), // Grey border
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            textEditingController
                                                                    .text
                                                                    .isEmpty
                                                                ? "Values"
                                                                : textEditingController
                                                                    .text,
                                                            // Text inside the first container
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                          ),
                                                          Icon(Icons
                                                              .keyboard_arrow_down)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      _showGoodsTypeBottomSheet(
                                                          context, (String
                                                              selectedType) {
                                                        // Update the state in the parent widget
                                                        setState(() {
                                                          selectedGoodsType =
                                                              selectedType;
                                                        });
                                                      });
                                                    },
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.all(7),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              width: 1),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(" " +
                                                                        selectedGoodsType
                                                                            .toString() ==
                                                                    "null"
                                                                ? "Goods Type"
                                                                : " " +
                                                                    selectedGoodsType
                                                                        .toString()),
                                                            Icon(Icons
                                                                .keyboard_arrow_down)
                                                          ],
                                                        )),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                        ],
                                      ),

                                      inkWellWidget(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) {
                                              return StatefulBuilder(builder:
                                                  (BuildContext context,
                                                      StateSetter setState) {
                                                return Observer(
                                                    builder: (context) {
                                                  return Stack(
                                                    children: [
                                                      AlertDialog(
                                                        contentPadding:
                                                            EdgeInsets.all(16),
                                                        content:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                      language
                                                                          .paymentMethod,
                                                                      style:
                                                                          boldTextStyle()),
                                                                  inkWellWidget(
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              6),
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              primaryColorD,
                                                                          shape:
                                                                              BoxShape.circle),
                                                                      child: Icon(
                                                                          Icons
                                                                              .close,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                  language
                                                                      .chooseYouPaymentLate,
                                                                  style:
                                                                      secondaryTextStyle()),
                                                              Text(
                                                                  isOther
                                                                      .toString(),
                                                                  style:
                                                                      secondaryTextStyle()),
                                                              SizedBox(
                                                                  height: 16),
                                                              isOther == false
                                                                  ? RadioListTile(
                                                                      contentPadding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                      controlAffinity:
                                                                          ListTileControlAffinity
                                                                              .trailing,
                                                                      activeColor:
                                                                          primaryColorD,
                                                                      value:
                                                                          'cash',
                                                                      groupValue:
                                                                          'cash',
                                                                      title: Text(
                                                                          language
                                                                              .cash,
                                                                          style:
                                                                              boldTextStyle()),
                                                                      onChanged:
                                                                          (String?
                                                                              val) {
                                                                        print(
                                                                            val);
                                                                      },
                                                                    )
                                                                  : Column(
                                                                      children:
                                                                          cashList
                                                                              .map((e) {
                                                                        return RadioListTile(
                                                                          contentPadding:
                                                                              EdgeInsets.zero,
                                                                          controlAffinity:
                                                                              ListTileControlAffinity.trailing,
                                                                          activeColor:
                                                                              primaryColorD,
                                                                          value:
                                                                              e,
                                                                          groupValue: paymentMethodType == 'cash_wallet'
                                                                              ? 'cash'
                                                                              : paymentMethodType,
                                                                          title: Text(
                                                                              e.capitalizeFirstLetter(),
                                                                              style: boldTextStyle()),
                                                                          onChanged:
                                                                              (String? val) {
                                                                            paymentMethodType =
                                                                                val!;
                                                                            setState(() {});
                                                                          },
                                                                        );
                                                                      }).toList(),
                                                                    ),
                                                              SizedBox(
                                                                  height: 16),
                                                              AppTextField(
                                                                controller:
                                                                    promoCode,
                                                                autoFocus:
                                                                    false,
                                                                textFieldType:
                                                                    TextFieldType
                                                                        .EMAIL,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .emailAddress,
                                                                errorThisFieldRequired:
                                                                    language
                                                                        .thisFieldRequired,
                                                                readOnly: true,
                                                                onTap:
                                                                    () async {
                                                                  var data =
                                                                      await showModalBottomSheet(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (_) {
                                                                      return CouPonWidget();
                                                                    },
                                                                  );
                                                                  if (data !=
                                                                      null) {
                                                                    promoCode
                                                                            .text =
                                                                        data;
                                                                  }
                                                                },
                                                                decoration: inputDecoration(
                                                                    context,
                                                                    label: language
                                                                        .enterPromoCode,
                                                                    suffixIcon: promoCode
                                                                            .text
                                                                            .isNotEmpty
                                                                        ? inkWellWidget(
                                                                            onTap:
                                                                                () {
                                                                              promoCode.clear();
                                                                              getNewService(coupon: false);
                                                                            },
                                                                            child: Icon(Icons.close,
                                                                                color: Colors.black,
                                                                                size: 25),
                                                                          )
                                                                        : null),
                                                              ),
                                                              SizedBox(
                                                                  height: 16),
                                                              AppButtonWidget(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                text: language
                                                                    .confirm,
                                                                textStyle: boldTextStyle(
                                                                    color: Colors
                                                                        .white),
                                                                color:
                                                                    primaryColorD,
                                                                onTap: () {
                                                                  if (promoCode
                                                                      .text
                                                                      .isNotEmpty) {
                                                                    getCouponNewService();
                                                                    //getNewService(coupon: true);
                                                                  } else {
                                                                    // getNewService();
                                                                    Navigator.pop(
                                                                        context);
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: appStoreClient
                                                            .isLoading,
                                                        child: Observer(
                                                            builder: (context) {
                                                          return loaderWidget();
                                                        }),
                                                      ),
                                                    ],
                                                  );
                                                });
                                              });
                                            },
                                          ).then((value) {
                                            setState(() {});
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.fromLTRB(
                                              16, 8, 16, 16),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      defaultRadius)),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 7),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(language.paymentVia,
                                                  style: secondaryTextStyle(
                                                      size: 12)),
                                              SizedBox(height: 8),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(4),
                                                    margin:
                                                        EdgeInsets.only(top: 4),
                                                    decoration: BoxDecoration(
                                                        color: primaryColorD,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                defaultRadius)),
                                                    child: Icon(
                                                        Icons.wallet_outlined,
                                                        size: 20,
                                                        color: Colors.white),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            isOther == false
                                                                ? 'Cash'
                                                                : paymentMethodType ==
                                                                        'cash_wallet'
                                                                    ? 'Cash'
                                                                    : paymentMethodType
                                                                        .capitalizeFirstLetter(),
                                                            style:
                                                                boldTextStyle(
                                                                    size: 14)),
                                                        SizedBox(height: 4),
                                                        SizedBox(height: 4),
                                                        Text(
                                                            paymentMethodType !=
                                                                    'cash_wallet'
                                                                ? language
                                                                    .forInstantPayment
                                                                : language
                                                                    .lblPayWhenEnds,
                                                            style:
                                                                secondaryTextStyle(
                                                                    size: 12)),
                                                        if (mSelectServiceAmount !=
                                                                null &&
                                                            paymentMethodType !=
                                                                'cash_wallet' &&
                                                            paymentMethodType ==
                                                                'wallet' &&
                                                            double.parse(
                                                                    mSelectServiceAmount!) >=
                                                                mTotalAmount!
                                                                    .toDouble())
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 4),
                                                            child: Text(
                                                                language
                                                                    .lblLessWalletAmount,
                                                                style: boldTextStyle(
                                                                    size: 12,
                                                                    color: Colors
                                                                        .red,
                                                                    weight: FontWeight
                                                                        .w500)),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 16, right: 16),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: AppButtonWidget(
                                                color: primaryColorD,
                                                onTap: () {
                                                  saveBookingData();
                                                },
                                                text: language.bookNow,
                                                textStyle: boldTextStyle(
                                                    color: Colors.white),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 16),

                                      Text("data")
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: appStoreClient.isLoading,
                      child: Observer(builder: (context) {
                        return loaderWidget();
                      }),
                    ),
                    if (!appStoreClient.isLoading && serviceList.isEmpty)
                      emptyWidget()
                  ],
                )
              : Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(defaultRadius),
                          topRight: Radius.circular(defaultRadius))),
                  child: rideRequest != null
                      ? rideRequest!.status == NEW_RIDE_REQUESTED
                          ? BookingWidget(id: widget.id)
                          : RideAcceptWidget(
                              rideRequest: rideRequest, driverData: driverData)
                      : BookingWidget(
                          id: rideRequestId == 0 ? widget.id : rideRequestId,
                          isLast: true),
                ),
          Text(
            subServiceList.length.toString(),
            style: TextStyle(color: Colors.red),
          ),
          Positioned(
            top: 60,
            child: showListView
                ? Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      height: 350,
                      // Set height for ListView
                      child: ListView.builder(
                        itemCount: subServiceList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                showListView = false;
                                //  dropDownSubCat = subServiceList[index];
                                // getSubServices(dropDownSubCat!.id.toString());
                                // Trigger the bottom sheet when a service is tapped
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 70,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Image.network(
                                          subServiceList[index].imageUrl,
                                          width: 70,
                                          fit: BoxFit.cover,
                                          height: 32,
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              subServiceList[index].name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            Text(
                                              subServiceList[index]
                                                  .commissionType,
                                              style: TextStyle(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showBottomModalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,
      // Ensures the keyboard doesn't overlap the modal
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            // Background color
            border: Border.all(color: Colors.grey),
            // Grey border for the container
            borderRadius:
                BorderRadius.circular(15), // Rounded corners for the container
          ),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom), // Adjust for the keyboard
            child: Column(
              children: [
                SizedBox(
                  height: 8,
                ),
                Text(
                  'Goods value',
                  style: TextStyle(
                      fontSize: 16,
                      color: primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8,
                ),
                Divider(
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(16),
                      // Padding inside the TextField
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        // Rounded corners for TextField
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(
                                0.5)), // Grey border when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        // Rounded corners for TextField when focused
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 2.0), // Blue border when focused
                      ),
                      hintText: 'Example: 5000 OM', // Placeholder text
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      "Note According to value of your products we will provide you insurance "),
                ),
                SizedBox(
                  height: 8,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(15),
                      // Add padding inside the container
                      decoration: BoxDecoration(
                        color: primaryColor,
                        // Background color of the container
                        borderRadius: BorderRadius.circular(12.0),
                        // Rounded corners
                      ),
                      child: Center(
                        child: Text(
                          'Book Now',
                          // Text inside the first container
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Function to show the bottom sheet and pass the selected value back to parent
  void _showGoodsTypeBottomSheet(
      BuildContext context, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        String selectedGoodsTypeInModal = selectedGoodsType
            .toString(); // Local variable to manage selection in the modal
        bool isOtherSelectedInModal = isOtherSelected;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Type of Goods',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: goodsTypes.map((String goodsType) {
                        return ListTile(
                          title: Text(
                            goodsType,
                            style: TextStyle(
                                color: selectedGoodsTypeInModal == goodsType
                                    ? Colors.green
                                    : Colors.black,
                                fontSize: 16),
                          ),
                          trailing: selectedGoodsTypeInModal == goodsType
                              ? Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            setState(() {
                              selectedGoodsTypeInModal = goodsType;
                              isOtherSelectedInModal = goodsType == 'Other';
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (isOtherSelectedInModal) ...[
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter other type of goods',
                          contentPadding: EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                    InkWell(
                      onTap: () {
                        // Pass the selected value back to the parent
                        onSelected(selectedGoodsTypeInModal);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                        ),
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            "Done",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Text color
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> getSubServices(String id) async {
    setState(() {
      isLoadingSublist = true;
    });
    subServiceList.clear();
    await getSubServicesByIdRider(id).then((value) {
      setState(() {
        subServiceList.addAll(value);

        // subServiceList = value[0];
        // Optionally reset dropdownValue2 if needed
      });
    });
    setState(() {
      isLoadingSublist = false;
    });
  }
}
