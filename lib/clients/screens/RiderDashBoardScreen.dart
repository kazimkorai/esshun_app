import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:taxi_driver/clients/model/ServiceModel.dart';
import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../screens/ReviewScreen.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../components/DrawerWidget.dart';
import '../main.dart';
import '../model/CurrentRequestModel.dart';
import '../model/NearByDriverListModel.dart';
import '../model/TextModel.dart';
import '../network/RestApis.dart';
import '../screens/EmergencyContactScreen.dart';
import '../screens/MyRidesScreen.dart';
import '../screens/MyWalletScreen.dart';
import '../screens/OrderDetailScreen.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/DataProvider.dart';
import '../utils/Extensions/ConformationDialog.dart';
import '../utils/Extensions/LiveStream.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';
import '../utils/images.dart';
import 'EditProfileScreen.dart';
import 'LocationPermissionScreen.dart';
import 'NewEstimateRideListWidget.dart';
import 'NotificationScreen.dart';
import 'RiderWidget.dart';
import 'SettingScreen.dart';

class RiderDashBoardScreen extends StatefulWidget {
  @override
  RiderDashBoardScreenState createState() => RiderDashBoardScreenState();
}

class RiderDashBoardScreenState extends State<RiderDashBoardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isSourcceDest = true;

  LatLng sourceLocation = LatLng(23.5880, 58.3829);
  List<TexIModel> list = getBookList();
  List<Marker> markers = [];
  Set<Polyline> _polyLines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  OnRideRequest? servicesListData;
  TextEditingController goodsValueTxt = TextEditingController();

  double cameraZoom = 14;
  double cameraTilt = 0;
  double cameraBearing = 30;
  int onTapIndex = 0;
  int selectIndex = 0;
  String sourceLocationTitle = '';

  late StreamSubscription<ServiceStatus> serviceStatusStream;

  LocationPermission? permissionData;

  late BitmapDescriptor riderIcon;
  late BitmapDescriptor driverIcon;
  List<NearByDriverListModel>? nearDriverModel;

  Future<void> loginUser(String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  dynamic dropdownValue1;

  dynamic dropdownValue2;

  String dropdownValue3 = 'Goods Value';
  String loadTypes = 'Food';
  PanelController _panelController = PanelController();
  bool isPanelOpen = false;
  List<ServiceList> servicesList = [];
  List<ServiceList> subServiceList = [];
  List<String> listLoadTypes = [
    "Food",
    "Building Materials",
    "Autoparts",
    "Tools And Equipment",
    'Other'
  ];
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _zoomIn() {
    mapController.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  void _zoomOut() {
    mapController.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  @override
  void initState() {
    super.initState();
    locationPermission();
    afterBuildCreated(() {
      init();
      getCurrentRequest();
    });
    loginUser("client");
  }

  Future<void> getSubServices(String id) async {
    subServiceList.clear();
    await getSubServicesById(id).then((value) {
      subServiceList = (value.data!);
      setState(() {});
    });
  }

  Future<void> init() async {
    servicesList.clear;
    subServiceList.clear();

    await getServices().then((value) {
      setState(() {
        servicesList = value.data!;
      });
    });

    await getCurrentUserLocation();

    riderIcon = await BitmapDescriptor.asset(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/source_icon.png');
    driverIcon = await BitmapDescriptor.asset(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/multiple_driver.png');

    await getAppSetting().then((value) {
      if (value.walletSetting!.isNotEmpty) {
        appStoreClient.setWalletPresetTopUpAmount(value.walletSetting!
                .firstWhere((element) => element.key == PRESENT_TOPUP_AMOUNT)
                .value ??
            '10|20|30');
        if (value.walletSetting!
                .firstWhere((element) => element.key == MIN_AMOUNT_TO_ADD)
                .value !=
            null)
          appStoreClient.setMinAmountToAdd(int.parse(value.walletSetting!
              .firstWhere((element) => element.key == MIN_AMOUNT_TO_ADD)
              .value!));
        if (value.walletSetting!
                .firstWhere((element) => element.key == MAX_AMOUNT_TO_ADD)
                .value !=
            null)
          appStoreClient.setMaxAmountToAdd(int.parse(value.walletSetting!
              .firstWhere((element) => element.key == MAX_AMOUNT_TO_ADD)
              .value!));
      }
      if (value.rideSetting!.isNotEmpty) {
        appStoreClient.setWalletTipAmount(value.rideSetting!
                .firstWhere((element) => element.key == PRESENT_TIP_AMOUNT)
                .value ??
            '10|20|30');
        appStoreClient.setIsRiderForAnother(value.rideSetting!
                .firstWhere((element) => element.key == RIDE_FOR_OTHER)
                .value ??
            "0");
        appStoreClient.setRiderMinutes(value.rideSetting!
                .firstWhere(
                    (element) => element.key == MAX_TIME_FOR_RIDER_MINUTE)
                .value ??
            '4');
      }
      if (value.currencySetting != null) {
        appStoreClient
            .setCurrencyCode(value.currencySetting!.symbol ?? currencySymbol);
        appStoreClient
            .setCurrencyName(value.currencySetting!.code ?? currencyNameConst);
        appStoreClient
            .setCurrencyPosition(value.currencySetting!.position ?? LEFT);
      }
    }).catchError((error) {
      log('${error.toString()}');
    });
    polylinePoints = PolylinePoints();
  }

  Future<void> getCurrentUserLocation() async {
    try {
      if (permissionData != LocationPermission.denied) {
        final geoPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high)
            .catchError((error) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
        });
        sourceLocation = LatLng(geoPosition.latitude, geoPosition.longitude);
        List<Placemark>? placemarks = await placemarkFromCoordinates(
            geoPosition.latitude, geoPosition.longitude);

        Placemark place = placemarks[0];
        if (place != null) {
          sourceLocationTitle =
              "${place.name != null ? place.name : place.subThoroughfare}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}, ${place.country}";
          polylineSource = LatLng(geoPosition.latitude, geoPosition.longitude);
        }
        markers.add(
          Marker(
            markerId: MarkerId('Order Detail'),
            position: sourceLocation,
            draggable: true,
            infoWindow: InfoWindow(title: sourceLocationTitle, snippet: ''),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
        startLocationTracking();
        getNearByDriverList(latLng: sourceLocation).then((value) async {
          toast(value.data!.length.toString());
          value.data!.forEach((element) {
            print(element.firstName);
            markers.add(
              Marker(
                markerId: MarkerId('Driver${element.id}'),
                position: LatLng(double.parse(element.latitude!.toString()),
                    double.parse(element.longitude!.toString())),
                infoWindow: InfoWindow(
                    title: '${element.firstName} ${element.lastName}',
                    snippet: 'kkkkkkk'),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );
          });
          setState(() {});
        });
        setState(() {});
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
      }
    } catch (e) {
      toast(e.toString());
      print(e.toString());
    }
  }

  Future<void> getCurrentRequest() async {
    await getCurrentRideRequestClient().then((value) {
      servicesListData = value.rideRequest ?? value.onRideRequest;
      if (servicesListData != null) {
        if (servicesListData!.status != COMPLETED) {
          launchScreen(
            context,
            isNewTask: true,
            NewEstimateRideListWidget(
              sourceLatLog: LatLng(
                  double.parse(servicesListData!.startLatitude!),
                  double.parse(servicesListData!.startLongitude!)),
              destinationLatLog: LatLng(
                  double.parse(servicesListData!.endLatitude!),
                  double.parse(servicesListData!.endLongitude!)),
              sourceTitle: servicesListData!.startAddress!,
              destinationTitle: servicesListData!.endAddress!,
              isCurrentRequest: true,
              servicesId: servicesListData!.serviceId,
              id: servicesListData!.id,
            ),
            pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
          );
        } else if (servicesListData!.status == COMPLETED &&
            servicesListData!.isRiderRated == 0) {
          launchScreen(
              context,
              ReviewScreen(
                  rideRequest: servicesListData!, driverData: value.driver),
              pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
              isNewTask: true);
        }
      } else if (value.payment != null &&
          value.payment!.paymentStatus != COMPLETED) {
        launchScreen(
            context, OrderDetailScreen(rideId: value.payment!.rideRequestId),
            pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
            isNewTask: true);
      }
    }).catchError((error) {
      log(error.toString());
    });
  }

  Future<void> locationPermission() async {
    serviceStatusStream =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        launchScreen(navigatorKey.currentState!.overlay!.context,
            LocationPermissionScreen());
      } else if (status == ServiceStatus.enabled) {
        getCurrentUserLocation();

        if (Navigator.canPop(navigatorKey.currentState!.overlay!.context)) {
          Navigator.pop(navigatorKey.currentState!.overlay!.context);

        }
      }
    }, onError: (error) {
      print(error.toString());
    });
  }

  Future<void> startLocationTracking() async {
    Map req = {
      "status": "active",
      "latitude": sourceLocation!.latitude.toString(),
      "longitude": sourceLocation!.longitude.toString(),
    };

    await updateStatus(req).then((value) {
      //
    }).catchError((error) {
      log(error);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void _onGeoChanged(CameraPosition position) {
    print("position: " + position.target.toString());
    print("zoom: " + position.zoom.toString());
  }

  @override
  Widget build(BuildContext context) {
    LiveStream().on(CHANGE_LANGUAGE, (p0) {
      setState(() {});
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: Drawer(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(right: 8),
                      // decoration: BoxDecoration(border: Border.all(color: primaryColor.withOpacity(0.6)),color: primaryColor.withOpacity(0.2),borderRadius: radius()),
                      child: Observer(builder: (context) {
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: radius(),
                              child: commonCachedNetworkImage(
                                  appStoreClient.userProfile
                                      .validate()
                                      .validate(),
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover),
                            ),
                            SizedBox(height: 8),
                            sharedPref.getString(LOGIN_TYPE) != 'mobile' &&
                                    sharedPref.getString(LOGIN_TYPE) != null
                                ? Text(
                                    sharedPref.getString(USER_NAME).validate(),
                                    style: boldTextStyle())
                                : Text(
                                    sharedPref.getString(FIRST_NAME).validate(),
                                    style: boldTextStyle()),
                            SizedBox(height: 4),
                            Text(appStoreClient.userEmail,
                                style: secondaryTextStyle()),
                          ],
                        );
                      }),
                    ),
                  ),
                  Divider(thickness: 1, height: 40),
                  DrawerWidget(
                    title: language.myProfile,
                    iconData: ic_my_profile,
                    onTap: () {
                      Navigator.pop(context);
                      launchScreen(context, EditProfileScreen(),
                          pageRouteAnimation: PageRouteAnimation.Slide);
                    },
                  ),
                  DrawerWidget(
                      title: language.myRides,
                      iconData: ic_my_rides,
                      onTap: () {
                        Navigator.pop(context);
                        launchScreen(context, MyRidesScreen(),
                            pageRouteAnimation: PageRouteAnimation.Slide);
                      }),
                  DrawerWidget(
                      title: language.myWallet,
                      iconData: ic_my_wallet,
                      onTap: () {
                        Navigator.pop(context);
                        launchScreen(context, MyWalletScreen(),
                            pageRouteAnimation: PageRouteAnimation.Slide);
                      }),
                  DrawerWidget(
                      title: language.emergencyContacts,
                      iconData: ic_emergency_contact,
                      onTap: () {
                        Navigator.pop(context);
                        launchScreen(context, EmergencyContactScreen(),
                            pageRouteAnimation: PageRouteAnimation.Slide);
                      }),
                  DrawerWidget(
                      title: language.setting,
                      iconData: ic_setting,
                      onTap: () {
                        Navigator.pop(context);
                        launchScreen(context, SettingScreen(),
                            pageRouteAnimation: PageRouteAnimation.Slide);
                      }),
                ],
              ),
            ),
            SizedBox(height: 16),
            Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Center(
                  child: Wrap(
                    children: [
                      AppButtonWidget(
                        color: primaryColor,
                        textStyle: boldTextStyle(color: Colors.white),
                        text: language.logOut,
                        onTap: () async {
                          await showConfirmDialogCustom(
                              _scaffoldKey.currentState!.context,
                              primaryColor: primaryColor,
                              dialogType: DialogType.CONFIRMATION,
                              title: language.areYouSureYouWantToLogoutThisApp,
                              positiveText: language.yes,
                              negativeText: language.no, onAccept: (v) async {
                            await appStoreClient.setLoggedIn(true);
                            await Future.delayed(Duration(milliseconds: 500));
                            await logout();
                          });
                        },
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
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
        actions: [
          IconButton(
            onPressed: () {
              launchScreen(context, NotificationScreen(),
                  pageRouteAnimation: PageRouteAnimation.Slide);
            },
            icon: Icon(Ionicons.notifications_outline),
          ),
        ],
      ),
      body: sourceLocation != null
          ? Stack(
              children: [
                GoogleMap(
                  zoomControlsEnabled: true,
                  markers: markers.map((e) => e).toSet(),
                  liteModeEnabled: true,
                  polylines: _polyLines,
                  compassEnabled: true,
                  zoomGesturesEnabled: true,
                  mapType: MapType.terrain,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: sourceLocation,
                    zoom: cameraZoom,
                    tilt: cameraTilt,
                    bearing: cameraBearing,
                  ),
                ),
                SlidingUpPanel(
                  controller: _panelController,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(defaultRadius),
                      topRight: Radius.circular(defaultRadius)),
                  backdropColor: primaryColor,
                  color: Color(0xFFF8F8F8),
                  onPanelOpened: () {
                    setState(() {
                      isPanelOpen = true; // Panel is open
                    });
                  },
                  onPanelClosed: () {
                    setState(() {
                      isPanelOpen = false; // Panel is open
                    });
                  },
                  backdropTapClosesPanel: true,
                  minHeight: 130,
                  maxHeight: 200,
                  panel: !isSourcceDest
                      ? Column(
                          children: [
                            Center(
                              child: Container(
                                height: 35,
                                color: borderColor,
                                width: MediaQuery.of(context).size.width,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_panelController.isPanelOpen) {
                                        _panelController.close();
                                      } else {
                                        _panelController.open();
                                      }
                                    });
                                  },
                                  child: Icon(
                                    isPanelOpen
                                        ? Icons.keyboard_arrow_down
                                        : Icons.keyboard_arrow_up,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // First row with two dropdowns
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .white, // Background color
                                            borderRadius: BorderRadius.circular(
                                                1), // Rounded corners
                                          ),
                                          child: servicesList.length > 0
                                              ? DropdownButtonHideUnderline(
                                                  child:
                                                      DropdownButton<dynamic>(
                                                    value: dropdownValue1,
                                                    items: servicesList.map<
                                                        DropdownMenuItem<
                                                            dynamic>>((item) {
                                                      return DropdownMenuItem<
                                                          dynamic>(
                                                        value: item,
                                                        child: Row(
                                                          children: [
                                                            item.serviceImage
                                                                        .toString() !=
                                                                    'null'
                                                                ? commonCachedNetworkImage(
                                                                    item.serviceImage,
                                                                    width: 35,
                                                                    height: 35)
                                                                : Text('No'),
                                                            Text("  " +
                                                                item.name
                                                                    .toString()),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        dropdownValue1 =
                                                            newValue;
                                                        getSubServices(
                                                            dropdownValue1.id
                                                                .toString());
                                                      });
                                                    },
                                                  ),
                                                )
                                              : Text("Not Found"),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: dropdownValue1.toString() !=
                                                "null"
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: Colors
                                                      .white, // Background color
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          1), // Rounded corners
                                                ),
                                                child: subServiceList.length > 0
                                                    ? DropdownButtonHideUnderline(
                                                        child: DropdownButton<
                                                            dynamic>(
                                                          value: dropdownValue2,
                                                          items: subServiceList.map<
                                                                  DropdownMenuItem<
                                                                      dynamic>>(
                                                              (item) {
                                                            return DropdownMenuItem<
                                                                dynamic>(
                                                              value: item,
                                                              child: Row(
                                                                children: [
                                                                  Text(item.name
                                                                      .toString()),
                                                                ],
                                                              ),
                                                            );
                                                          }).toList(),
                                                          onChanged:
                                                              (newValue) {
                                                            setState(() {
                                                              dropdownValue2 =
                                                                  newValue;
                                                              //getSubServices(dropdownValue1.id.toString());
                                                            });
                                                          },
                                                        ),
                                                      )
                                                    : Container(
                                                        height: 45,
                                                        child: Center(
                                                            child: Text(
                                                                "Not found"))),
                                              )
                                            : Container(
                                                height: 45,
                                                child: Center(
                                                    child: Text("Not found"))),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),

                                  // Second row with one dropdown and a counter
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            _showBottomSheet(context);
                                          },
                                          child: Container(
                                            child: Center(
                                                child: Text(
                                                    goodsValueTxt.text.isEmpty
                                                        ? 'Goods value'
                                                        : goodsValueTxt.text)),
                                            height: 45,
                                            width: 55,
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .white, // Background color
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      1), // Rounded corners
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .white, // Background color
                                            borderRadius: BorderRadius.circular(
                                                1), // Rounded corners
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: loadTypes,
                                              iconEnabledColor: Colors.grey,
                                              iconDisabledColor: Colors.grey,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  loadTypes = newValue!;
                                                });
                                              },
                                              items: listLoadTypes.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(" " + value),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Third row with two dropdowns

                                  SizedBox(height: 16),

                                  // Last row with a button

                                  AppButtonWidget(
                                    width: MediaQuery.of(context).size.width,
                                    color: borderColor,
                                    text: "Pick Location",
                                    textStyle:
                                        boldTextStyle(color: Colors.white),
                                    onTap: () async {
                                      if (await checkPermission()) {
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(
                                                    defaultRadius),
                                                topRight: Radius.circular(
                                                    defaultRadius)),
                                          ),
                                          context: context,
                                          builder: (_) {
                                            return RiderWidget(
                                                title: sourceLocationTitle);
                                          },
                                        );
                                      }
                                      // getNearByDriverList(
                                      //     latLng: sourceLocation);
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(bottom: 16),
                                height: 5,
                                width: 70,
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius)),
                              ),
                            ),
                            Text(
                                language.whatWouldYouLikeToGo
                                    .capitalizeFirstLetter(),
                                style: primaryTextStyle()),
                            SizedBox(height: 16),
                            AppTextField(
                              autoFocus: false,
                              readOnly: true,
                              onTap: () async {
                                if (await checkPermission()) {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft:
                                              Radius.circular(defaultRadius),
                                          topRight:
                                              Radius.circular(defaultRadius)),
                                    ),
                                    context: context,
                                    builder: (_) {
                                      return RiderWidget(
                                          title: sourceLocationTitle);
                                    },
                                  );
                                }
                              },
                              textFieldType: TextFieldType.EMAIL,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Feather.search),
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: radius(),
                                    borderSide:
                                        BorderSide(color: dividerColor)),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: radius(),
                                    borderSide:
                                        BorderSide(color: dividerColor)),
                                border: OutlineInputBorder(
                                    borderRadius: radius(),
                                    borderSide:
                                        BorderSide(color: dividerColor)),
                                hintText: language.enterYourDestination,
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                ),
              ],
            )
          : loaderWidget(),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Goods Value',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context); // Close the bottom sheet
                      },
                    ),
                  ],
                ),
                Text("Please enter the values of products"),
                SizedBox(height: 10),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: goodsValueTxt,
                  decoration: InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                    alignment: Alignment.center,
                    child: AppButtonWidget(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      text: "DONE",
                      textColor: Colors.white,
                      color: borderColor,
                      width: MediaQuery.of(context).size.width,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
