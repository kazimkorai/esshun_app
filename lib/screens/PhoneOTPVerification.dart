import 'package:flutter/material.dart';
import 'package:taxi_driver/screens/DriverRegisterScreen.dart';
import 'package:taxi_driver/utils/Colors.dart';

import '../clients/network/RestApis.dart';
import '../clients/utils/Extensions/app_common.dart';

class OTPVerificationDriver extends StatefulWidget {
  String phoneNo;

  OTPVerificationDriver(this.phoneNo);
  @override
  _OTPVerificationDriverState createState() => _OTPVerificationDriverState();
}

class _OTPVerificationDriverState extends State<OTPVerificationDriver> {
  TextEditingController otpController1 = TextEditingController();
  TextEditingController otpController2 = TextEditingController();
  TextEditingController otpController3 = TextEditingController();
  TextEditingController otpController4 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xfff7f6fb),
        body: Column(
          children: [
            Container(
                height: 300,
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
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.pop(context,true);

                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "    Verification",
                          style: TextStyle(color: Colors.white,fontSize: 18),
                        ),
                        Text('')
                      ],
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
                                "  Customer",
                                style:
                                TextStyle(color: Colors.white, fontSize: 18),
                              ),
                              Text(
                                "  Verification",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5,top: 4),
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
            SizedBox(
              height: 24,
            ),
            Text(
              'Verification',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Enter your OTP code number",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 28,
            ),
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _textFieldOTP(first: true, last: false,controller: otpController1),
                      _textFieldOTP(first: false, last: false,controller: otpController2),
                      _textFieldOTP(first: false, last: false,controller: otpController3),
                      _textFieldOTP(first: false, last: true,controller: otpController4),
                    ],
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          String otp = otpController1.text +
                              otpController2.text +
                              otpController3.text +
                              otpController4.text;
                          print(otp);
                          print("OTP Entered: $otp");
                          Map<String, dynamic> mapData = {};
                          mapData['user_type']="driver";
                          mapData['contact_number'] = widget.phoneNo.toString();
                          mapData["otp"]=otpController1.text +
                              otpController2.text +
                              otpController3.text +
                              otpController4.text;
                          otpVerify(mapData,context,true);
                        });


                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => CustomerDa()),
                        // );
                      },
                      style: ButtonStyle(
                        foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                        MaterialStateProperty.all<Color>(    Color.fromRGBO(0, 52, 111, 1),),
                        shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Text(
                          'Verify',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 18,
            ),
            Text(
              "Didn't you receive any code?",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 18,
            ),
            Text(
              "Resend New Code",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColorD,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _textFieldOTP({required bool first, last,   required TextEditingController controller,}) {
    return Container(
      height: 85,
      width: 65,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: TextField(
          autofocus: true,
          controller: controller,
          onChanged: (value) {
            if (value.length == 1 && last == false) {
              FocusScope.of(context).nextFocus();
            }
            if (value.length == 0 && first == false) {
              FocusScope.of(context).previousFocus();
            }
          },
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            counter: Offstage(),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.black12),
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: primaryColorD),
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

class OtpRegisterDriver extends StatefulWidget {

  @override
  _OtpRegisterDriverState createState() => _OtpRegisterDriverState();
}

class _OtpRegisterDriverState extends State<OtpRegisterDriver> {
  TextEditingController txtPhoneNo=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
                height: 300,
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
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: (){

                            Navigator.pop(context,true);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "    Register",
                          style: TextStyle(color: Colors.white,fontSize: 18),
                        ),
                        Text('')
                      ],
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
                                "  Customer",
                                style:
                                TextStyle(color: Colors.white, fontSize: 18),
                              ),
                              Text(
                                "  Registration",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5,top: 4),
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
            SizedBox(
              height: 33,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Add your phone number. we'll send you a verification code so we know you're real",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 28,
            ),
            Container(
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    controller: txtPhoneNo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10)),
                      prefix: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '(+968)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      suffixIcon: Icon(
                        Icons.check_circle,
                        color: primaryColorD,
                        size: 32,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if(txtPhoneNo.value.text.length==8){
                          Map<String, dynamic> mapData = {};
                          mapData['contact_number'] = txtPhoneNo.value.text.toString();

                          loginWithOtp(mapData,context,true);
                        }
                        else{
                          toast("Please add a valid phone number");
                        }
                      },
                      style: ButtonStyle(
                        foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Color.fromRGBO(0, 52, 111, 1),),
                        shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Text(
                          'Send',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
