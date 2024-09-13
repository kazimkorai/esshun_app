import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../main.dart';
import '../main.dart';
import '../utils/Colors.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/ConformationDialog.dart';
import '../utils/Extensions/StringExtensions.dart';
import '../utils/Extensions/app_common.dart';
import '../../model/ContactNumberListModel.dart';
import '../../network/RestApis.dart';
import '../../utils/Common.dart';

class EmergencyContactScreen extends StatefulWidget {
  @override
  EmergencyContactScreenState createState() => EmergencyContactScreenState();
}

class EmergencyContactScreenState extends State<EmergencyContactScreen> {
  ScrollController scrollController = ScrollController();

  final FlutterContactPicker _contactPicker = new FlutterContactPicker();
  Contact? _contact;

  int page = 1;
  int currentPage = 1;
  int totalPage = 1;

  List<ContactModel> contactNumber = [];

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          currentPage++;

          appStoreClient.setLoading(true);
          setState(() {});
          init();
        }
      }
    });
    afterBuildCreated(() => appStoreClient.setLoading(true));
  }

  void init() async {
    appStoreClient.setLoading(true);
    await getSosList().then((value) {
      appStoreClient.setLoading(false);
      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;

      if (currentPage == 1) {
        contactNumber.clear();
      }
      contactNumber.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStoreClient.setLoading(false);

      log(error.toString());
    });
  }

  Future<void> addContact({String? name, String? contactNumber}) async {
    appStoreClient.setLoading(true);
    Map req = {
      "title": name,
      "contact_number": contactNumber,
    };
    await saveSOS(req).then((value) {
      appStoreClient.setLoading(false);
      init();
      toast(value.message);
    }).catchError((error) {
      appStoreClient.setLoading(false);
      log(error.toString());
    });
  }

  Future<void> delete({required int id}) async {
    appStoreClient.setLoading(true);
    await deleteSosList(id: id).then((value) {
      init();
      appStoreClient.setLoading(false);
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
        title: Text(language.emergencyContact, style: boldTextStyle(color: Colors.white)),
      ),
      body: Observer(builder: (context) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: contactNumber.length,
                itemBuilder: (_, index) {
                  return Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
                        child: Text(contactNumber[index].title![0], style: boldTextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contactNumber[index].title.validate(), style: boldTextStyle()),
                            SizedBox(height: 4),
                            Text(contactNumber[index].contactNumber.validate(), style: primaryTextStyle()),
                          ],
                        ),
                      ),
                      if(contactNumber[index].regionId ==null) inkWellWidget(
                        onTap: () async {
                          showConfirmDialogCustom(context, title: language.areYouSureYouWantDeleteThisNumber, positiveText: language.yes, negativeText: language.no, dialogType: DialogType.DELETE,
                              onAccept: (c) async {
                            await delete(id: contactNumber[index].id!);
                          }, primaryColor: primaryColor);
                        },
                        child: Icon(MaterialIcons.delete_outline),
                      )
                    ],
                  );
                },
                separatorBuilder: (_, index) {
                  return Divider();
                },
              ),
            ),
            Visibility(
              visible: appStoreClient.isLoading,
              child: loaderWidget(),
            ),
            !appStoreClient.isLoading && contactNumber.isEmpty ? emptyWidget() : SizedBox(),
          ],
        );
      }),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: AppButtonWidget(
          width: MediaQuery.of(context).size.width,
          text: language.addContact,
          textStyle: boldTextStyle(color: Colors.white),
          color: primaryColor,
          onTap: () async {
            Contact? contact = await _contactPicker.selectContact();
            setState(() {
              _contact = contact;
            });
            if (_contact != null) addContact(name: _contact!.fullName.validate(), contactNumber: _contact!.phoneNumbers!.first);
          },
        ),
      ),
    );
  }
}
