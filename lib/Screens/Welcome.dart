import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/Screens/UserDOB.dart';
import 'package:loveafghan/Screens/UserName.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/util/color.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Container(
                  height: MediaQuery.of(context).size.height * .8,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 150,
                        ),
                        Text(
                          "Love Afghan",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 35,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            getTranslated(context, 'welcome_text'),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            getTranslated(context, 'be_yourself'),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            getTranslated(context, 'be_yourself_text'),
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            getTranslated(context, 'playit_cool'),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            getTranslated(context, 'playit_cool_text'),
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            getTranslated(context, 'stay_safe'),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            getTranslated(context, 'stay_safe_text'),
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            getTranslated(context, 'be_proactive'),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            getTranslated(context, 'be_proactive_text'),
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40, top: 50),
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
                          getTranslated(context, 'got_it'),
                          style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                              fontWeight: FontWeight.bold),
                        ))),
                    onTap: () async {
                      await FirebaseAuth.instance.currentUser().then((_user) {
                        if (_user.displayName != null) {
                          if (_user.displayName.length > 0) {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => UserDOB({
                                          'UserName': _user.displayName
                                              .split(" ")
                                              .sublist(0, 1)
                                              .join(" ")
                                        })));
                          } else {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => UserName()));
                          }
                        } else {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => UserName()));
                        }
                      });
                    },
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
