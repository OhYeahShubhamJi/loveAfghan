import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loveafghan/Screens/auth/login.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/main.dart';
import 'package:loveafghan/models/language.dart';
import 'package:loveafghan/models/user_model.dart';
import 'package:loveafghan/util/color.dart';
import 'package:loveafghan/util/snackbar.dart';
import 'package:share/share.dart';
import 'UpdateNumber.dart';
import 'UpdateEmail.dart';

class Settings extends StatefulWidget {
  final User currentUser;
  final bool isPurchased;
  final Map items;
  Settings(this.currentUser, this.isPurchased, this.items);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map<String, dynamic> changeValues = {};
  RangeValues ageRange;
  String email;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _showMe;
  int distance;
  bool isNotificationsEnabled = true;
  bool isEmailsEnabled = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void dispose() {
    // _ad?.dispose();
    super.dispose();

    if (changeValues.length > 0) {
      updateData();
    }
  }

  Future updateData() async {
    Firestore.instance
        .collection("Users")
        .document(widget.currentUser.id)
        .setData(changeValues, merge: true);
    // lastVisible = null;
    // print('ewew$lastVisible');
  }

  int freeR;
  int paidR;

  @override
  void initState() {
    super.initState();
    email = widget.currentUser.email;
    freeR = widget.items['free_radius'] != null
        ? int.parse(widget.items['free_radius'])
        : 400;
    paidR = widget.items['paid_radius'] != null
        ? int.parse(widget.items['paid_radius'])
        : 400;
    setState(() {
      if (!widget.isPurchased && widget.currentUser.maxDistance > freeR) {
        widget.currentUser.maxDistance = freeR.round();
        changeValues.addAll({'maximum_distance': freeR.round()});
      } else if (widget.isPurchased &&
          widget.currentUser.maxDistance >= paidR) {
        widget.currentUser.maxDistance = paidR.round();
        changeValues.addAll({'maximum_distance': paidR.round()});
      }
      _showMe = widget.currentUser.showGender;
      distance = widget.currentUser.maxDistance.round();
      ageRange = RangeValues(double.parse(widget.currentUser.ageRange['min']),
          (double.parse(widget.currentUser.ageRange['max'])));
      isNotificationsEnabled = widget.currentUser.isNotificationsEnabled;
      isEmailsEnabled = widget.currentUser.isEmailsEnabled;
    });
  }

