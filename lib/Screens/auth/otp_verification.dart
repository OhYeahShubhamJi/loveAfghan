import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loveafghan/Screens/Tab.dart';
import 'package:loveafghan/Screens/auth/otp.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/util/color.dart';
import 'package:loveafghan/util/snackbar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'login.dart';

class Verification extends StatefulWidget {
  final bool updateNumber;
  final String phoneNumber;
  final String smsVerificationCode;
  Verification(this.phoneNumber, this.smsVerificationCode, this.updateNumber);

  @override
  _VerificationState createState() => _VerificationState();
}

var onTapRecognizer;

class _VerificationState extends State<Verification> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Login _login = new Login();
  Future updateNumber() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection("Users")
        .document(user.uid)
        .setData({'phoneNumber': user.phoneNumber}, merge: true).then((_) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            Future.delayed(Duration(seconds: 2), () async {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Tabbar(null, null)));
            });
            return Center(
                child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          "asset/auth/verified.jpg",
                          height: 100,
                        ),
                        Text(
                          getTranslated(
                              context, 'phone_number_changed_successfully'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.black,
                              fontSize: 20),
                        )
                      ],
                    )));
          });
    });
  }

  String code;
  @override
  void initState() {
    super.initState();
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pop(context);
      };
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(60),
        ),
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: IconButton(
          alignment: Alignment.centerRight,
          color: secondryColor,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 100),
                width: 300,
                child: Image.asset(
                  "asset/auth/verifyOtp.png",
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50),
              child: RichText(
                text: TextSpan(
                    text: getTranslated(context, 'enter_the_code_sent_to'),
                    children: [
                      TextSpan(
                          text: widget.phoneNumber,
                          style: TextStyle(
                              color: primaryColor,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              textBaseline: TextBaseline.alphabetic,
                              fontSize: 15)),
                    ],
                    style: TextStyle(color: Colors.black54, fontSize: 15)),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: PinCodeTextField(
                textInputType: TextInputType.number,
                length: 6,
                obsecureText: false,
                animationType: AnimationType.fade,
                shape: PinCodeFieldShape.underline,
                animationDuration: Duration(milliseconds: 300),
                fieldHeight: 50,
                fieldWidth: 35,
                onChanged: (value) {
                  code = value;
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: "Didn't receive the code? ",
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                  children: [
                    TextSpan(
                        text: " RESEND",
                        recognizer: onTapRecognizer,
                        style: TextStyle(
                            color: Color(0xFF91D3B3),
                            fontWeight: FontWeight.bold,
                            fontSize: 16))
                  ]),
            ),
            SizedBox(
              height: 40,
            ),
            InkWell(
              child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            primaryColor.withOpacity(.5),
                            primaryColor.withOpacity(.8),
                            primaryColor,
                            primaryColor
                          ])),
                  height: MediaQuery.of(context).size.height * .065,
                  width: MediaQuery.of(context).size.width * .75,
                  child: Center(
                      child: Text(
                    getTranslated(context, 'verify'),
                    style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.bold),
                  ))),
              onTap: () async {
                showDialog(
                  builder: (context) {
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pop(context);
                    });
                    return Center(
                        child: CupertinoActivityIndicator(
                      radius: 20,
                    ));
                  },
                  barrierDismissible: false,
                  context: context,
                );
                AuthCredential _phoneAuth = PhoneAuthProvider.getCredential(
                    verificationId: widget.smsVerificationCode, smsCode: code);
                if (widget.updateNumber) {
                  FirebaseUser user = await FirebaseAuth.instance.currentUser();
                  user
                      .updatePhoneNumberCredential(_phoneAuth)
                      .then((_) => updateNumber())
                      .catchError((e) {
                    if (e.toString() ==
                        "PlatformException(ERROR_CREDENTIAL_ALREADY_IN_USE, This credential is already associated with a different user account., null, null)") {
                      CustomSnackbar.snackbar(
                          "This phone number is already associated with a different user account.",
                          _scaffoldKey);
                    } else {
                      CustomSnackbar.snackbar("$e", _scaffoldKey);
                    }
                  });
                } else {
                  FirebaseAuth.instance
                      .signInWithCredential(_phoneAuth)
                      .then((authResult) {
                    if (authResult != null) {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) {
                            Future.delayed(Duration(seconds: 2), () async {
                              Navigator.pop(context);
                              await _login.navigationCheck(
                                  authResult.user, context);
                            });
                            return Center(
                                child: Container(
                                    width: 180.0,
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Column(
                                      children: <Widget>[
                                        Image.asset(
                                          "asset/auth/verified.jpg",
                                          height: 100,
                                        ),
                                        Text(
                                          getTranslated(
                                              context, 'verified_successfully'),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              decoration: TextDecoration.none,
                                              color: Colors.black,
                                              fontSize: 20),
                                        )
                                      ],
                                    )));
                          });
                      Firestore.instance
                          .collection('Users')
                          .where('userId', isEqualTo: authResult.user.uid)
                          .getDocuments()
                          .then((QuerySnapshot snapshot) async {
                        if (snapshot.documents.length <= 0) {
                          await setDataUser(authResult.user);
                        }
                      });
                    }
                  }).catchError((onError) {
                    CustomSnackbar.snackbar(
                        "Invalid verification code, Please try again.",
                        _scaffoldKey);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
