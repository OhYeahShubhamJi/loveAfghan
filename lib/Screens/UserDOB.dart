import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loveafghan/Screens/Email.dart';
import 'package:loveafghan/localization/localization_constants.dart';
import 'package:loveafghan/util/color.dart';

class UserDOB extends StatefulWidget {
  final Map<String, dynamic> userData;
  UserDOB(this.userData);

  @override
  _UserDOBState createState() => _UserDOBState();
}

class _UserDOBState extends State<UserDOB> {
  // String userDOB = '';
  DateTime selecteddate;
  TextEditingController dobctlr = new TextEditingController();

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
                      getTranslated(context, 'my_birthday_is'),
                      style: TextStyle(fontSize: 40),
                    ),
                    padding: EdgeInsets.only(left: 50, top: 120),
                  ),
                ],
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Container(
                      child: ListTile(
                    title: CupertinoTextField(
                      readOnly: true,
                      keyboardType: TextInputType.phone,
                      prefix: IconButton(
                        icon: (Icon(
                          Icons.calendar_today,
                          color: primaryColor,
                        )),
                        onPressed: () {},
                      ),
                      onTap: () => showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                                height:
                                    MediaQuery.of(context).size.height * .25,
                                child: GestureDetector(
                                  child: CupertinoDatePicker(
                                    backgroundColor: Colors.white,
                                    initialDateTime: DateTime(
                                        _getYear(), _getMonth(), _getDay()),
                                    onDateTimeChanged: (DateTime newdate) {
                                      setState(() {
                                        dobctlr.text =
                                            newdate.month.toString() +
                                                '/' +
                                                newdate.day.toString() +
                                                '/' +
                                                newdate.year.toString();
                                        selecteddate = newdate;
                                      });
                                    },
                                    maximumYear: _getYear(),
                                    minimumYear: _getMinimumYear(),
                                    maximumDate: DateTime(
                                        _getYear(), _getMonth(), _getDay()),
                                    mode: CupertinoDatePickerMode.date,
                                  ),
                                  onTap: () {
                                    print(dobctlr.text);
                                    Navigator.pop(context);
                                  },
                                ));
                          }),
                      placeholder: "MM/DD/YYYY",
                      controller: dobctlr,
                    ),
                    subtitle:
                        Text(getTranslated(context, 'your_age_will_be_public')),
                  ))),
              dobctlr.text.length > 0
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
                            widget.userData.addAll({
                              'user_DOB': "$selecteddate",
                              'age': ((DateTime.now()
                                          .difference(selecteddate)
                                          .inDays) /
                                      365.2425)
                                  .truncate(),
                            });
                            print(widget.userData);
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        Email(widget.userData)));
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

int _getMinimumYear() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy').format(now);
  int year = int.parse(formattedDate) - 100;
  print(year);
  return year;
}

int _getYear() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy').format(now);
  int year = int.parse(formattedDate) - 18;
  print(year);
  return year;
}

int _getMonth() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('MM').format(now);
  int month = int.parse(formattedDate);
  print(month);
  return month;
}

int _getDay() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd').format(now);
  int day = int.parse(formattedDate);
  print(day);
  return day;
}
