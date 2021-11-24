import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/Screens/auth/otp.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/models/user_model.dart';
import 'package:loveafghan/util/color.dart';

class UpdateNumber extends StatelessWidget {
  final User currentUser;
  UpdateNumber(this.currentUser);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          getTranslated(context, 'phone_number_settings'),
          style: TextStyle(color: primaryColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: primaryColor,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
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
                  topLeft: Radius.circular(50), topRight: Radius.circular(50))),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(getTranslated(context, 'phone_number'),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Card(
                      child: ListTile(
                    title: Text(
                        currentUser.phoneNumber != null
                            ? "${currentUser.phoneNumber}"
                            : getTranslated(context, 'verify_phone_number'),
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400)),
                    trailing: Icon(
                      currentUser.phoneNumber != null ? Icons.done : null,
                      color: primaryColor,
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      getTranslated(context, 'verified_phone_number'),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: secondryColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Center(
                      child: InkWell(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                                getTranslated(
                                    context, 'update_my_phone_number'),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: primaryColor)),
                          ),
                        ),
                        onTap: () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => OTP(true))),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
