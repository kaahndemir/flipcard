import 'package:FlipCard/res/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CardFrontView extends StatelessWidget {
  Map cardMap;
  CardFrontView(this.cardMap);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width - 50,
      decoration: BoxDecoration(
          color: blueDark.withOpacity(0.95),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Container(
        child: AutoSizeText(
          cardMap['term'],
          minFontSize: 12,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            color: Colors.white
          ),
        ),
      ),
    );
  }
}

