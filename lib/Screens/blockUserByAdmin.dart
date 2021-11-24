import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/util/color.dart';
import 'package:url_launcher/url_launcher.dart';

class BlockUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondryColor.withOpacity(.5),
      body: AlertDialog(
        actionsPadding: EdgeInsets.only(right: 10),
        backgroundColor: Colors.white,
        actions: [
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: getTranslated(context, 'for_more_info_visit'),
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  TextSpan(
                    text: " https://loveafghan.com",
                    style: TextStyle(color: primaryColor, fontSize: 16),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url = 'https://loveafghan.com';
                        if (await canLaunch(url)) {
                          await launch(
                            url,
                            forceSafariVC: false,
                          );
                        }
                      },
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
        title: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: Container(
                      height: 50,
                      width: 100,
                      child: Image.asset(
                        "asset/loveafghan-Logo-BP.png",
                        fit: BoxFit.contain,
                      )),
                )),
            Text(
              getTranslated(context, 'sorry_you_cant_access_the_application'),
              style: TextStyle(color: primaryColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          getTranslated(context,
              'youre_blocked_by_the_admin_and_your_profile_will_also_not_appear_for_other_users'),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
