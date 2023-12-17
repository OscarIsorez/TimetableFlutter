import 'package:flutter/material.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:timetableapp/components/MySpace.dart';
import 'package:timetableapp/components/Timetable.dart';
import 'package:timetableapp/components/WeeklySchedule.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController(initialPage: 0);
  Timetable timetable = Timetable(
      url:
          "https://planning.univ-rennes1.fr/jsp/custom/modules/plannings/o35ex53R.shu");

  DateTime appBarTitle = Timetable.getMonday(DateTime.now());

  List<WeeklySchedule> schedules = [];

  final TextEditingController _urlController = TextEditingController();

  String currentUrl = "";

  // ignore: constant_identifier_names
  static const GLOBAL_HEIGHT = 14;

  DateTime updateDayWeekDynamic(DateTime newDate) {
    setState(() {
      appBarTitle = newDate;
    });
    return appBarTitle;
  }

  Future<void> updateMultipleSchedules() async {
    var tpSchudles = await timetable.generateTimetable();
    setState(() {
      schedules = tpSchudles;
    });
  }

  void goToFirstWeek() {
    _pageController.animateToPage(0,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);

    updateDayWeekDynamic(Timetable.getMonday(DateTime.now()));
  }

  @override
  void initState() {
    super.initState();
    updateMultipleSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // if the day or month are smaller than 10, we add a 0 before
            // "${appBarTitle.day}/${appBarTitle.month} to ${appBarTitle.add(const Duration(days: 6)).day}/${appBarTitle.add(const Duration(days: 6)).month}",
            "${appBarTitle.day < 10 ? "0${appBarTitle.day}" : appBarTitle.day}/${appBarTitle.month < 10 ? "0${appBarTitle.month}" : appBarTitle.month} to ${appBarTitle.add(const Duration(days: 6)).day < 10 ? "0${appBarTitle.add(const Duration(days: 6)).day}" : appBarTitle.add(const Duration(days: 6)).day}/${appBarTitle.add(const Duration(days: 6)).month < 10 ? "0${appBarTitle.add(const Duration(days: 6)).month}" : appBarTitle.add(const Duration(days: 6)).month}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            )),
        toolbarHeight: 30,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              updateMultipleSchedules();
              // toast "uup to date ! "

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Center(
                      child: Text(
                    "Up to date !",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  duration: const Duration(milliseconds: 1000),
                  backgroundColor: Colors.green[300],
                  elevation: 10,
                  // we add a margin to the toast and borderradius
                  margin: const EdgeInsets.all(10),
                  behavior: SnackBarBehavior.floating,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  animation: CurvedAnimation(
                      parent: const AlwaysStoppedAnimation(1),
                      curve: Curves.easeInOut),
                ),
              );
            },
          ),
          IconButton(
              onPressed: () {
                showChangeUrlDialog();
              },
              icon: const Icon(Icons.link)),
          IconButton(
              onPressed:
                  // go back to the first page
                  () => goToFirstWeek(),
              icon: const Icon(Icons.home))
        ],
      ),
      body: Row(
        children: [
          // Première colonne pour les horaires
          SizedBox(
            width: 40,
            child: Column(
              children: [
                const SizedBox(height: 9),
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
                  Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(bottom: 4),
                    height: GLOBAL_HEIGHT * 4,
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
              ],
            ),
          ),
      
          // Deuxième colonne pour les jours et la PageView
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 15),
                Row(
                  children: [
                    for (var dayWeek in ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'])
                      Flexible(
                        child: Container(
                          height: 22,
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
                    onPageChanged: (int index) {
                      var newAppBarTitle = Timetable.getMonday(DateTime.now())
                          .add(Duration(days: index * 7));
      
                      updateDayWeekDynamic(newAppBarTitle);
                    },
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      return Row(children: [
                        for (var day in schedules[index].events)
                          if (day.isEmpty)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Column(
                                  children: [
                                    for (var i = 0; i < 42; i++)
                                      MySpace(color: Colors.grey[200]),
                                  ],
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
          const SizedBox(width: 5),
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
                  "${event.start.add(const Duration(hours: 1)).hour}:${event.start.minute == 0 ? "00" : event.start.minute}"),
              const SizedBox(height: 3),
              const Text(
                "End",
                style: TextStyle(
                  //underline
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("${event.end.add(
                    const Duration(hours: 1),
                  ).hour}:${event.end.minute == 0 ? "00" : event.end.minute}"),
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
    DateTime startingTime = DateTime(
        day[0].start.year, day[0].start.month, day[0].start.day, 8, 15);

    DateTime endingTime = DateTime(
        day[0].start.year, day[0].start.month, day[0].start.day, 18, 45);

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
          InkWell(
            onTap: () {
              showEventDialog(eventAtTime);
            },
            // may use another widget here
            child: Container(
              padding: const EdgeInsets.all(1),
              height: (GLOBAL_HEIGHT *
                      (eventAtTime.end.difference(eventAtTime.start).inMinutes /
                          15)) +
                  (eventAtTime.end.difference(eventAtTime.start).inMinutes /
                      15),
              decoration: BoxDecoration(
                color: Colors.deepPurple[100],
                borderRadius: const BorderRadius.all(Radius.circular(8)),

                // border: Border.all(
                //   color: Colors.grey,
                //   width: 0.5,
                // ),
              ),
              child: SingleChildScrollView(
                child: Center(
                  child: Text(
                      //
                      "${eventAtTime.summary} ${eventAtTime.location}\n",
                      textAlign: TextAlign.center ,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
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
      child: SizedBox(
        width: 65,
        
        child: Column(
          children: columnChildren,
        ),
      ),
    );
  }

  void showChangeUrlDialog() {
    String newUrl = ""; // Variable pour stocker le nouvel URL

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change URL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newUrl = value;
                },
                decoration: const InputDecoration(labelText: 'Enter New URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newUrl.isNotEmpty) {
                  setState(() {
                    timetable.url = newUrl;
                  });
                  updateMultipleSchedules();
                }
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
