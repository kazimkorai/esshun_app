import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_driver/clients/screens/ChatScreen.dart';
import 'package:taxi_driver/clients/service/ChatMessagesService.dart';
import 'package:taxi_driver/clients/store/AppStore.dart';
import 'package:taxi_driver/network/RestApis.dart';
import 'package:taxi_driver/screens/ChatScreen.dart';
import 'package:taxi_driver/screens/SplashScreen.dart';

import 'package:taxi_driver/utils/Colors.dart';
import 'package:taxi_driver/utils/Common.dart';
import 'package:taxi_driver/utils/Constants.dart';
import 'package:taxi_driver/utils/DataProvider.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';

import 'AppTheme.dart';
import 'Services/ChatMessagesService.dart';
import 'Services/NotificationService.dart';
import 'Services/UserServices.dart';


import 'firebase_options.dart';
import 'language/AppLocalizations.dart';
import 'language/BaseLanguage.dart';
import 'model/FileModel.dart';
import 'model/LanguageDataModel.dart';
import 'screens/NoInternetScreen.dart';
import 'utils/Extensions/app_common.dart';


late SharedPreferences sharedPref;
Color textPrimaryColorGlobal = textPrimaryColor;
Color textSecondaryColorGlobal = textSecondaryColor;
Color defaultLoaderBgColorGlobal = Colors.white;
List<LanguageDataModel> localeLanguageList = [];
LanguageDataModel? selectedLanguageDataModel;
late BaseLanguage language;
bool isCurrentlyOnNoInternet = false;
AppStoreClient appStoreClient = AppStoreClient();
LatLng polylineSource = LatLng(0.00, 0.00);
late List<FileModel> fileList = [];
bool mIsEnterKey = false;
String mSelectedImage = "assets/default_wallpaper.png";
LatLng polylineDestination = LatLng(0.00, 0.00);
ChatMessageServiceClient chatMessageService = ChatMessageServiceClient();
NotificationService notificationService = NotificationService();
UserService userService = UserService();

final navigatorKey = GlobalKey<NavigatorState>();

get getContext => navigatorKey.currentState?.overlay?.context;
late LocationPermission locationPermissionHandle;

Future<void> initialize({
  double? defaultDialogBorderRadius,
  List<LanguageDataModel>? aLocaleLanguageList,
  String? defaultLanguage,
}) async {
  localeLanguageList = aLocaleLanguageList ?? [];
  selectedLanguageDataModel =
      getSelectedLanguageModel(defaultLanguage: default_Language);
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  try {
//
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
///
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance
    // Your personal reCaptcha public key goes here:
        .activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,

    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  sharedPref = await SharedPreferences.getInstance();
  await initialize(aLocaleLanguageList: languageList());
  appStoreClient.setLanguage(default_Language);

  await appStoreClient.setLoggedIn(sharedPref.getBool(IS_LOGGED_IN) ?? false,
      isInitializing: true);
  // await appStoreClient.setUserId(int.parse(sharedPref.getString(USER_ID).toString())=="null"?0:int.parse(sharedPref.getString(USER_ID).toString()),
  //     isInitializing: true);
  await appStoreClient.setUserEmail(sharedPref.getString(USER_EMAIL).validate(),
      isInitialization: true);
  await appStoreClient
      .setUserProfile(sharedPref.getString(USER_PROFILE_PHOTO).validate());

  await OneSignal.shared.setAppId(mOneSignalAppIdDriver);
  OneSignal.shared.consentGranted(true);
  saveOneSignalPlayerId();
  OneSignal.shared.promptUserForPushNotificationPermission();
  OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) {
    event.complete(event.notification);
  });
  if (appStoreClient.isLoggedIn) {
    getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) async {
      if (value.data!.playerId == null || value.data!.playerId!.isEmpty) {
        updatePlayerId();
      }
    });
  }

  runApp(const MyApp());
}

Future<void> updatePlayerId() async {
  Map req = {
    "player_id": sharedPref.getString(PLAYER_ID),
  };
  updateStatus(req).then((value) {
    //
  }).catchError((error) {
    //
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
    connectivitySubscription.cancel();
  }

  void init() async {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((e) {
      if (e == ConnectivityResult.none) {
        log('not connected');
        isCurrentlyOnNoInternet = true;
        launchScreen(
            navigatorKey.currentState!.overlay!.context, NoInternetScreen());
      } else {
        if (isCurrentlyOnNoInternet) {
          Navigator.pop(navigatorKey.currentState!.overlay!.context);
          isCurrentlyOnNoInternet = false;
          toast('Internet is connected.');
        }
        log('connected');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'eshhun Driver',
        theme: AppTheme.lightTheme,

        builder: (context, child) {
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: child!,
          );
        },
        home: SplashScreen(),
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale:
            Locale(appStoreClient.selectedLanguage.validate(value: default_Language)),
      );
    });
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
