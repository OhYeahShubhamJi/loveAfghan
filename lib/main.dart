import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loveafghan/Screens/Splash.dart';
import 'package:loveafghan/Screens/Tab.dart';
import 'package:loveafghan/Screens/Welcome.dart';
import 'package:loveafghan/Screens/auth/login.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/localization/loveafghan_localization.dart';
import 'package:loveafghan/util/color.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'util/color.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]).then((_) {
    InAppPurchaseConnection.enablePendingPurchases();
    runApp(new MyApp());
  });
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  bool isLoading = true;
  bool isAuth = false;
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  Future _checkAuth() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.currentUser().then((FirebaseUser user) async {
      print(user);
      if (user != null) {
        await Firestore.instance
            .collection('Users')
            .where('userId', isEqualTo: user.uid)
            .getDocuments()
            .then((QuerySnapshot snapshot) async {
          if (snapshot.documents.length > 0) {
            if (snapshot.documents[0].data['location'] != null) {
              setState(() {
                isRegistered = true;
                isLoading = false;
              });
            } else {
              setState(() {
                isAuth = true;
                isLoading = false;
              });
            }
            print("loggedin ${user.uid}");
          } else {
            setState(() {
              isLoading = false;
            });
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: primaryColor,
        ),
        home: Splash(),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: primaryColor,
          accentColor: darkPrimaryColor,
        ),
        locale: _locale,
        supportedLocales: [
          Locale('en', 'US'),
          Locale('ar', 'AE'),
          Locale('es', 'ES'),
          Locale('nl', 'NL'),
          Locale('ru', 'RU'),
          Locale('ur', 'PK'),
          Locale('hi', 'IN'),
          Locale('de', 'DE'),
          Locale('fr', 'FR'),
          Locale('fa', 'IR'),
          Locale('ps', 'AF'),
        ],
        localizationsDelegates: [
          LoveafghanLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          for (var locale in supportedLocales) {
            if (locale.languageCode == deviceLocale.languageCode &&
                locale.countryCode == deviceLocale.countryCode) {
              return deviceLocale;
            }
          }

          return supportedLocales.first;
        },
        home: isLoading
            ? Splash()
            : isRegistered
                ? Tabbar(null, null)
                : isAuth
                    ? Welcome()
                    : Login(),
      );
    }
  }
}

RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
Function mathFunc = (Match match) => '${match[1]},';
