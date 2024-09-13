import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';

import '../../main.dart';
import '../../utils/Common.dart';
import '../main.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import 'RiderDashBoardScreen.dart';

class LocationPermissionScreen extends StatefulWidget {
  @override
  LocationPermissionScreenState createState() => LocationPermissionScreenState();
}

class LocationPermissionScreenState extends State<LocationPermissionScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    determinePosition();
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
          ),automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('images/location-permissions.json', height: 200, width: 200, fit: BoxFit.cover),
              SizedBox(height: 32),
              Text(language.mostReliableeshhunRiderApp, style: boldTextStyle(size: 18)),
              SizedBox(height: 16),
              Text(language.toEnjoyYourRideExperiencePleaseAllowPermissions, style: secondaryTextStyle(color: primaryColor), textAlign: TextAlign.center),
              SizedBox(height: 32),
              AppButtonWidget(
                width: MediaQuery.of(context).size.width,
                text: language.allow,
                textStyle: boldTextStyle(color: Colors.white),
                color: primaryColor,
                onTap: () async {
                  if(await checkPermission()){
                    launchScreen(context, RiderDashBoardScreen(),isNewTask: true);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<Position?> determinePosition() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location Not Available');
    }
  } else {
    //throw Exception('Error');
  }
  return await Geolocator.getCurrentPosition();
}
