import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../utils/Extensions/app_common.dart';

class TermsConditionScreen extends StatefulWidget {
  final String? title;
  final String? subtitle;

  TermsConditionScreen({this.title, this.subtitle});

  @override
  TermsConditionScreenState createState() => TermsConditionScreenState();
}

class TermsConditionScreenState extends State<TermsConditionScreen> {
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
        ),
        title: Text(widget.title!, style: boldTextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: HtmlWidget("${widget.subtitle}"),
      ),
    );
  }
}
