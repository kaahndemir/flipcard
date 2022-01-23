import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:FlipCard/dialogs/createCard.dart';
import 'package:FlipCard/flipcard.dart';
import 'package:FlipCard/main.dart';
import 'package:FlipCard/models/card_front.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:FlipCard/words_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'res/colors.dart';
import 'res/category_creation.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardBoxScreen extends StatefulWidget {
  const CardBoxScreen({Key? key}) : super(key: key);

  @override
  _CardBoxScreenState createState() => _CardBoxScreenState();
}

String boxId = '';

StreamController<int> cardBoxStream = StreamController<int>();

late Size size;

class _CardBoxScreenState extends State<CardBoxScreen> {
  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    boxId = arguments['id'];
    print(boxId);

    setSharedPrefs();

    size = MediaQuery.of(context).size;
    
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(child: CardBox()),
          ],
        ));
  }
}

Function refreshCardBoxScreen = () {};
final cardsetController = TextEditingController();
var uuid = Uuid();

class CardBox extends StatefulWidget {
  const CardBox({Key? key}) : super(key: key);

  @override
  State<CardBox> createState() => _CardBoxState();
}

double heightRatio = 1;
String materialsPath = 'assets/materials';
String svgLogo = '$materialsPath/logo.svg';

List _secureCards = [];

class _CardBoxState extends State<CardBox> {
  addSecureCards() async {
    _secureCards = [];
    await setSharedPrefs();
    Map cardBox = await json.decode(prefs.getString(boxId).toString());

    for(int i = 0; i < cardBox['cards'].length; i++){
      Map card = cardBox['cards'][i];
       print('addSecureCard() card: $card');
      if (card['status'] != 'del') {
        _secureCards.add(card);
      }
    }
    print('SecureCards: $_secureCards');

    print('addSecureCards() run');
  }

