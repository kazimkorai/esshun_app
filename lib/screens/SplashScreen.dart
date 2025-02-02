import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_driver/login_option_screen.dart';
import 'package:taxi_driver/screens/DriverDashboardScreen.dart';

import '../clients/screens/RiderDashBoardScreen.dart';
import '../clients/screens/WalkThroughtScreen.dart';
import '../main.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import 'LoginScreenDriver.dart';
import 'VerifyDeliveryPersonScreen.dart';
import 'WalkThroughtScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();


    checkLoginStatus(context);
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userRole = prefs.getString('user_role');

    if (userRole == 'client') {
      launchScreen(context, RiderDashBoardScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
    } else if (userRole == 'driver') {
      init();
    } else {
      launchScreen(context, LoginOptionScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
    }
  }


  void init() async {
    await driverDetail();
    await Future.delayed(Duration(seconds: 2));
    if (sharedPref.getBool(IS_FIRST_TIME) ?? true) {
      launchScreen(context, WalkThroughtScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
    } else {
      if (sharedPref.getInt(IS_Verified_Driver) == 0 && appStoreClient.isLoggedIn) {
        launchScreen(context, DriverDashboardScreen(), pageRouteAnimation: PageRouteAnimation.SlideBottomTop, isNewTask: true);

        // launchScreen(context, VerifyDeliveryPersonScreen(isShow: true), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      } else if (sharedPref.getInt(IS_Verified_Driver) == 1 && appStoreClient.isLoggedIn) {
        launchScreen(context, DriverDashboardScreen(), pageRouteAnimation: PageRouteAnimation.SlideBottomTop, isNewTask: true);
      } else {
        launchScreen(context, LoginOptionScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      }
    }
  }

  Future<void> driverDetail() async {
    if (appStoreClient.isLoggedIn) {
      await getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) {
        if (value.data!.status == REJECT || value.data!.status == BANNED) {
          toast('${language.yourAccountIs} ${value.data!.status}. ${language.pleaseContactSystemAdministrator}');
          logout();
        }
      }).catchError((error) {
        //
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
      backgroundColor: primaryColorD,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/ic_driver_white.png', fit: BoxFit.contain, height: 150, width: 150),
            SizedBox(height: 16),
            Text(language.appName, style: boldTextStyle(color: Colors.white, size: 22)),
          ],
        ),
      ),
    );
  }
}
