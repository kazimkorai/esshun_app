import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:taxi_driver/clients/screens/RiderDashBoardScreen.dart';
import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../main.dart';
import '../model/LocationModel.dart';
import '../screens/NewEstimateRideListWidget.dart';
import '../model/GoogleMapSearchModel.dart';
import '../model/ServiceModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import 'NewGoogleMapScreen.dart';

class RiderWidget extends StatefulWidget {
  final String title;

  RiderWidget({required this.title});

  @override
  RiderWidgetState createState() => RiderWidgetState();
}

class RiderWidgetState extends State<RiderWidget> {
  TextEditingController sourceLocation = TextEditingController();
  TextEditingController destinationLocation = TextEditingController();
  TextEditingController goodsValueTxt = TextEditingController();
  FocusNode sourceFocus = FocusNode();
  FocusNode desFocus = FocusNode();

  int selectedIndex = -1;
  String mLocation = "";
  bool isDone = true;
  bool isPickup = true;
  bool isDrop = false;
  double? totalAmount;
  double? subTotal;
  double? amount;
  List<ServiceList> servicesList = [];
  LocationModel? model;
  ServiceList? serviceList;

  List<ServiceList> list = [];
  List<Prediction> listAddress = [];

  List<ServiceList> subServiceList = [];
  List<String> listLoadTypes = [
    "Food",
    "Building Materials",
    "Autoparts",
    "Tools And Equipment",
    'Other'
  ];
  dynamic dropdownValue1;

  dynamic dropdownValue2;

  String dropdownValue3 = 'Goods Value';
  String loadTypes = 'Food';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    sourceLocation.text = widget.title;

    servicesList.clear;
    subServiceList.clear();

    await getServices().then((value) {
      list.addAll(value.data!);

      setState(() {
        setState(() {
          servicesList = value.data!;
        });
      });
    });

    sourceFocus.addListener(() {
      sourceLocation.selection =
          TextSelection.collapsed(offset: sourceLocation.text.length);
      if (sourceFocus.hasFocus) sourceLocation.clear();
    });

