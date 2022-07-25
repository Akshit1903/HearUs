import 'package:HearUs/screens/connectMentor.dart';
import 'package:HearUs/screens/dialScreen/components/rounded_button.dart';
import 'package:HearUs/screens/home.dart';
import 'package:HearUs/screens/listeners.dart';
import 'package:HearUs/screens/mentorFirstScreen.dart';
import 'package:HearUs/services/auth.dart';
import 'package:HearUs/style/colors.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/style/newFonts.dart';
import 'package:HearUs/util/modals.dart';
import 'package:HearUs/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentRazorpay extends StatefulWidget {
  final DataFromSharedPref userData;
  final DocumentSnapshot ds;
  final int amount;
  final String paymentfor;
  PaymentRazorpay({this.userData, this.ds, this.amount, this.paymentfor});
  @override
  _PaymentRazorpayState createState() => _PaymentRazorpayState();
}

class _PaymentRazorpayState extends State<PaymentRazorpay> {
  int _modeSelected = -1;
  Razorpay razorpay;
  @override
  void initState() {
    super.initState();
    razorpay = new Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);

    subscription = (widget.amount == 199)
        ? "1 month"
        : (widget.amount == 499)
            ? "3 months"
            : "5 months";

    if (!widget.paymentfor.contains('Mentor')) {
      timeList = createList();
    }
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  List<String> timeList;