  final _globalKey = GlobalKey();
  final _columnKey = GlobalKey();
  double heightListView = 50;
  double widthListView = 50;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(getWidgetInfo);
    print('initState => cardBox.dart');
  }

  void getWidgetInfo(_) {
    final renderBoxRed =
        _columnKey.currentContext?.findRenderObject() as RenderBox;
    Size widgetSize = renderBoxRed.size;
    setState(() {
      heightListView = renderBoxRed.size.height;
      widthListView = renderBoxRed.size.width;
    });

    print("SIZE of widget game screen: $widgetSize");
  }

  @override
  Widget build(BuildContext context) {
    //683 is the height of the emulator
    heightRatio = (height / 683);
    print('Height: $height');
    refreshCardBoxScreen = () {
      print('refreshCardBoxScreen');
      setState(() {});
    };
        //Set securecards
    if (!cardBoxStream.hasListener) {
      cardBoxStream.stream.listen((e) {
        addSecureCards();
      });
    }
    
    return FutureBuilder(
      future: addSecureCards(),
      builder: (context, snapshot) {
        
        return SafeArea(
            child: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: (size.height > heightListView)
                          ? size.height - heightListView
                          : 0),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [backgroundDark, backgroundLight])),
                  child: Column(
                    key: _columnKey,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(top: 25, left: 25, bottom: 40),
                        child: AutoSizeText(
                          returnCardBox()['name'],
                          style: const TextStyle(
                              fontSize: 30,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _secureCards.length, // Variable's value is 0
                          itemBuilder: (context, index) {
                            Map card = returnCardBox()['cards'][index];
                            return Transform.rotate(
                              angle: pi / -80,
                              child: Slidable(
                                key: UniqueKey(),
                                endActionPane: ActionPane(
                                    extentRatio: 1 / 2,
                                    motion: ScrollMotion(),
                                    dismissible: DismissiblePane(
                                      onDismissed: () {
                                        removeCard(index);
                                      },
                                    ),
                                    children: [
                                      SlidableAction(
                                          label: 'Delete',
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.red,
                                          onPressed: (context) {
                                            removeCard(index);
                                          }),
                                    ]),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 4, top: 4),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(),
                                      Container(
                                        width: size.width - 100,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.all(Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Container(
                                                padding: EdgeInsets.only(right: 5),
                                                child: AutoSizeText(
                                                  card['term'],
                                                  maxLines: 1,
                                                  minFontSize: 20,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      color: Colors.black,
                                                      fontFamily: 'Raleway',
                                                      fontWeight: FontWeight.w800,
                                                      fontStyle: FontStyle.italic),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: isDone(index)
                                                  ? 'Mark as Undone'
                                                  : 'Mark as Done',
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                if (isDone(index)) {
                                                  markAsUndone(index);
                                                } else {
                                                  markAsDone(index);
                                                }
                                              },
                                              icon: Icon(
                                                !isDone(index)
                                                    ? Icons.mark_as_unread_rounded
                                                    : Icons.done,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          height: 35,
                                          width: 5,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft: Radius.circular(10)),
                                            color: Colors.red,
                                          ),
                                          child: SizedBox())
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: size.width,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: Size(size.width, 80),
                      painter: BNBCustomPainter(),
                    ),
                    Center(
                        child: FloatingActionButton(
                      heroTag: 3,
                      onPressed: () {
                        shuffled = [];
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GamePage(cardBoxId: boxId)));
                      },
                      backgroundColor: Colors.transparent,
                      child: Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: SvgPicture.asset(
                          svgLogo,
                          fit: BoxFit.contain,
                        ),
                      ),
                      splashColor: blueMediumLight,
                    )),
                    Container(
                      width: size.width,
                      height: 80,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FloatingActionButton(
                              heroTag: '1',
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              tooltip: 'Restore Cards',
                              splashColor: blueMediumLight,
                              onPressed: () {},
                              child: Icon(
                                Icons.restore_from_trash_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            FloatingActionButton(
                              heroTag: '0',
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              tooltip: 'Create Card',
                              splashColor: blueMediumLight,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => CreateCard());
                              },
                              child: Icon(
                                Icons.add_circle_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ]),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
      }
    );
  }

  formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('MM/dd').format(dateTime);
    return formattedDate;
  }

  List decorationCards = [];
  List cardBoxIndexes = [];

  isDone(index) {
    setSharedPrefs();
    bool result = false;

    result = _secureCards[index]['status'] == 'done';

    for (int i = 0; i < _secureCards.length; i++) {
      if (_secureCards[i]['id'] == boxId) {
        if (_secureCards[i]['cards'][index]['status'] == 'done') {
          result = true;
        }
      }
    }
    return result;
  }

  //This will return cardbox as Map
  returnCardBox() {
    setSharedPrefs();
    Map result = json.decode(prefs.getString(boxId).toString()) as Map;

    return result;
  }

  void markAsUndone(int index) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    prefs = await _prefs;
    Map tempMap = json.decode(prefs.getString(boxId).toString());

    tempMap['cards'][index]['status'] = 'undone';

    await prefs.setString(boxId, json.encode(tempMap));
    await setSharedPrefs();
    cardBoxStream.add(0);
  }

  void markAsDone(int index) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    prefs = await _prefs;
    Map tempMap = json.decode(prefs.getString(boxId).toString());

    tempMap['cards'][index]['status'] = 'done';

    await prefs.setString(boxId, json.encode(tempMap));
    await setSharedPrefs();
    cardBoxStream.add(0);
  }

  removeCard(int index) async {
    await setSharedPrefs();
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;

    Map cardBox = json.decode(prefs.getString(boxId).toString());

    cardBox['cards'][index]['status'] = 'del';

    await prefs.setString(boxId, json.encode(cardBox));

    await setSharedPrefs();

    cardBoxStream.add(0);
    print('CardBox: ${cardBox}');
  }
}

int returnRandomNumber(int max, int min) {
  Random _random = Random();
  int randomNumber = min + _random.nextInt(max - min);
  return randomNumber;
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundLight
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true /* UnimplementedError() */;
  }
}
