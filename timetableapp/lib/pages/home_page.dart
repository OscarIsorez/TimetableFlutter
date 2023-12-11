import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timetableapp/components/Course_tile.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:timetableapp/components/MySpace.dart';
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
                        // MySpace(color: Colors.grey[200], flex: 2),
                        const SizedBox(height: 18,),

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
                        Expanded(
                          child: Column(
                            children: [
                              // MySpace(color: Colors.grey[200]),
                              Container(
                                alignment: Alignment.centerRight,
                                color: Colors.white,
                                child: Text(
                                  "$hour-",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              MySpace(color: Colors.grey[200], flex: 2,),
                              MySpace(color: Colors.grey[200], flex: 2),
                              MySpace(color: Colors.grey[200], flex: 2),
                            ],
                          ),
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
                                    for (var i = 0; i < 45; i++)
                                      MySpace(color: Colors.grey[200]),
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

  void showEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event.summary),
          content: Text(
              "${event.description}\n${event.location}\n${event.start}\n${event.end}"),
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //     child: const Text('Close'),
          //   ),
          // ],
        );
      },
    );
  }

  Widget buildDay(List<Event> day) {
    List<Widget> columnChildren = [
      MySpace(
        color: Colors.grey[200],
      )
    ];
    DateTime startingTime =
        DateTime(day[0].start.year, day[0].start.month, day[0].start.day, 8, 0);

    DateTime endingTime = DateTime(
        day[0].start.year, day[0].start.month, day[0].start.day, 19, 0);

    for (var i = startingTime;
        i.isBefore(endingTime);
        i = i.add(const Duration(minutes: 15))) {
      var eventAtTime = day.firstWhere(
        (event) => event.start.isBefore(i) && event.end.isAfter(i),
        orElse: () => Event(
            summary: "",
            description: "",
            start: DateTime.now(),
            end: DateTime.now(),
            location: ""),
      );

      if (eventAtTime.summary != "") {
        columnChildren.add(
          Expanded(
            flex: eventAtTime.end.difference(eventAtTime.start).inMinutes %
                        15 ==
                    0
                ? eventAtTime.end.difference(eventAtTime.start).inMinutes ~/ 15
                : eventAtTime.end.difference(eventAtTime.start).inMinutes ~/
                        15 +
                    1,
            child: InkWell(
              onTap: () {
                showEventDialog(eventAtTime);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellow[200],
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
                child: Text(
                    "${eventAtTime.summary} ${eventAtTime.start.day}/${eventAtTime.start.month} ${eventAtTime.start.hour}:${eventAtTime.start.minute}",
                    style: const TextStyle(
                      color: Colors.black,
                    )),
              ),
            ),
          ),
        );
        i = eventAtTime.end;
      } else {
        columnChildren.add(MySpace(
          color: Colors.grey[200],
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
