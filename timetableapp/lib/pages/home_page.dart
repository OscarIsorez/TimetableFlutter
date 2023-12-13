import 'package:flutter/material.dart';
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
  String dayWeekDynamic = "";
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

  String updateDayWeek(String s) {
    setState(() {
      dayWeekDynamic = s;
    });

    return dayWeekDynamic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Première colonne pour les horaires
          SizedBox(
            width: 65,
            child: Column(
              children: [
                const SizedBox(height: 65),
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
                ])
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.white,
                      child: Text(
                        "$hour-",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Deuxième colonne pour les jours et la PageView
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 25),
                // Row pour les jours
                Row(
                  children: [
                    for (var dayWeek in ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'])
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                          ),
                          padding: const EdgeInsets.all(1),
                          child: Center(
                            child: Text(
                              maxLines: 1,
                              dayWeek,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // PageView pour les événements
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      return Row(children: [
                        for (var day in schedules[index].events)
                          if (day.isEmpty)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Container(
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
                                  ),
                                ),
                              ),
                            )
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Location",
                style: TextStyle(
                  //underline
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(event.location.substring(3)),
              const SizedBox(height: 3),
              const Text(
                "Start",
                style: TextStyle(
                  //underline
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                  "${event.start.hour}:${event.start.minute == 0 ? "00" : event.start.minute}"),
              const SizedBox(height: 3),
              const Text(
                "End",
                style: TextStyle(
                  //underline
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                  "${event.end.hour}:${event.end.minute == 0 ? "00" : event.end.minute}"),
              const SizedBox(height: 3),
              const Text(
                "Description",
                style: TextStyle(
                  //underline
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(event.description),
              const SizedBox(height: 3),
            ],
          ),
        );
      },
    );
  }

  Widget buildDay(List<Event> day) {
    // updateDayWeek(day[0].start.day.toString());

    List<String> patternsToRemove = [
      "(006)",
      "(001)",
      "(002)",
      "(003)",
      "(004)",
      "(005)",
      "(007)",
      "(008)",
      "(009)",
      "(010)",
      "(011)",
      "(012)",
      "(013)",
      "(014)",
      "(015)",
      "(016)",
      "Linux",
      "ISTIC",
      "(",
      ")",
      "Prioritaire",
      "200",
      "201",
      "202",
      "203",
      "204",
      "205",
      "206",
      "207",
      "208",
      "209",
      "210",
      "211",
      "212",
      "213",
      "214",
      "215",
      "216",
      "217",
      "218",
      "219",
      "220"
    ];

    List<Widget> columnChildren = [];
    DateTime startingTime =
        DateTime(day[0].start.year, day[0].start.month, day[0].start.day, 9, 0);

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

      for (String toremove in patternsToRemove) {
        eventAtTime.summary = eventAtTime.summary.replaceAll(toremove, "");
        eventAtTime.location = eventAtTime.location.replaceAll(toremove, "");
      }

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

              // may use another widget here
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[100],
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Text(
                      //
                      "${eventAtTime.summary} ${eventAtTime.location}\n${eventAtTime.start.hour}:${eventAtTime.start.minute == 0 ? "00" : eventAtTime.start.minute}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      )),
                ),
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
