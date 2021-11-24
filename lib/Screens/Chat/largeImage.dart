import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loveafghan/util/color.dart';

class LargeImage extends StatelessWidget {
  final largeImage;
  LargeImage(this.largeImage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: Colors.black, width: 1),
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
        body: Center(
          child: CachedNetworkImage(
            fit: BoxFit.contain,
            placeholder: (context, url) => Center(
              child: CupertinoActivityIndicator(
                radius: 20,
              ),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
            height: MediaQuery.of(context).size.height * .80,
            width: MediaQuery.of(context).size.width,
            imageUrl: largeImage ?? '',
          ),
        ));
  }
}
