import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:timetableapp/components/Timetable.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timetable timetable = Timetable(
      url:
          'https://planning.univ-rennes1.fr/jsp/custom/modules/plannings/o35ex53R.shu');

  @override
  void initState() {
    super.initState();

    timetable.loadData();
    timetable.fillWeeklySchedules();
  }

  Widget buildScheduleList() {
    return  
    ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: timetable.weeklySchedules.length,
        itemBuilder: (context, index) {
          return buildWeeklySchedule(timetable.weeklySchedules[index]);
        });
  }

  Widget buildWeeklySchedule(weeklySchedule) {
    return Container(
      width: 100,
      child: Column(
        children: [
          for (var event in weeklySchedule.events)
            Container(
              height: 50,
              width: 100,
              color: Colors.grey[300],
              child: Text(event.summary),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.launch),
            onPressed: () => {
              timetable.loadData(),
              timetable.fillWeeklySchedules(),
            },
          ),
        ],
      ),
      body:
          // padding: const EdgeInsets.all(16.0),
          Column(
        children: [
          // Days
          Row(
            children: [
              const SizedBox(width: 65), // Case vide avant le lundi
              for (var day in [
                'Lundi',
                'Mardi',
                'Mercredi',
                'Jeudi',
                'Vendredi'
              ])
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    padding: const EdgeInsets.all(1),
                    child: Center(
                      child:  Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ),
                  ),
                ),
            ],
          ),

          // Hours and courses
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    // height: HEIGHT,
                    color: Colors.grey[300],
                    child: Column(
                      children: [
                        for (var hour in [
                          '8:00',
                          '9:00',
                          '10:00',
                          '11:00',
                          '12:00',
                          '13:00',
                          '14:00',
                          '15:00',
                          '16:00',
                          '17:00',
                          '18:00',
                          '19:00',
                        ])
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                margin:
                                    const EdgeInsets.only(bottom: 2, left: 5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey[300],
                                ),
                                child: Text(
                                  hour,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                height: 28,
                                width: 5,
                                color: Colors.black,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5, // Cette colonne prend plus de place
                  child: Container(
                    // height: HEIGHT,
                    color: Colors.grey,
                    child: buildScheduleList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
