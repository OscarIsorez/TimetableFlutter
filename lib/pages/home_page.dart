// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:timetableapp/components/MySpace.dart';
import 'package:timetableapp/components/SnackBarPopUp.dart';
import 'package:timetableapp/components/Timetable.dart';
import 'package:timetableapp/components/WeeklySchedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String start = "8:00";
  final String end = "21:00";

  static Future<String?> selectUrlFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('url') ?? "";
    if (url.isNotEmpty) {
      return url;
    } else {
      return null;
    }
  }

  // ignore: non_constant_identifier_names
  static String SetUrlFromStorage() {
    selectUrlFromStorage().then((value) => value);
    return selectUrlFromStorage().toString();
  }

  Timetable timetable = Timetable(url: SetUrlFromStorage());

  final PageController _pageController = PageController(initialPage: 0);

  DateTime appBarTitle = Timetable.getMonday(DateTime.now());

  List<WeeklySchedule> schedules = [];

  final TextEditingController _urlController = TextEditingController();

  Color? mygrey = Colors.grey[100];

  static const double globalHeight = 15;

  Timetable? timetableBackup;
  bool isVAlide(String url) {
    return url.contains("https://") || url.contains("http://") ? true : false;
  }

  @override
  initState() {
    super.initState();
    updateMultipleSchedules();
    timetableBackup = timetable;

    // if (kDebugMode) {
    // print(start.split(":")[0]);
    // }
    // if (kDebugMode) {
    //   print(end.split(":")[0]);
    // }
  }

  static int getCurrentWeekIndex(timetable) {
    return timetable.getWeekIndex(DateTime.now());
  }

  DateTime updateDayWeekDynamic(DateTime newDate) {
    setState(() {
      appBarTitle = newDate;
    });
    return appBarTitle;
  }

  Future<List<WeeklySchedule>> updateMultipleSchedules() async {
    final storedUrl = await timetable.getStoredUrl();

    final urlToUse = storedUrl ?? timetable.url;

    timetable.url = urlToUse;

    var newSchedule = await timetable.generateTimetable();

    if (newSchedule.isNotEmpty) {
      setState(() {
        schedules = newSchedule;
      });
      timetable.saveTimetable(timetable);
      SnackBarPopUp.callSnackBar(
          "Timetable up to date", context, Colors.green[300]);
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(timetable.infosToShare),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
              // (timetableBackup != null)
              //     ? TextButton(
              //         child: const Text('Load backup'),
              //         onPressed: () async {
              //           Timetable? timetableBackup =
              //               await timetable.loadTimetable();
              //           if (timetableBackup != null) {
              //             setState(() {
              //               schedules = timetableBackup.schedules;
              //             });
              //             SnackBarPopUp.callSnackBar(
              //                 "Backup loaded", context, Colors.green[300]);

              //             Navigator.pop(context);
              //           } else {
              //             SnackBarPopUp.callSnackBar(
              //                 "No backup found", context, Colors.red[300]);
              //             Navigator.pop(context);
              //           }

              //           Navigator.pop(context);
              //         },
              //       )
              // : Container(
              //     // child: Text(timetableBackup.toString()),
              //     ),
            ],
          );
        },
      );
    }
    return schedules;
  }

  void goToFirstWeek() {
    _pageController.animateToPage(0,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    updateDayWeekDynamic(Timetable.getMonday(DateTime.now()));
  }

  Widget buildTimetable(WeeklySchedule schedule) {
    return Row(children: [
      for (var day in schedule.events)
        if (day.isEmpty)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                children: [
                  for (var i = 0; i < 52; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Container(
                        height: 15,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: mygrey),
                      ),
                    )
                ],
              ),
            ),
          )
        else
          buildDay(day),
    ]);
  }

  String generateLastUpdateString() {
    if (timetable.lastUpdate != null) {
      return "${timetable.lastUpdate.day < 10 ? "0${timetable.lastUpdate.day}" : timetable.lastUpdate.day}/${timetable.lastUpdate.month < 10 ? "0${timetable.lastUpdate.month}" : timetable.lastUpdate.month} at ${timetable.lastUpdate!.hour < 10 ? "0${timetable.lastUpdate!.hour}" : timetable.lastUpdate.hour}:${timetable.lastUpdate.minute < 10 ? "0${timetable.lastUpdate.minute}" : timetable.lastUpdate.minute}";
    } else {
      return "";
    }
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
              Text(event.location),
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
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  //underline
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(event.description.toString().replaceAll(RegExp("\n"), " ")),
              const SizedBox(height: 3),
            ],
          ),
        );
      },
    );
  }

  Widget buildDay(List<Event> day) {
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
    ];

    List<Widget> columnChildren = [];
    DateTime startingTime = DateTime(
        day[0].start.year, day[0].start.month, day[0].start.day, 8, 15);

    DateTime endingTime = DateTime(
        day[0].start.year, day[0].start.month, day[0].start.day, 21, 15);

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
        eventAtTime.location = eventAtTime.location.replaceAll(toremove, "");
      }

      if (eventAtTime.summary != "") {
        columnChildren.add(
          InkWell(
            onTap: () {
              showEventDialog(eventAtTime);
            },
            child: Container(
              // on centre le contenu
              alignment: Alignment.center,

              padding: const EdgeInsets.only(
                left: 2,
                right: 2,
              ),
              height: (globalHeight *
                      (eventAtTime.end.difference(eventAtTime.start).inMinutes /
                          15)) +
                  (eventAtTime.end.difference(eventAtTime.start).inMinutes /
                      15),
              decoration: BoxDecoration(
                color: eventAtTime.summary.contains("CC")
                    ? Colors.red
                    : Timetable.MyColors[eventAtTime.summary.substring(0, 3)],
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Text(
                          // overflow: TextOverflow.visible,
                          "${eventAtTime.summary}\n",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          )),
                    ),
                    Text(
                      // overflow: TextOverflow.visible,
                      "${eventAtTime.location}\n",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        i = eventAtTime.end;
      } else {
        columnChildren.add(MySpace(
          color: mygrey,
          height: 15,
        ));
      }
    }

    return Flexible(
      flex: 1,
      child: Column(
        children: columnChildren,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              // margin : const EdgeInsets.only(top: 2),
              child: Text(
                "${appBarTitle.day < 10 ? "0${appBarTitle.day}" : appBarTitle.day}/${appBarTitle.month < 10 ? "0${appBarTitle.month}" : appBarTitle.month} to ${appBarTitle.add(const Duration(days: 4)).day < 10 ? "0${appBarTitle.add(const Duration(days: 4)).day}" : appBarTitle.add(const Duration(days: 4)).day}/${appBarTitle.add(const Duration(days: 4)).month < 10 ? "0${appBarTitle.add(const Duration(days: 4)).month}" : appBarTitle.add(const Duration(days: 4)).month}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        toolbarHeight: 36,
        backgroundColor: Colors.grey[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_downward),
            onPressed: () async {
              Timetable? timetableBackup = await timetable.loadTimetable();
              if (timetableBackup != null) {
                setState(() {
                  schedules = timetableBackup.schedules;
                });
                print("Backup from ${timetableBackup.lastUpdate} loaded");
                SnackBarPopUp.callSnackBar(
                    "Backup from ${timetableBackup.lastUpdate} loaded",
                    context,
                    Colors.green[300]);
              } else {
                SnackBarPopUp.callSnackBar(
                    "No backup found", context, Colors.red[300]);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              updateMultipleSchedules();
            },
          ),
          IconButton(
              onPressed: () {
                showChangeUrlDialog(context);
              },
              icon: const Icon(Icons.link)),
          IconButton(
              onPressed:
                  // go back to the first page
                  () => goToFirstWeek(),
              icon: const Icon(Icons.home))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              // Première colonne pour les horaires
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    const SizedBox(height: 13),
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
                      '20:00',
                      '21:00'
                    ])
                      Column(
                        children: [
                          Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.only(bottom: 1),
                            height: globalHeight,
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
                          MySpace(color: Colors.white, height: globalHeight),
                          MySpace(color: Colors.white, height: globalHeight),
                          MySpace(color: Colors.white, height: globalHeight),
                        ],
                      ),
                  ],
                ),
              ),

              // Deuxième colonne pour les jours et la PageView
              Expanded(
                child: Container(
                  height: 920,
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          for (var dayWeek in [
                            'Lun',
                            'Mar',
                            'Mer',
                            'Jeu',
                            'Ven'
                          ])
                            Flexible(
                              flex: 1,
                              child: Container(
                                height: 22,
                                // width: 60,
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
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (int index) {
                            DateTime newDate = Timetable.getMonday(
                                DateTime.now().add(Duration(days: index * 7)));
                            updateDayWeekDynamic(newDate);
                          },
                          itemCount: schedules.length,
                          itemBuilder: (context, index) {
                            return buildTimetable(schedules[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }

  void showChangeUrlDialog(BuildContext context) {
    String newUrl = ""; // Variable pour stocker le nouvel URL

    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text('Change URL'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    newUrl = value;
                  },
                  decoration: InputDecoration(
                      labelText: 'Enter New URL',
                      hintText:
                          "https://planning.univ-rennes1.fr/jsp/custom/modules/plannings/6YP8G1Yv.shu",
                      //  we want the hint text to be black
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      hintMaxLines: 1),
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
                  if (newUrl.isNotEmpty && isVAlide(newUrl)) {
                    setState(() {
                      timetable.url = newUrl;
                    });
                    updateMultipleSchedules();
                    timetable.saveUrlToPreferences(newUrl);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Center(
                            child: Text(
                          "Link up to date !",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        duration: const Duration(milliseconds: 500),
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
                  }
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }
}
