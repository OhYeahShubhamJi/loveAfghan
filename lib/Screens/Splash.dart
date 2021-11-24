import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
              height: 175,
              width: 200,
              child: Image.asset(
                "asset/loveafghan-Logo-BP.png",
                width: 200,
                height: 175,
                fit: BoxFit.contain,
              )),
        ));
  }
}
