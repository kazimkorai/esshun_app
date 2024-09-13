import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:taxi_driver/clients/screens/PhoneOTPVerificationClient.dart';
import 'package:taxi_driver/clients/utils/Colors.dart';

import 'package:taxi_driver/screens/LoginScreenDriver.dart';
import 'package:taxi_driver/screens/PhoneOTPVerification.dart';
import 'package:taxi_driver/utils/Colors.dart';

import 'clients/screens/LoginScreenClient.dart';
import 'clients/utils/Extensions/AppButtonWidget.dart';
import 'clients/utils/Extensions/app_common.dart';
import 'main.dart';

class LoginOptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
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
                                "  Welcome",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "  Eshhun App",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
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
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 33,
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '  Choose Your Favorite',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OtpRegisterClient()),
                      );
                    },
                    child: Container(
                      height: 150,
                      width: MediaQuery.of(context).size.width / 2 - 10,
                      padding: EdgeInsets.all(2),
                      // Border width
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(0, 52, 111, 1),
                            // rgba(0, 52, 111, 1)
                            Color.fromRGBO(0, 112, 90, 1),
                            // rgba(0, 112, 90, 1)
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10), // Content padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Background color of the content
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'images/transport.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "Customer",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text("Customer Trip Package")
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      print('*OtpRegisterDriver clicked');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OtpRegisterDriver()),
                      );

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => LoginDriverScreen()),
                      // );
                    },
                    child: Container(
                      height: 150,
                      width: MediaQuery.of(context).size.width / 2 - 10,
                      padding: EdgeInsets.all(2),
                      // Border width
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(0, 52, 111, 1),
                            // rgba(0, 52, 111, 1)
                            Color.fromRGBO(0, 112, 90, 1),
                            // rgba(0, 112, 90, 1)
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10), // Content padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Background color of the content
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/driver.png',
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Driver',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Rent truck',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
