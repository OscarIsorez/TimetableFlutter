import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timetableapp/components/Course_tile.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:timetableapp/components/MyWhiteSpace.dart';
import 'package:timetableapp/components/Timetable.dart';
import 'package:timetableapp/components/WeeklySchedule.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController(initialPage: 0);
  String appBarTitle = 'Schedule';
  List<WeeklySchedule> schedules = [];
  Timetable timetable = Timetable(
      url:
          "https://planning.univ-rennes1.fr/jsp/custom/modules/plannings/o35ex53R.shu");

  Future<void> updateMultipleSchedules() async {
    var tpSchudles = await timetable.generateTimetable();
    setState(() {
      schedules = tpSchudles;
    });
  }

  @override
  void initState() {
    super.initState();
    updateMultipleSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 35),
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
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Hours and courses
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 65,
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

                        // Hours
                        Column(
                          children: [
                            Container(
                              color: Colors.grey[300],
                              padding: const EdgeInsets.all(2),
                              margin: const EdgeInsets.only(bottom: 2, left: 5),
                              alignment: Alignment.center,
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

                // TimeTable
                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      return Row(children: [
                        for (var day in schedules[index].events)
                          if (day.isEmpty)
                            Container(
                                width: 65,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    for (var i = 0; i < 44; i++)
                                      Container(
                                        // 1/44eme de la hauteur du container
                                        height: 15,
                                             // Ajustez la hauteur en fonction de vos besoins
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.green,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                  ],
                                ))
                          else
                            buildDay(day),
                      ]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDay(List<Event> day) {
    List<Widget> columnChildren = [];
    DateTime startingTime =
        DateTime(day[0].start.year, day[0].start.month, day[0].start.day, 7, 0);

    DateTime endingTime = DateTime(
        day[0].start.year, day[0].start.month, day[0].start.day, 19, 0);

    for (var i = startingTime;
        i.isBefore(endingTime);
        i = i.add(const Duration(minutes: 15))) {
      var eventAtTime = day.firstWhere(
        (event) => // we check if event.start is equal to i
            event.start.isAtSameMomentAs(i),
        orElse: () => Event(
            summary: "white",
            description: "",
            start: DateTime.now(),
            end: DateTime.now(),
            location: ""),
      );

      if (eventAtTime.summary != "white") {
        columnChildren.add(
          Container(
            height: eventAtTime.end.difference(eventAtTime.start).inMinutes * 1,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 0.5,
              ),
            ),
            child: Text("${eventAtTime.summary}"),
          ),
        );
        i = eventAtTime.end.subtract(const Duration(minutes: 15));
      } else {
        columnChildren.add(Container(
          height: 10, // Ajustez la hauteur en fonction de vos besoins
          color: Colors.blue[100],
        ));
      }
    }

    return Expanded(
      child: Container(
        width: 65,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        child: Column(
          children: columnChildren,
        ),
      ),
    );
  }
}
