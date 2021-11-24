import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/Screens/UserDOB.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/util/color.dart';

class UserName extends StatefulWidget {
  @override
  _UserNameState createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {
  Map<String, dynamic> userData = {}; //user personal info
  String username = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Padding(
                    child: Text(
                      getTranslated(context, 'my_first_name_is'),
                      style: TextStyle(fontSize: 40),
                    ),
                    padding: EdgeInsets.only(left: 50, top: 120),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Container(
                  child: TextFormField(
                    style: TextStyle(fontSize: 23),
                    decoration: InputDecoration(
                      helperMaxLines: 3,
                      hintText: getTranslated(context, 'enter_your_first_name'),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                      helperText:
                          'Once you choose your name then you will not be able to change it.',
                      helperStyle: TextStyle(
                        color: secondryColor,
                        fontSize: 15,
                        // overflow: TextOverflow.visible
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        username = value;
                      });
                    },
                  ),
                ),
              ),
              username.length > 0
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
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
                                getTranslated(context, 'continue'),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                    fontWeight: FontWeight.bold),
                              ))),
                          onTap: () {
                            userData.addAll({'UserName': "$username"});
                            print(userData);
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => UserDOB(userData)));
                          },
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              height: MediaQuery.of(context).size.height * .065,
                              width: MediaQuery.of(context).size.width * .75,
                              child: Center(
                                  child: Text(
                                getTranslated(context, 'continue'),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: secondryColor,
                                    fontWeight: FontWeight.bold),
                              ))),
                          onTap: () {},
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