  void openCheckout() {
    int finalAmount = (widget.paymentfor.contains('Mentor'))
        ? widget.amount * 100
        : amountSel * 100;
    var options = {
      "key": "rzp_live_dUcIwO9v2WXoKB",
      "description": widget.paymentfor.contains('Mentor')
          ? "Payment for : ${widget.paymentfor} \nAmount : $finalAmount \nPayment by user: ${widget.userData.myUsername}\nUserId: ${widget.userData.myUserId} \nUser Email id : ${widget.userData.myEmail}"
          : "Payment for : ${widget.paymentfor} \nAmount : $finalAmount \nPayment by user: ${widget.userData.myUsername}\nUserId: ${widget.userData.myUserId} \nUser Email id : ${widget.userData.myEmail} \nAppointment Date and Time with psychologist(if applicable): $dateTimePsycho $dropdownValue",
      "amount": finalAmount,
      "prefill": {
        "email": '${widget.userData.myEmail}',
        "contact": '',
      },
    };
    try {
      razorpay.open(options);
      print('${options.toString()}');
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(
          msg: '${e.toString()}',
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    print("payment Success : $response");
    Fluttertoast.showToast(
        msg:
            "Payment Successful! \nThanks for choosing us \n Your payment id: ${response.paymentId}",
        textColor: Colors.white,
        backgroundColor: Colors.black);
    if (widget.paymentfor.contains('Mentor')) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              settings: RouteSettings(name: 'ConnectMentor'),
              builder: (context) => ConnectMentor(
                    tag: widget.paymentfor.replaceAll(" Mentor", ""),
                    userData: widget.userData,
                    subscription: subscription,
                  )),
          (route) => false);
      print(
          'The tag selected is ${widget.paymentfor.replaceAll(" Mentor", "")}');
    } else if (widget.paymentfor == 'MoreListeners') {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              settings: RouteSettings(name: "ListenersPage"),
              builder: (context) => ListenersPage(
                    userData: widget.userData,
                  )),
          (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              settings: RouteSettings(name: "HomePage"),
              builder: (context) => HomePage(
                    userData: widget.userData,
                    auth: AuthMethods().authMethods,
                  )),
          (route) => false);
    }
  }

  void handlePaymentError() {
    print("payment error");
    Fluttertoast.showToast(
        msg: "Payment ERROR! ${Razorpay.EVENT_PAYMENT_ERROR.toString}",
        textColor: Colors.white,
        backgroundColor: Colors.red);
    if (widget.paymentfor.contains('Mentor')) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              settings: RouteSettings(name: 'MentorFirstScreen'),
              builder: (context) => MentorFirstScreen(
                    userData: widget.userData,
                  )),
          (route) => false);
      print(
          'The tag selected is ${widget.paymentfor.replaceAll(" Mentor", "")}');
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              settings: RouteSettings(name: "HomePage"),
              builder: (context) => HomePage(
                    userData: widget.userData,
                    auth: AuthMethods().authMethods,
                  )),
          (route) => false);
    }
  }

  void handleExternalWallet() {
    print("external wallet");
  }

  String time24to12(int time) {
    if (time < 12)
      return '${time.toString()}: 00 AM';
    else if (time == 12)
      return '12: 00 PM';
    else if (time > 12) return '${(time - 12).toString()}: 00 PM';
  }

  int amountSel = 349;
  String subscription = '';
  String dateTimePsycho = 'NA';
  int selectedSession;
  String psychoSession;
  Widget sessionButton(String session, int price, int i) {
    bool selected = false;
    if (selectedSession == i) {
      selected = true;
    } else
      selected = false;
    return Container(
      child: InkWell(
        onTap: () {
          setState(() {
            psychoSession = session;
            selectedSession = i;
            amountSel = price;
          });
          print("selected session is $psychoSession");
          print("selected duration Integer is $selectedSession");
          print("selected price is $amountSel");
          Fluttertoast.showToast(msg: 'Session Booked : $psychoSession');
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: (MediaQuery.of(context).size.width - 30) * 0.5,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: (selected)
                  ? AppColor().buttonColor
                  : AppColor().mainBackColor),
          child: Text(
            "$session        Rs.${price.toString()}",
            style: AppTextStyle().bodyStyleWhite,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String dropdownValue;
  List<String> createList() {
    int time = widget.ds['availTime']['start'];
    List<String> timeList = [];
    dropdownValue = '${time24to12(widget.ds['availTime']['start'])}';
    while (time != widget.ds['availTime']['end']) {
      timeList.add(time24to12(time++));
    }
    return timeList;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    Future<void> dialogEnterDetails([String msg = ""]) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(msg == "" ? 'Please enter all details' : msg),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OKAY'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          "Payment Gateway",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: (widget.paymentfor.contains('Mentor'))
          ? Stack(
              children: <Widget>[
                Container(
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                ),
                Center(
                  child: Container(
                    height: size.height * 0.9,
                    child: ListView(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          width: size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Appointment Details',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle().headingStyle),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Mentor required for :    ${widget.paymentfor}',
                            style: AppTextStyle().psychoListHeadStyle,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Subscription duration :    $subscription',
                            style: AppTextStyle().psychoListHeadStyle,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Payable amount :    Rs. ${widget.amount}',
                            style: AppTextStyle().psychoListHeadStyle,
                          ),
                        ),
                        // Container(
                        //   padding: EdgeInsets.all(10),
                        //   child: Text(
                        //     'Your Email ID :    ${widget.userData.myEmail}',
                        //     style: AppTextStyle().psychoListHeadStyle,
                        //   ),
                        // ),
                        // Container(
                        //   padding: EdgeInsets.all(10),
                        //   child: Text(
                        //     'Contact Hear Us :    info@hearus.me',
                        //     style: AppTextStyle().psychoListHeadStyle,
                        //   ),
                        // ),
                        SizedBox(
                          height: size.height * 0.25,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: button1(
                            "CONFIRM AND PAY",
                            AppColor().buttonColor,
                            context,
                            () {
                              openCheckout();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          : (widget.paymentfor == 'MoreListeners')
              ? Stack(
                  children: <Widget>[
                    Container(
                      height: size.height,
                      width: size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                    ),
                    SingleChildScrollView(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 5),
                              margin: EdgeInsets.only(top: 20),
                              decoration: BoxDecoration(),
                              child: Row(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      // borderRadius: BorderRadius.all(Radius.circular(15)),
                                      color: AppColor()
                                          .gradientLeftColor
                                          .withOpacity(0.3),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          widget.ds["imgUrl"],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.55,
                                        child: Text(
                                          widget.ds["name"],
                                          style: AppTextStyle()
                                              .psychoListHeadStyle,
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.55,
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          widget.ds['subProfile'],
                                          style: NewAppTextStyle()
                                              .psychoIntrobodyStyle,
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.55,
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          widget.ds['address'],
                                          style: NewAppTextStyle()
                                              .psychoIntrobodyStyle,
                                        ),
                                      ),
                                      Container(
                                        width: 150,
                                        child: Stack(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(top: 10),
                                              width: 100,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  for (int i = 1;
                                                      i <= widget.ds['rate'];
                                                      i++)
                                                    Icon(
                                                      Icons.star,
                                                      color: Color(0xFF000000),
                                                      size: 20,
                                                    ),
                                                  for (int j = 1;
                                                      j <=
                                                          5 - widget.ds['rate'];
                                                      j++)
                                                    Icon(
                                                      Icons
                                                          .star_border_outlined,
                                                      color: Color(0xFF000000),
                                                      size: 20,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              width: size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Appointment Details',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyle().headingStyle),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Payment for :    Chatting with more listeners',
                                style: AppTextStyle().psychoListHeadStyle,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Subscription duration :    Lifetime',
                                style: AppTextStyle().psychoListHeadStyle,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Payable amount :    Rs. ${widget.amount}',
                                style: AppTextStyle().psychoListHeadStyle,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Your Email ID :    ${widget.userData.myEmail}',
                                style: AppTextStyle().psychoListHeadStyle,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Contact Hear Us :    info@hearus.me',
                                style: AppTextStyle().psychoListHeadStyle,
                              ),
                            ),
                            // Container(
                            //   height: size.height * 0.10,
                            //   width: size.width,
                            //   child: Expanded(
                            //     child: Row(
                            //       children: [
                            //         Text("hello"),
                            //         // RoundedButton(
                            //         //     iconSrc: "assets/icons/call_end.svg",
                            //         //     press: () {}),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            SizedBox(
                              height: size.height * 0.25,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: button1(
                                "CONFIRM AND PAY",
                                AppColor().buttonColor,
                                context,
                                () {
                                  openCheckout();
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: <Widget>[
                    Container(
                      height: size.height,
                      width: size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                    ),
                    Column(
                      children: [
                        SingleChildScrollView(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(16),
                                  margin: EdgeInsets.only(top: 20),
                                  decoration: BoxDecoration(),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          // borderRadius: BorderRadius.all(Radius.circular(15)),
                                          color: AppColor()
                                              .gradientLeftColor
                                              .withOpacity(0.3),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              widget.ds["imgUrl"],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            child: Text(
                                              widget.ds["name"],
                                              style: AppTextStyle()
                                                  .psychoListHeadStyle,
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              widget.ds['subProfile'],
                                              style: NewAppTextStyle()
                                                  .psychoIntrobodyStyle,
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Text(
                                              widget.ds['address'],
                                              style: NewAppTextStyle()
                                                  .psychoIntrobodyStyle,
                                            ),
                                          ),
                                          Container(
                                            width: 150,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(top: 10),
                                                  width: 100,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: <Widget>[
                                                      for (int i = 1;
                                                          i <=
                                                              widget.ds['rate'];
                                                          i++)
                                                        Icon(
                                                          Icons.star,
                                                          color:
                                                              Color(0xFF000000),
                                                          size: 20,
                                                        ),
                                                      for (int j = 1;
                                                          j <=
                                                              5 -
                                                                  widget.ds[
                                                                      'rate'];
                                                          j++)
                                                        Icon(
                                                          Icons
                                                              .star_border_outlined,
                                                          color:
                                                              Color(0xFF000000),
                                                          size: 20,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                ),
                                // Container(
                                //   padding: EdgeInsets.all(10),
                                //   width: size.width,
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.center,
                                //     children: [
                                //       Text('Appointment Details',
                                //           textAlign: TextAlign.center,
                                //           style: AppTextStyle().headingStyle),
                                //     ],
                                //   ),
                                // ),
                                // Container(
                                //   padding: EdgeInsets.all(10),
                                //   child: Text(
                                //     'Psychologist Name :    ${widget.paymentfor}',
                                //     style: AppTextStyle().psychoListHeadStyle,
                                //   ),
                                // ),
                                // Container(
                                //   padding: EdgeInsets.all(10),
                                //   child: Text(
                                //     'Availability :    ${widget.ds["availability"].toString().replaceAll('[', '').replaceAll(']', '')}',
                                //     style: AppTextStyle().psychoListHeadStyle,
                                //   ),
                                // ),
                                // Container(
                                //   padding: EdgeInsets.all(10),
                                //   child: Text(
                                //     'Time :    ${time24to12(widget.ds['availTime']['start'])} - ${time24to12(widget.ds['availTime']['end'])}',
                                //     style: AppTextStyle().psychoListHeadStyle,
                                //   ),
                                // ),
                                SizedBox(
                                    // height: 70,
                                    ),

                                Container(
                                  width: size.width,
                                  height: 80,
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Container(
                                      //   padding: EdgeInsets.only(right: 20),
                                      //   child: Text(
                                      //     'Date of appointment : ',
                                      //     style:
                                      //         AppTextStyle().psychoListHeadStyle,
                                      //   ),
                                      // ),
                                      // SizedBox(
                                      //   width: 10,
                                      // ),

                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 15),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: SvgPicture.asset(
                                                  "assets/psycho/calendar.svg",
                                                  semanticsLabel: "calendar",
                                                  fit: BoxFit.cover,
                                                  width: 5,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: DateTimePicker(
                                                  initialValue: '',
                                                  firstDate: DateTime(2020),
                                                  lastDate: DateTime(2100),
                                                  use24HourFormat: false,
                                                  dateLabelText:
                                                      'Tap to select date',
                                                  calendarTitle:
                                                      'SELECT ANY DAY FROM ${widget.ds["availability"].toString().replaceAll('[', '').replaceAll(']', '').toUpperCase()}',
                                                  type: DateTimePickerType.date,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color(0xFF253334),
                                                    decorationColor:
                                                        Colors.grey,
                                                  ),
                                                  decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      disabledBorder:
                                                          InputBorder.none,
                                                      label: Text(
                                                        dateTimePsycho == "NA"
                                                            ? "Tap to select date"
                                                            : "Date selected",
                                                        style: dateTimePsycho ==
                                                                "NA"
                                                            ? TextStyle()
                                                            : TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                      ),
                                                      fillColor: Colors.grey),
                                                  onChanged: (val) {
                                                    print(dateTimePsycho);
                                                    setState(() {
                                                      dateTimePsycho = val;
                                                    });
                                                    print(dateTimePsycho);
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'Date of Appointment : $dateTimePsycho');
                                                  },
                                                  validator: (val) {
                                                    print(val);
                                                    return null;
                                                  },
                                                  onSaved: (val) {
                                                    print(
                                                        "Date Time selected is $val");
                                                    setState(() {
                                                      dateTimePsycho = val;
                                                    });

                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'Date of Appointment : $dateTimePsycho');
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: size.width,
                                  height: 80,
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Container(
                                      //   padding: EdgeInsets.only(right: 20),
                                      //   child: Text(
                                      //     'Time of appointment : ',
                                      //     style:
                                      //         AppTextStyle().psychoListHeadStyle,
                                      //   ),
                                      // ),
                                      // SizedBox(
                                      //   width: 10,
                                      // ),
                                      Container(
                                        width: size.width - 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        padding: EdgeInsets.only(left: 15),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              height: 25,
                                              width: 25,
                                              child: SvgPicture.asset(
                                                "assets/psycho/time.svg",
                                                semanticsLabel: "time",
                                                fit: BoxFit.cover,
                                                width: 5,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            DropdownButton<String>(
                                              value: dropdownValue,
                                              icon: const Icon(Icons
                                                  .arrow_drop_down_outlined),
                                              iconSize: 24,
                                              elevation: 1,
                                              style: AppTextStyle()
                                                  .psychoListHeadStyle,
                                              underline: Container(),
                                              // Container(
                                              //   height: 1,
                                              //   color: Colors.grey,
                                              // ),
                                              onChanged: (String newValue) {
                                                setState(() {
                                                  dropdownValue = newValue;
                                                });
                                                print(
                                                    'selected time is $dropdownValue');
                                                Fluttertoast.showToast(
                                                    msg:
                                                        'Time of Appointment : $dropdownValue');
                                              },
                                              items: timeList.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black54,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                // Container(
                                //   padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                //   child: Text(
                                //     'Booking Price : ',
                                //     style: AppTextStyle().psychoListHeadStyle,
                                //   ),
                                // ),
                                // Container(
                                //   padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                //   width: size.width,
                                //   child: Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: <Widget>[
                                //       sessionButton("30 mins",
                                //           widget.ds["fees"]["30mins"], 1),
                                //       sessionButton("1 hour",
                                //           widget.ds["fees"]["1hour"], 2),
                                //     ],
                                //   ),
                                // ),
                                // Container(
                                //   padding: EdgeInsets.all(10),
                                //   child: Text(
                                //     'Your Email ID :    ${widget.userData.myEmail}',
                                //     style: AppTextStyle().psychoListHeadStyle,
                                //   ),
                                // ),
                                // Container(
                                //   padding: EdgeInsets.all(10),
                                //   child: Text(
                                //     'Contact Hear Us :    info@hearus.me',
                                //     style: AppTextStyle().psychoListHeadStyle,
                                //   ),
                                // ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _modeSelected = 0;
                                        });
                                        print(_modeSelected);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: (_modeSelected == 0)
                                              ? AppColor().buttonColor
                                              : Theme.of(context).canvasColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/psycho/Group.svg",
                                          semanticsLabel: "Group",
                                          fit: BoxFit.cover,
                                          width: 45,
                                          color: AppColor().textColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _modeSelected = 1;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: (_modeSelected == 1)
                                              ? AppColor().buttonColor
                                              : Theme.of(context).canvasColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/psycho/call.svg",
                                          semanticsLabel: "call",
                                          fit: BoxFit.cover,
                                          width: 40,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _modeSelected = 2;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: (_modeSelected == 2)
                                              ? AppColor().buttonColor
                                              : Theme.of(context).canvasColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/psycho/video-camera.svg",
                                          semanticsLabel: "video-camera",
                                          fit: BoxFit.cover,
                                          width: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    // height: 50,
                                    ),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                        Divider(
                          thickness: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: button1("CONFIRM AND PAY",
                              AppColor().buttonColor, context, () {
                            print((_modeSelected != -1) &&
                                (dateTimePsycho != 'NA'));
                            if ((_modeSelected != -1) &&
                                (dateTimePsycho != 'NA')) {
                              openCheckout();
                            } else if (DateTime.parse(dateTimePsycho)
                                .isBefore(DateTime.now())) {
                              dialogEnterDetails("Please select a valid date");
                            } else {
                              dialogEnterDetails();
                            }
                          }),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
