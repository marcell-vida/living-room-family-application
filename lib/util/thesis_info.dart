import 'package:flutter/material.dart';

/// egy függvény, ami visszaad egy [Column] objektumot
///
/// opcionális paraméterként egy [Icon] objektumot fogad
Widget _columnOfElements({Icon? icon}){

  // Widget objektumok listája
  List<Widget> listOfWidgets = <Widget>[
    const Text('Hello World!'),
    Container(color: Colors.purple, height: 20, width: 20),
  ];

  // String objektumok listája
  List<String> listOfStrings = <String>[
    'First',
    'Second',
    'Third'
  ];

  return Column(
    children: [
      // terjesztés (spread) operátor használata beilleszti ide
      // a korábbi listOfWidgets listát
      ...listOfWidgets,

      // végigiterálunk a listOfStrings listán és minden
      // alkalommal hozzáadunk egy Text objektumot a listához,
      // mely a listOfStrings lista aktuális elemét jelzi majd ki
      for(String element in listOfStrings)
        Text(element),

      // amennyiben a függvény opcionális icon paramétere
      // nem null akkor azt is hozzáadjuk a listához
      if(icon != null) icon
    ],
  );
}