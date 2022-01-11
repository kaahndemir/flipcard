import 'dart:convert';
import 'dart:math';

import 'package:FlipCard/cardbox.dart';
import 'package:FlipCard/flipcard.dart';
import 'package:FlipCard/cardbox.dart';
import 'package:FlipCard/models/card_back.dart';
import 'package:FlipCard/models/card_front.dart';
import 'package:FlipCard/recovery/game_screen.dart';
import 'package:FlipCard/res/category_creation.dart';
import 'package:FlipCard/res/colors.dart';
import 'package:FlipCard/words_screen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CreateCard extends StatefulWidget {
  const CreateCard({Key? key}) : super(key: key);

  @override
  _CreateCardState createState() => _CreateCardState();
}

late AnimationController _flipAnimationController;
late Animation _flipAnimation;
AnimationStatus _animationStatus = AnimationStatus.dismissed;

final GlobalKey _widgetKey = GlobalKey();

double height = 0;
double width = 0;
bool isRun = false;

String cardBoxId = boxId;

Map card = {'status': 'undone', 'id': uuid.v4(), 'term': '', 'exp': ''};

class _CreateCardState extends State<CreateCard> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _flipAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _flipAnimation =
        Tween<double>(begin: 0, end: 1).animate(_flipAnimationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            _animationStatus = status;
          });

    cardFrontController = TextEditingController();
    cardBackController = TextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback(getWidgetInfo);
  }

  void getWidgetInfo(_) {
    final RenderBox renderBox =
        _widgetKey.currentContext!.findRenderObject() as RenderBox;
    final widgetSize = renderBox.size;
    height = renderBox.size.height;
    width = renderBox.size.width;

    isRun =
        true; //If the build is complete, activate onScroll for CarouselSlider
    print("SIZE of widget game screen: $widgetSize");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox.expand(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                if (_flipAnimation.value < 0.5) {
                  _flipAnimationController.forward();
                } else if (cardFrontController.text.isNotEmpty &&
                    cardBackController.text.isNotEmpty) {
                  //Save the card
                  final _prefs = await SharedPreferences.getInstance();
                  SharedPreferences prefs = await _prefs;

                  Map cardBox = json.decode(prefs.getString(boxId).toString());
                  card['term'] = cardFrontController.text;
                  card['exp'] = cardBackController.text;

                  cardBox['cards'].insert(0, card);

                  prefs.setString(boxId, json.encode(cardBox));
                  await setSharedPrefs();
                  Navigator.pop(context);
                  cardBoxStream.add(1);
                  setState(() {
                    cardBackController.clear();
                    cardFrontController.clear();
                  });
                } else if (cardFrontController.text.isEmpty) {
                  _flipAnimationController.reverse();
                }
              },
              child: Card(
                color: Colors.transparent,
                elevation: 10,
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  height: 50,
                  width: size.width - 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: blueMediumLight),
                  child: Text(
                    _flipAnimation.value > 0.5 ? 'Save' : 'Next',
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w800,
                        fontSize: 30,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            GestureDetector(
              key: _widgetKey,
              onVerticalDragUpdate: (d) async {
                if (_flipAnimation.value < 0.5) {
                  _flipAnimationController.forward();
                } else {
                  _flipAnimationController.reverse();
                }
              },
              child: Container(
                height: size.height / 5 * 3,
                width: size.width,
                alignment: Alignment.center,
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(pi * _flipAnimation.value),
                  origin: Offset(width / 2, height / 2),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: _flipAnimation.value > 0.5
                        ? CreateCardBack(card)
                        : CreateCardFront(card),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TextEditingController cardFrontController = TextEditingController();
TextEditingController cardBackController = TextEditingController();

bool isComplete = false;

class CreateCardFront extends StatelessWidget {
  Map cardMap;
  CreateCardFront(this.cardMap);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width - 50,
      decoration: BoxDecoration(
          color: blueDark.withOpacity(0.95),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Flexible(
                    child: TextField(
                      onChanged: (e) {
                        isDone();
                      },
                      controller: cardFrontController,
                      cursorColor: Colors.white70,
                      textAlignVertical: TextAlignVertical.center,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter term',
                          hintStyle: TextStyle(color: Colors.white54)),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: IconButton(
                splashRadius: 15,
                onPressed: () {
                  
                },
                icon: Icon(
                  Icons.edit,
                ),
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CreateCardBack extends StatefulWidget {
  Map cardMap;
  CreateCardBack(this.cardMap);

  @override
  State<CreateCardBack> createState() => _CreateCardBackState();
}

class _CreateCardBackState extends State<CreateCardBack> {
  final _cardBackKey = GlobalKey();
  double height = 50;
  double width = 50;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(getWidgetInfo);
  }

  void getWidgetInfo(_) {
    final renderBoxRed =
        _cardBackKey.currentContext?.findRenderObject() as RenderBox;
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
        origin: Offset(width / 2, height / 2),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Flexible(
                  child: TextField(
                    onChanged: (e) {
                      isDone();
                    },
                    controller: cardBackController,
                    cursorColor: Colors.black87,
                    textAlignVertical: TextAlignVertical.center,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter explanation',
                        hintStyle: TextStyle(color: Colors.black45)),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                        color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

isDone() {
  //Check if the both controller texts are entered
  if (cardBackController.text.isNotEmpty &&
      cardFrontController.text.isNotEmpty) {
    isComplete = true;
  }
  return isComplete;
}
