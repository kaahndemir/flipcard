import 'package:flutter/material.dart';
import 'res/colors.dart';
import 'res/category_creation.dart';


class CategoryScreen extends StatelessWidget {
  const CategoryScreen({
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
            GridView.count(
              crossAxisCount: 2,
              
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
                    height: 80,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.white,
                      backgroundBlendMode: BlendMode.overlay,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            margin: EdgeInsets.all(10),
                            child: Text(
                              (e as Map)['name'],
                              style: TextStyle(
                                fontSize: 20,
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