    desFocus.addListener(() {
      if (desFocus.hasFocus) {
        if (mLocation.isNotEmpty) {
          sourceLocation.text = mLocation;
          sourceLocation.selection =
              TextSelection.collapsed(offset: sourceLocation.text.length);
        } else {
          sourceLocation.text = widget.title;
          sourceLocation.selection =
              TextSelection.collapsed(offset: sourceLocation.text.length);
        }
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: MediaQuery
            .of(context)
            .viewInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
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
                          borderRadius: BorderRadius.circular(defaultRadius)),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.only(bottom: 16),
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(defaultRadius)),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Column(
                              children: [
                                Icon(Icons.near_me, color: Colors.green),
                                SizedBox(height: 4),
                                SizedBox(
                                  height: 60,
                                  child: DottedLine(
                                    direction: Axis.vertical,
                                    lineLength: double.infinity,
                                    lineThickness: 1,
                                    dashLength: 2,
                                    dashColor: primaryColor,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Icon(Icons.location_on, color: Colors.red),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  if (isPickup == true)
                                    Text(language.lblWhereAreYou,
                                        style: secondaryTextStyle()),
                                  TextFormField(
                                    controller: sourceLocation,
                                    focusNode: sourceFocus,
                                    decoration: InputDecoration(
                                        contentPadding:
                                        EdgeInsets.symmetric(vertical: 8),
                                        isDense: true,
                                        hintStyle: primaryTextStyle(),
                                        labelStyle: primaryTextStyle(),
                                        hintText: language.currentLocation),
                                    onTap: () {
                                      isPickup = false;
                                      setState(() {});
                                    },
                                    onChanged: (val) {
                                      if (val.isNotEmpty) {
                                        isPickup = true;
                                        if (val.length < 3) {
                                          isDone = false;
                                          listAddress.clear();
                                          setState(() {});
                                        } else {
                                          searchAddressRequest(search: val)
                                              .then((value) {
                                            isDone = true;
                                            listAddress = value.predictions!;
                                            setState(() {});
                                          }).catchError((error) {
                                            log(error);
                                          });
                                        }
                                      } else {
                                        isPickup = false;
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  SizedBox(height: 30),
                                  if (isDrop == true)
                                    Text(language.lblDropOff,
                                        style: secondaryTextStyle()),
                                  TextFormField(
                                    controller: destinationLocation,
                                    focusNode: desFocus,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                        contentPadding:
                                        EdgeInsets.symmetric(vertical: 8),
                                        isDense: true,
                                        hintStyle: primaryTextStyle(),
                                        labelStyle: primaryTextStyle(),
                                        hintText: language.destinationLocation),
                                    onTap: () {
                                      isDrop = false;
                                      setState(() {});
                                    },
                                    onChanged: (val) {
                                      if (val.isNotEmpty) {
                                        isDrop = true;
                                        if (val.length < 3) {
                                          listAddress.clear();
                                          setState(() {});
                                        } else {
                                          searchAddressRequest(search: val)
                                              .then((value) {
                                            listAddress = value.predictions!;
                                            setState(() {});
                                          }).catchError((error) {
                                            log(error);
                                          });
                                        }
                                      } else {
                                        isDrop = false;
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                  if (listAddress.isNotEmpty) SizedBox(height: 16),
                  ListView.builder(
                    controller: ScrollController(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: listAddress.length,
                    itemBuilder: (context, index) {
                      Prediction mData = listAddress[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.location_on_outlined,
                            color: primaryColor),
                        minLeadingWidth: 16,
                        title: Text(mData.description ?? "",
                            style: primaryTextStyle()),
                        onTap: () async {
                          await searchAddressRequestPlaceId(
                              placeId: mData.placeId)
                              .then((value) async {
                            var data = value.result!.geometry;
                            if (sourceFocus.hasFocus) {
                              isDone = true;
                              mLocation = mData.description!;
                              sourceLocation.text = mData.description!;
                              polylineSource = LatLng(
                                  data!.location!.lat!, data.location!.lng!);

                              if (sourceLocation.text.isNotEmpty &&
                                  destinationLocation.text.isNotEmpty) {
                                showBottomSheetType(context);
                                // launchScreen(
                                //     context, NewEstimateRideListWidget(sourceLatLog: polylineSource, destinationLatLog: polylineDestination, sourceTitle: sourceLocation.text, destinationTitle: destinationLocation.text),
                                //     pageRouteAnimation: PageRouteAnimation.SlideBottomTop);

                                // sourceLocation.clear();
                                // destinationLocation.clear();
                              }
                            } else if (desFocus.hasFocus) {
                              destinationLocation.text = mData.description!;
                              polylineDestination = LatLng(
                                  data!.location!.lat!, data.location!.lng!);
                              if (sourceLocation.text.isNotEmpty &&
                                  destinationLocation.text.isNotEmpty) {
                                showBottomSheetType(context);
                                // launchScreen(

                                //     context, NewEstimateRideListWidget(sourceLatLog: polylineSource, destinationLatLog: polylineDestination, sourceTitle: sourceLocation.text, destinationTitle: destinationLocation.text),
                                //     pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                                // sourceLocation.clear();
                                // destinationLocation.clear();
                              }
                            }
                            listAddress.clear();
                            setState(() {});
                          }).catchError((error) {
                            log(error);
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  AppButtonWidget(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    color: primaryColor,
                    onTap: () async {
                      if (sourceFocus.hasFocus) {
                        isDone = true;
                        PickResult selectedPlace = await launchScreen(
                            context, NewGoogleMapScreen(isDestination: false),
                            pageRouteAnimation:
                            PageRouteAnimation.SlideBottomTop);
                        log(selectedPlace);
                        mLocation = selectedPlace.formattedAddress!;
                        sourceLocation.text = selectedPlace.formattedAddress!;
                        polylineSource = LatLng(
                            selectedPlace.geometry!.location.lat,
                            selectedPlace.geometry!.location.lng);

                        if (sourceLocation.text.isNotEmpty &&
                            destinationLocation.text.isNotEmpty) {
                          log(sourceLocation.text);
                          log(destinationLocation.text);
                          showBottomSheetType(context);
                          // launchScreen(
                          //     context, NewEstimateRideListWidget(sourceLatLog: polylineSource, destinationLatLog: polylineDestination, sourceTitle: sourceLocation.text, destinationTitle: destinationLocation.text),
                          //     pageRouteAnimation: PageRouteAnimation.SlideBottomTop);

                          sourceLocation.clear();
                          destinationLocation.clear();
                        }
                      } else if (desFocus.hasFocus) {
                        PickResult selectedPlace = await launchScreen(
                            context, NewGoogleMapScreen(isDestination: true),
                            pageRouteAnimation:
                            PageRouteAnimation.SlideBottomTop);

                        destinationLocation.text =
                        selectedPlace.formattedAddress!;
                        polylineDestination = LatLng(
                            selectedPlace.geometry!.location.lat,
                            selectedPlace.geometry!.location.lng);

                        if (sourceLocation.text.isNotEmpty && destinationLocation.text.isNotEmpty) {
                          log(sourceLocation.text);
                          log(destinationLocation.text);
                          showBottomSheetType(context);

                        }
                      } else {
                        //
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.my_location_sharp, color: Colors.white),
                        SizedBox(width: 16),
                        Text(language.chooseOnMap,
                            style: boldTextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getSubServices(String id) async {
    subServiceList.clear();
    await getSubServicesById(id).then((value) {
      setState(() {
        subServiceList = value.data!;
        // Optionally reset dropdownValue2 if needed
        dropdownValue2 = subServiceList.isNotEmpty ? subServiceList[0] : null;
      });
    });
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

  void showBottomSheetType(BuildContext context) {
    bool loading = false; // Add loading state
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Set default values for the dropdowns if available
            if (servicesList.isNotEmpty && dropdownValue1 == null) {
              setModalState(() {
                dropdownValue1 = servicesList.length > 1 ? servicesList[1] : servicesList[0];
                // Show progress indicator while fetching subservices
                loading = true;
                getSubServices(dropdownValue1.id.toString()).then((_) {
                  setModalState(() {
                    dropdownValue2 = subServiceList.length > 1
                        ? subServiceList[1]
                        : subServiceList.isNotEmpty
                        ? subServiceList[0]
                        : null;
                    loading = false; // Hide progress indicator once done
                  });
                });
              });
            }

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Show loading indicator
                Column(
                    children: [
                      // First row with two dropdowns
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1),
                              ),
                              child: servicesList.isNotEmpty
                                  ? DropdownButtonHideUnderline(
                                child: DropdownButton<dynamic>(
                                  value: dropdownValue1,
                                  items: servicesList
                                      .map<DropdownMenuItem<dynamic>>(
                                          (item) {
                                        return DropdownMenuItem<dynamic>(
                                          value: item,
                                          child: Row(
                                            children: [
                                              item.serviceImage.toString() !=
                                                  'null'
                                                  ? Image.network(
                                                item.serviceImage
                                                    .toString(),
                                                width: 35,
                                                height: 35,
                                              )
                                                  : Text('No Image'),
                                              SizedBox(width: 8),
                                              Text(item.name.toString()),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (newValue) {
                                    setModalState(() {
                                      dropdownValue1 = newValue;
                                      loading = true; // Start loading
                                    });
                                    getSubServices(dropdownValue1.id
                                        .toString())
                                        .then((_) {
                                      setModalState(() {
                                        dropdownValue2 =
                                        subServiceList.length > 1
                                            ? subServiceList[1]
                                            : subServiceList
                                            .isNotEmpty
                                            ? subServiceList[0]
                                            : null;
                                        loading = false; // Stop loading
                                      });
                                    });
                                  },
                                ),
                              )
                                  : Center(child: Text("Not Found")),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: dropdownValue1 != null
                                ? Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(1),
                              ),
                              child: subServiceList.isNotEmpty
                                  ?  DropdownButtonHideUnderline(
                                child: DropdownButton<dynamic>(
                                  value: dropdownValue2,
                                  items: subServiceList.map<
                                      DropdownMenuItem<
                                          dynamic>>((item) {
                                    return DropdownMenuItem<
                                        dynamic>(
                                      value: item,
                                      child: Text(
                                          item.name.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setModalState(() {
                                      dropdownValue2 = newValue;
                                    });
                                  },
                                ),
                              )
                                  : Container(
                                height: 45,
                                child:  loading
                                    ? Center(
                                  child: CircularProgressIndicator(),
                                )
                                    :  Center(
                                    child: Text("Not found")),
                              ),
                            )
                                : Container(
                              height: 45,
                              child: Center(child: Text("Not found")),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Second row with a dropdown and counter
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: loadTypes,
                                  onChanged: (String? newValue) {
                                    setModalState(() {
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
                      SizedBox(height: 16),
                      AppButtonWidget(
                        width: MediaQuery.of(context).size.width,
                        color: borderColor,
                        text: "Go Next",
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        onTap: () {

                          launchScreen(
                              context, NewEstimateRideListWidget(sourceLatLog: polylineSource, destinationLatLog: polylineDestination, sourceTitle: sourceLocation.text, destinationTitle: destinationLocation.text),
                              pageRouteAnimation: PageRouteAnimation.SlideBottomTop);

                          sourceLocation.clear();
                          destinationLocation.clear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



}
