import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_driver/clients/screens/NewEstimateRideListWidget.dart';
import 'package:taxi_driver/clients/utils/Extensions/AppButtonWidget.dart';

import '../../model/ServiceModel.dart';
import '../../model/new_service_model.dart';
import '../../network/RestApis.dart';
import '../../utils/Extensions/app_common.dart';
import '../utils/Colors.dart';

class ServicesWidget extends StatefulWidget {
  //
  final LatLng sourceLatLog;
  final LatLng destinationLatLog;
  final String sourceTitle;
  final String destinationTitle;
  bool isCurrentRequest;
  final int? servicesId;
  final int? id;

  ServicesWidget({
    required this.sourceLatLog,
    required this.destinationLatLog,
    required this.sourceTitle,
    required this.destinationTitle,
    this.isCurrentRequest = false,
    this.servicesId,
    this.id,
  });

  @override
  _ServicesWidgetState createState() => _ServicesWidgetState();
}

class _ServicesWidgetState extends State<ServicesWidget> {
  bool isLoadingMain = false;
  bool isLoadingSublist = false;
  TextEditingController textEditingController = new TextEditingController();
  List<ListServicesModel> servicesList = [];
  List<ListServicesModel> subServiceList = [];
  dynamic dropdownValue2 = null;
  dynamic dropdownValue1 = null;

  List<String> goodsTypes = [
    'Food',
    'Building Materials',
    'Auto Parts',
    'Tools and Equipment',
    'Other',
  ];

  String? selectedGoodsType;
  bool isOtherSelected = false;

  // Google Map controller
  GoogleMapController? mapController;
  bool showListView = false;

