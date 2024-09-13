import 'package:flutter/material.dart';

import '../components/EarningReportWidget.dart';
import '../components/EarningTodayWidget.dart';
import '../components/EarningWeekWidget.dart';
import '../main.dart';
import '../model/EarningListModelWeek.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Extensions/app_common.dart';

class EarningScreen extends StatefulWidget {
  @override
  EarningScreenState createState() => EarningScreenState();
}

class EarningScreenState extends State<EarningScreen> {
  EarningListModelWeek? earningListModelWeek;
  List<WeekReport> weekReport = [];

  num totalRideCount = 0;
  num totalCashRide = 0;
  num totalWalletRide = 0;
  num totalCardRide = 0;
  num totalEarnings = 0;

  @override
  void initState() {
    super.initState();
    // init();
  }

  void init() async {
    appStoreClient.setLoading(true);
    Map req = {
      "type": "week",
    };
    await earningList(req: req).then((value) {
      appStoreClient.setLoading(false);
      totalRideCount = value.totalRideCount!;
      totalCashRide = value.totalCashRide!;
      totalWalletRide = value.totalWalletRide!;
      totalCardRide = value.totalCardRide!;
      totalEarnings = value.totalEarnings!;

      weekReport.addAll(value.weekReport!);
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(

        appBar: AppBar(
          leading: IconButton( // Adds a back button
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back when pressed
            },
          ),
          title: Text(language.earning.toString(),
              style: boldTextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            Container(
              height: 40,
              margin: EdgeInsets.only(right: 16, left: 16, top: 16),
              decoration: BoxDecoration(
                color: dividerColor,
                borderRadius: radius(),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: radius(),
                  color: primaryColorD,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: primaryColorD,
                labelStyle: boldTextStyle(color: Colors.white, size: 14),
                tabs: [
                  Text("today"),
                  Text("weekly"),
                  Text("report"),
                ],
              ),
            ),
            Expanded( // Fixes the TabBarView error
              child: TabBarView(
                children: [
                  EarningTodayWidget(),
                  EarningWeekWidget(),
                  EarningReportWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}
