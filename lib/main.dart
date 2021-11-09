import 'package:shared_preferences/shared_preferences.dart';
import 'category_screen.dart';
import 'res/colors.dart';
import 'package:flutter/material.dart';
import 'models/cardset.dart';
import 'models/subcategory.dart';
import 'models/card.dart';
import 'models/category.dart';
import 'models/program.dart';
import 'res/category_creation.dart';

void main() {
  runApp(const Home());
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}



class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Main(),
    );
  }
}

class Main extends StatelessWidget {
  const Main({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundLight, backgroundLight])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            //Categories
            ListView(
              shrinkWrap: true,
              children: categories.map((e) {
                String name = (e as Map)['name'];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (context) => CategoryScreen()));
                  },
                  child: Container(
                    height: 70,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.white,
                      backgroundBlendMode: BlendMode.overlay,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(left: 25),
                            child: Text(
                              (e as Map)['name'],
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w800,
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: blueMediumLight,
          foregroundColor: blueMediumLight,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
