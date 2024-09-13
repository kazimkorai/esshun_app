import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../main.dart';
import '../main.dart';
import '../utils/Extensions/app_common.dart';

class NoInternetScreen extends StatefulWidget {
  @override
  _NoInternetScreenState createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
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
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Feather.wifi_off, size: 100),
            SizedBox(height: 16),
            Text(language.yourInternetIsNotWorking, style: boldTextStyle(size: 20)),
          ],
        ),
      ),
    );
  }
}
