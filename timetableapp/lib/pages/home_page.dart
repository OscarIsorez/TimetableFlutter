import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:timetableapp/pages/Data.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Data data = new Data(
      icsUrl:
          'https://planning.univ-rennes1.fr/jsp/custom/modules/plannings/o35ex53R.shu');

  @override
  void initState() {
    super.initState();
    data.extractDataFromLink();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Weekly Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 50), // Case vide avant le lundi
                for (var day in ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'])
                  Expanded(
                    child: Center(
                      child: Text(day),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                // Colonne des heures de la journée
                Expanded(
                  child: Column(
                    children: [
                      for (var hour in ['8:00', '9:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00'])
                        Text(hour),
                    ],
                  ),
                ),
                SizedBox(width: 20), // Espace entre les deux colonnes
                // Colonne des cours avec la couleur de fond
                Expanded(
                  flex: 2, // Cette colonne prend plus de place
                  child: Column(
                    children: [
                      // Exemple de cours avec couleur de fond bleue
                      CourseItem('Cours 1', '8:00 - 9:00', Colors.blue),
                      CourseItem('Cours 2', '10:00 - 11:00', Colors.blue),
                      CourseItem('Cours 3', '14:00 - 15:00', Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CourseItem extends StatelessWidget {
  final String title;
  final String time;
  final Color backgroundColor;

  const CourseItem(this.title, this.time, this.backgroundColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(10),
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(time),
        ],
      ),
    );
  }
}