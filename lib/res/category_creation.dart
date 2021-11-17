import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


List data = [
  {'name': 'Entrepreneurship',
    'id': '8456',
    'date': '2021-11-09 20:17:09.102',
    'cardsets': [
      {'name': 'Business Model',
        'date': '2021-12-09 20:17:09.102',
        'id': '4651',
        'cards': [
          {'status': 'null','id': '8789','word': 'Key Partners', 'exp': 'Who you are going to cooperate with'},
          {'status': 'null','id': '8669','word': 'Value Propositions', 'exp': 'What benefits you offer to customer'},
          {'status': 'null','id': '8498','word': 'Key Resources', 'exp': 'What you have to accomplish your goal'},
          {'status': 'null','id': '1939','word': 'Revenue Streams', 'exp': 'Where do the incomes come from'},
          {'status': 'null','id': '1899','word': 'Customer Relationship', 'exp': 'How you are going to communicate your customer'},
          {'status': 'null','id': '6542','word': 'Cost Structure', 'exp': 'What kind of outcomes you are going to have'},
        ]
      }
    ]
  },
];

List categories = [];

Future<List> setSharedPrefs() async{
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs = await _prefs;
  var encodedMap = json.encode(data);
  //Set shared preferences if doesn't containg any data
  if(!prefs.containsKey('categories')){
    prefs.setString('categories', encodedMap);
  } else {
    categories = json.decode(prefs.getString('categories').toString());
  }
  print('setSharedPreferences() $categories');
  return categories;
}