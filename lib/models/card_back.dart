import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CardBackView extends StatefulWidget {
  Map cardMap;
  CardBackView(this.cardMap);

  @override
  State<CardBackView> createState() => _CardBackViewState();
}

class _CardBackViewState extends State<CardBackView> {

  final _cardBackKey = GlobalKey();
  double height = 50;
  double width = 50;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(getWidgetInfo);
  }

  void getWidgetInfo(_){
    final renderBoxRed = _cardBackKey.currentContext?.findRenderObject() as RenderBox;
    Size widgetSize = renderBoxRed.size;
    setState(() {
      height = renderBoxRed.size.height;
      width = renderBoxRed.size.width;
    });

    print("SIZE of widget game screen: $widgetSize");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width - 50,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Transform(
          key: _cardBackKey,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(pi),
        origin: Offset(width/2, height/2),
          child: AutoSizeText(
              widget.cardMap['exp'],
              minFontSize: 12,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                
              ),
            ),
        ),
      );
  }
}
