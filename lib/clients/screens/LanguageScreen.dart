import 'package:flutter/material.dart';
import '../../model/LanguageDataModel.dart';
import '../../utils/Constants.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/app_common.dart';
import '../model/LanguageDataModel.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/LiveStream.dart';

class LanguageScreen extends StatefulWidget {
  @override
  LanguageScreenState createState() => LanguageScreenState();
}

class LanguageScreenState extends State<LanguageScreen> {
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
        title: Text(language.language, style: boldTextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: List.generate(localeLanguageList.length, (index) {
          LanguageDataModel data = localeLanguageList[index];
          return inkWellWidget(
            onTap: () async {
              await sharedPref.setString(SELECTED_LANGUAGE_CODE, data.languageCode!);
              selectedLanguageDataModel = data;
              appStoreClient.setLanguage(data.languageCode!, context: context);
              setState(() {});
              LiveStream().emit(CHANGE_LANGUAGE);
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.asset(data.flag.validate(), width: 34),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${data.name.validate()}', style: boldTextStyle()),
                        SizedBox(height: 8),
                        Text('${data.subTitle.validate()}', style: secondaryTextStyle()),
                      ],
                    ),
                  ),
                  if ((sharedPref.getString(SELECTED_LANGUAGE_CODE) ?? default_Language) == data.languageCode) Icon(Icons.check_circle, color: primaryColor),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