  void _changeLanguage(Language language) async {
    Locale _temp = await setLocale(language.languageCode);
    MyApp.setLocale(context, _temp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(
            getTranslated(context, 'settings'),
            style: TextStyle(color: primaryColor),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: primaryColor,
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: Colors.white),
      body: Container(
        decoration: BoxDecoration(
          color: primaryColor,

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(49),
            topRight: const Radius.circular(49),
          ), // BorderRadius
        ),
        child: Container(
          margin: const EdgeInsetsDirectional.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            // border: Border(top: BorderSide(width: 4)),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      getTranslated(context, 'account_settings'),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  email == ''
                      ? ListTile(
                          title: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: InkWell(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(getTranslated(context, 'email')),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                          ),
                                          child: Text(
                                            getTranslated(context, 'add_now'),
                                            style:
                                                TextStyle(color: secondryColor),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: secondryColor,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) => UpdateEmail(
                                                  email,
                                                  widget.currentUser.id)))
                                      .then((value) {
                                    setState(() {
                                      if (value.toString() != null) {
                                        CustomSnackbar.snackbar(
                                            getTranslated(context,
                                                'your_email_has_been_updated'),
                                            _scaffoldKey);
                                        print("Email Updated!");
                                        email = value.toString();
                                      }
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => UpdateEmail(
                                    email,
                                    widget.currentUser.id,
                                  ),
                                ),
                              ).then(
                                (value) {
                                  setState(
                                    () {
                                      value != null
                                          ? email = value.toString()
                                          : print("operation canceled!");
                                    },
                                  );
                                },
                              );
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: <Widget>[
                                    Text('Email'),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: Text(
                                        email,
                                        style: TextStyle(
                                          color: secondryColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: secondryColor,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  ListTile(
                    title: Card(
                        child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(getTranslated(context, 'phone_number')),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                  ),
                                  child: Text(
                                    widget.currentUser.phoneNumber != null
                                        ? "${widget.currentUser.phoneNumber}"
                                        : getTranslated(context, 'verify_now'),
                                    style: TextStyle(color: secondryColor),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: secondryColor,
                                  size: 15,
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      UpdateNumber(widget.currentUser)));
                        },
                      ),
                    )),
                    subtitle: Text(getTranslated(context,
                        'verify_a_phone_number_to_secure_your_account')),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      getTranslated(context, 'discovery_settings'),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Card(
                      child: ExpansionTile(
                        key: UniqueKey(),
                        leading: Text(
                          getTranslated(context, 'current_location'),
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        title: Text(
                          widget.currentUser.address,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Center(
                                      child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(60),
                                            boxShadow: [
                                              BoxShadow(
                                                spreadRadius: 5,
                                                blurRadius: 5,
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                          child: CupertinoActivityIndicator(
                                            radius: 15,
                                          )),
                                    );
                                  });
                              var currentLocation = await Geolocator()
                                  .getCurrentPosition(
                                      desiredAccuracy: LocationAccuracy.best);
                              List<Placemark> pm = await Geolocator()
                                  .placemarkFromCoordinates(
                                      currentLocation.latitude,
                                      currentLocation.longitude);
                              var address =
                                  "${pm[0].locality}${pm[0].subLocality} ${pm[0].subAdministrativeArea}\n ${pm[0].country} ,${pm[0].postalCode}";
                              Navigator.pop(context);
                              showCupertinoModalPopup(
                                  context: context,
                                  builder: (ctx) {
                                    return Container(
                                      color: Colors.white,
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .4,
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              getTranslated(
                                                  context, 'new_address'),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                          ),
                                          Card(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(18.0),
                                              child: Text(
                                                address,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w300,
                                                    decoration:
                                                        TextDecoration.none),
                                              ),
                                            ),
                                          ),
                                          RaisedButton(
                                            color: Colors.white,
                                            child: Text(
                                              getTranslated(context, 'done'),
                                              style: TextStyle(
                                                  color: primaryColor),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Firestore.instance
                                                  .collection("Users")
                                                  .document(
                                                      '${widget.currentUser.id}')
                                                  .updateData({
                                                'location': {
                                                  'latitude':
                                                      currentLocation.latitude,
                                                  'longitude':
                                                      currentLocation.longitude,
                                                  'address': address
                                                },
                                              });
                                              showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (_) {
                                                    Future.delayed(
                                                        Duration(seconds: 3),
                                                        () {
                                                      setState(() {
                                                        widget.currentUser
                                                            .address = address;
                                                      });

                                                      Navigator.pop(context);
                                                    });
                                                    return Center(
                                                        child: Container(
                                                            width: 160.0,
                                                            height: 120.0,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Image.asset(
                                                                  "asset/auth/verified.jpg",
                                                                  height: 60,
                                                                  color:
                                                                      primaryColor,
                                                                  colorBlendMode:
                                                                      BlendMode
                                                                          .color,
                                                                ),
                                                                Text(
                                                                  getTranslated(
                                                                      context,
                                                                      'location_changed'),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      decoration:
                                                                          TextDecoration
                                                                              .none,
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          20),
                                                                )
                                                              ],
                                                            )));
                                                  });

                                              // .then((_) {
                                              //   Navigator.pop(context);
                                              // });
                                            },
                                          )
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.blue,
                                    size: 25,
                                  ),
                                  Text(
                                    getTranslated(context, 'change_location'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                    ),
                    child: Text(
                      getTranslated(context,
                          'change_your_location_to_see_members_in_other_city'),
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              getTranslated(context, 'show_me'),
                              style: TextStyle(
                                  fontSize: 18,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            ListTile(
                              title: DropdownButton(
                                iconEnabledColor: primaryColor,
                                iconDisabledColor: secondryColor,
                                isExpanded: true,
                                items: [
                                  DropdownMenuItem(
                                    child: Text(getTranslated(context, 'men')),
                                    value: "man",
                                  ),
                                  DropdownMenuItem(
                                      child:
                                          Text(getTranslated(context, 'women')),
                                      value: "woman"),
                                  DropdownMenuItem(
                                      child: Text(
                                          getTranslated(context, 'everyone')),
                                      value: "everyone"),
                                ],
                                onChanged: (val) {
                                  changeValues.addAll({
                                    'showGender': val,
                                  });
                                  setState(() {
                                    _showMe = val;
                                  });
                                },
                                value: _showMe,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            getTranslated(context, 'maximum_distance'),
                            style: TextStyle(
                                fontSize: 18,
                                color: primaryColor,
                                fontWeight: FontWeight.w500),
                          ),
                          trailing: Text(
                            "${(distance * 0.621371).toStringAsFixed(0).replaceAllMapped(reg, mathFunc)} ${(distance * 0.621371).toStringAsFixed(0).replaceAllMapped(reg, mathFunc) == "1" ? "Mile" : "Miles"} \n(${distance.toString().replaceAllMapped(reg, mathFunc)} Km)",
                            style: TextStyle(fontSize: 16),
                          ),
                          subtitle: Slider(
                              value: distance.toDouble(),
                              inactiveColor: secondryColor,
                              min: 1.0,
                              max: widget.isPurchased
                                  ? paidR.toDouble()
                                  : freeR.toDouble(),
                              activeColor: primaryColor,
                              onChanged: (val) {
                                changeValues
                                    .addAll({'maximum_distance': val.round()});
                                setState(() {
                                  distance = val.round();
                                });
                              }),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            getTranslated(context, 'age_range'),
                            style: TextStyle(
                                fontSize: 18,
                                color: primaryColor,
                                fontWeight: FontWeight.w500),
                          ),
                          trailing: Text(
                            "${ageRange.start.round()}-${ageRange.end.round()}",
                            style: TextStyle(fontSize: 16),
                          ),
                          subtitle: RangeSlider(
                              inactiveColor: secondryColor,
                              values: ageRange,
                              min: 18.0,
                              max: 100.0,
                              divisions: 25,
                              activeColor: primaryColor,
                              labels: RangeLabels('${ageRange.start.round()}',
                                  '${ageRange.end.round()}'),
                              onChanged: (val) {
                                changeValues.addAll({
                                  'age_range': {
                                    'min': '${val.start.truncate()}',
                                    'max': '${val.end.truncate()}'
                                  }
                                });
                                setState(() {
                                  ageRange = val;
                                });
                              }),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      getTranslated(context, 'app_settings'),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                getTranslated(context, 'notifications'),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(getTranslated(
                                      context, 'push_notifications')),
                                  Switch(
                                      activeColor: primaryColor,
                                      value: isNotificationsEnabled,
                                      onChanged: (value) {
                                        changeValues.addAll(
                                            {'isNotificationsEnabled': value});
                                        setState(() {
                                          isNotificationsEnabled = value;
                                        });
                                      })
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "Email Notifications"), // TODO: translate this.
                                  Switch(
                                      activeColor: primaryColor,
                                      value: isEmailsEnabled,
                                      onChanged: (value) {
                                        changeValues
                                            .addAll({'isEmailsEnabled': value});
                                        setState(() {
                                          isEmailsEnabled = value;
                                        });
                                      })
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              getTranslated(context, 'language'),
                              style: TextStyle(
                                  fontSize: 18,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            ListTile(
                              title: DropdownButton<Language>(
                                hint: Text(
                                    getTranslated(context, 'change_language')),
                                onChanged: (Language language) {
                                  _changeLanguage(language);
                                },
                                items: Language.languageList()
                                    .map<DropdownMenuItem<Language>>((lang) =>
                                        DropdownMenuItem<Language>(
                                          value: lang,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                lang.flag,
                                                style: TextStyle(fontSize: 24),
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Text(lang.name)
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'invite_your_friends'),
                              style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Share.share(
                            'Check out this app to meet Afghans around the world : https://loveafghan.com/',
                            subject: 'Invitation to Love Afghan App');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      child: Card(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                              getTranslated(context, 'logout'),
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(getTranslated(context, 'logout')),
                              content: Text(getTranslated(context,
                                  'do_you_want_to_logout_your_account')),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(getTranslated(context, 'no')),
                                ),
                                FlatButton(
                                  onPressed: () async {
                                    await _auth.signOut().whenComplete(() {
                                      Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => Login()),
                                      );
                                    });
                                  },
                                  child: Text(getTranslated(context, 'yes')),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'delete_account'),
                              style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  getTranslated(context, 'delete_account')),
                              content: Text(getTranslated(context,
                                  'do_you_really_want_to_delete_your_account')),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(getTranslated(context, 'no')),
                                ),
                                FlatButton(
                                  onPressed: () async {
                                    final user = await _auth
                                        .currentUser()
                                        .then((FirebaseUser user) {
                                      return user;
                                    });
                                    await _deleteUser(user).then((_) async {
                                      await user.delete().whenComplete(() {
                                        Navigator.pushReplacement(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) => Login()),
                                        );
                                      });
                                    });
                                  },
                                  child: Text(getTranslated(context, 'yes')),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Container(
                            height: 50,
                            width: 100,
                            child: Image.asset(
                              "asset/loveafghan-Logo-BP.png",
                              fit: BoxFit.contain,
                            )),
                      )),
                  SizedBox(
                    height: 80,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _deleteUser(FirebaseUser user) async {
    await Firestore.instance.collection("Users").document(user.uid).delete();
  }
}