  // Initial camera position
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco, adjust as needed
    zoom: 10,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() async {
    setState(() {
      isLoadingMain = true;
    });
    await getServicesRider().then((value) {
      servicesList.addAll(value);
      setState(() {
        servicesList = value;
        if (servicesList.isNotEmpty) {
          dropdownValue1 = servicesList[0];
          getSubServicesById(dropdownValue1.id.toString());
        }
      });
    });
    setState(() {
      isLoadingMain = false;
    });

  }
  int? selectedIndexSubcat; // Variable to hold the index of the selected item


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set the color of the back button to white
        ),
        title: Text(
          'Select Service',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Google Map widget

          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),

          Positioned(
            left: 10,
            right: 10,
            bottom: 0,
            child: Visibility(
              visible: servicesList.isNotEmpty,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8, top: 16),
                          height: 5,
                          width: 70,
                          decoration: BoxDecoration(
                            color: primaryColor, // primaryColor
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: subServiceList.asMap().entries.map((entry) {
                            int index = entry.key; // Get the index
                            var e = entry.value; // Get the item

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndexSubcat = index; // Update the selected index
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                margin: EdgeInsets.only(top: 16, left: 8, right: 8),
                                decoration: BoxDecoration(
                                  color: selectedIndexSubcat == index ? Colors.green[100] : Colors.white, // Change color based on selection
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    e.imageUrl != null
                                        ? Image.network(
                                      e.imageUrl.toString(),
                                      height: 50,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    )
                                        : Text("Image not found"),
                                    SizedBox(height: 8),
                                    Text(e.name.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor)),
                                    SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Capacity:',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                        SizedBox(width: 4),
                                        Text('${e.capacity} + 1',
                                            style: TextStyle(color: primaryColor)),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      ),
                      SizedBox(height: 12),
                      dropdownValue1.toString() == "null"
                          ? SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    showListView =
                                        !showListView; // Toggle ListView visibility
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          dropdownValue1 != null
                                              ? Image.network(
                                                  dropdownValue1.imageUrl
                                                      .toString(),
                                                  width: 32,
                                                  fit: BoxFit.cover,
                                                  height: 32,
                                                )
                                              : SizedBox.shrink(),
                                          Text("  " + dropdownValue1.name),
                                        ],
                                      ),
                                      SizedBox(width: 8.0),
                                      Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // Adjust alignment as needed
                          children: [
                            // First container
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _showBottomModalSheet(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  // Add padding inside the container
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    // Background color of the container
                                    borderRadius: BorderRadius.circular(12.0),
                                    // Rounded corners
                                    border: Border.all(
                                        color: Colors.grey,
                                        width: 1), // Grey border
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        textEditingController.text.isEmpty
                                            ? "Values"
                                            : textEditingController.text,
                                        // Text inside the first container
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Icon(Icons.keyboard_arrow_down)
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _showGoodsTypeBottomSheet(context, (String selectedType) {
                                    // Update the state in the parent widget
                                    setState(() {
                                      selectedGoodsType = selectedType;
                                    });
                                  });
                                },
                                child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(" " +
                                                    selectedGoodsType
                                                        .toString() ==
                                                "null"
                                            ? "Goods Type"
                                            : " " +
                                                selectedGoodsType.toString()),
                                        Icon(Icons.keyboard_arrow_down)
                                      ],
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          // Add padding inside the container
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // Background color of the container
                            borderRadius: BorderRadius.circular(12.0),
                            // Rounded corners
                            border: Border.all(
                                color: Colors.grey, width: 1), // Grey border
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment via',
                                // Text inside the first container
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.withOpacity(0.5)),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.payment,
                                    color: primaryColor,
                                    size: 32,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "Card payment",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text("  For instant payment")
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){

                          launchScreen(
                              context, NewEstimateRideListWidget(sourceLatLog: LatLng(23.6065715, 58.2252696), destinationLatLog: LatLng(23.60657,58.2352696), sourceTitle: widget.sourceTitle, destinationTitle: widget. destinationTitle),
                              pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(15),
                            // Add padding inside the container
                            decoration: BoxDecoration(
                              color: primaryColor,
                              // Background color of the container
                              borderRadius: BorderRadius.circular(12.0),
                              // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Book Now',
                                // Text inside the first container
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          showListView
              ? Positioned(
                  bottom: 250,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.white,
                      height: 350, // Set height for ListView
                      child: ListView.builder(
                        itemCount: servicesList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                showListView = false;
                                dropdownValue1 = servicesList[index];
                                getSubServices(dropdownValue1.id.toString());
                                // Trigger the bottom sheet when a service is tapped
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 70,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Image.network(
                                          servicesList[index].imageUrl,
                                          width: 70,
                                          fit: BoxFit.cover,
                                          height: 32,
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              servicesList[index].name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            Text(
                                              servicesList[index]
                                                  .commissionType,
                                              style: TextStyle(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),

          isLoadingSublist
              ? Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 200,
                  child: Center(
                    child: SizedBox(
                      height: 40, // Set the height
                      width: 40, // Set the width
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : SizedBox.shrink(),

          // Loading indicator
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 16),
                  height: 5,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.blue, // primaryColor
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Services",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black),
                ),
              ),
              Container(
                color: Colors.white,
                height: 350, // Set height for ListView
                child: ListView.builder(
                  itemCount: servicesList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          showListView = false;
                          dropdownValue1 = servicesList[index];
                          getSubServices(dropdownValue1.id.toString());
                          // Trigger the bottom sheet when a service is tapped
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 70,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Image.network(
                                    servicesList[index].imageUrl,
                                    width: 70,
                                    fit: BoxFit.cover,
                                    height: 32,
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        servicesList[index].name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        servicesList[index].commissionType,
                                        style: TextStyle(
                                            color: Colors.grey.withOpacity(0.5),
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getSubServices(String id) async {
    setState(() {
      isLoadingSublist = true;
    });
    subServiceList.clear();
    await getSubServicesByIdRider(id).then((value) {
      setState(() {
        subServiceList = value;
        // Optionally reset dropdownValue2 if needed
        dropdownValue2 =
            (subServiceList.isNotEmpty ? subServiceList[0] : null)!;
      });
    });
    setState(() {
      isLoadingSublist = false;
    });
  }

  void _showBottomModalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,
      // Ensures the keyboard doesn't overlap the modal
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            // Background color
            border: Border.all(color: Colors.grey),
            // Grey border for the container
            borderRadius:
                BorderRadius.circular(15), // Rounded corners for the container
          ),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom), // Adjust for the keyboard
            child: Column(
              children: [
                SizedBox(
                  height: 8,
                ),
                Text(
                  'Goods value',
                  style: TextStyle(
                      fontSize: 16,
                      color: primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8,
                ),
                Divider(
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(16),
                      // Padding inside the TextField
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        // Rounded corners for TextField
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(
                                0.5)), // Grey border when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        // Rounded corners for TextField when focused
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 2.0), // Blue border when focused
                      ),
                      hintText: 'Example: 5000 OM', // Placeholder text
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      "Note According to value of your products we will provide you insurance "),
                ),
                SizedBox(
                  height: 8,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(15),
                      // Add padding inside the container
                      decoration: BoxDecoration(
                        color: primaryColor,
                        // Background color of the container
                        borderRadius: BorderRadius.circular(12.0),
                        // Rounded corners
                      ),
                      child: Center(
                        child: Text(
                          'Book Now',
                          // Text inside the first container
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
// Function to show the bottom sheet and pass the selected value back to parent
  void _showGoodsTypeBottomSheet(BuildContext context, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        String selectedGoodsTypeInModal = selectedGoodsType.toString(); // Local variable to manage selection in the modal
        bool isOtherSelectedInModal = isOtherSelected;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Type of Goods',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: goodsTypes.map((String goodsType) {
                        return ListTile(
                          title: Text(
                            goodsType,
                            style: TextStyle(
                                color: selectedGoodsTypeInModal == goodsType
                                    ? Colors.green
                                    : Colors.black,
                                fontSize: 16),
                          ),
                          trailing: selectedGoodsTypeInModal == goodsType
                              ? Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            setState(() {
                              selectedGoodsTypeInModal = goodsType;
                              isOtherSelectedInModal = goodsType == 'Other';
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (isOtherSelectedInModal) ...[
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter other type of goods',
                          contentPadding: EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                    InkWell(
                      onTap: () {
                        // Pass the selected value back to the parent
                        onSelected(selectedGoodsTypeInModal);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            "Done",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Text color
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

}
