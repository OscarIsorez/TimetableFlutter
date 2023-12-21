import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:timetableapp/components/App_Theme.dart';
import 'package:timetableapp/components/WeeklySchedule.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:timetableapp/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Timetable {
  // ------------------ ATTRIBUTES ------------------ //
  static Map<String, Color> MyColors = {};

  String url = "";
  List<WeeklySchedule> schedules = [];
  // ignore: non_constant_identifier_names
  var all_events = <Event>[];

  // ------------------ CONSTRUCTOR ------------------ //

  Timetable({required this.url});

  // ------------------ METHODS ------------------ //


  void initMapOfColors(List<Event> events, List<Color?> colors) {
    print("intiMapOfColors");
    MyColors.clear();

    var shuffledColors = List.from(colors)..shuffle();
    var index = 0;
    for (var event in events) {
      if (index == shuffledColors.length) {
        index = 0;
      }
      if (event.summary.contains("CC")) {
        MyColors.putIfAbsent(event.summary.substring(0, 3), () => Colors.red);
      } else {
        MyColors.putIfAbsent(
            event.summary.substring(0, 3), () => shuffledColors[index]!);
      }
      index++;
    }
    print("event.length : ${events.length}");
  }

  Future<List<WeeklySchedule>> generateTimetable() async {
    

    schedules = [];
    all_events = [];


    final response = await http.get(Uri.parse(url));

    print("generateTimetable() called ${response.statusCode}");
    print(url);

    if (response.statusCode != 200) {
      return schedules;
    }

    final body = response.body;

    final file = await writeICSData(body);

    final icsObj = ICalendar.fromLines(File(file.path).readAsLinesSync());

    for (var i = 0; i < icsObj.data.length; i++) {
      Event event = Event(
          summary: icsObj.data[i]['summary'].replaceAll("G4", ""),
          description: icsObj.data[i]['description'],
          location: icsObj.data[i]['location'],
          start: icsObj.data[i]['dtstart'].toDateTime()!,
          // .add(const Duration(hours: 1)),
          end: icsObj.data[i]['dtend'].toDateTime()!);
      // .add(const Duration(hours: 1)));

      all_events.add(event);
    }
    buildschedules();
    initMapOfColors(all_events, AppTheme.listOfColorsForCourses);


    return schedules;
  }

  // Méthode pour récupérer l'URL stockée dans les préférences partagées
  Future<String?> getStoredUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('timetable_url');
  }

  // Méthode pour sauvegarder l'URL dans les préférences partagées
  Future<void> saveUrlToPreferences(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('timetable_url', url);
  }

  // ignore: non_constant_identifier_names
  List<Event> all_events_sorted() {
    List<Event> allEventsS = [];
    allEventsS = all_events;
    allEventsS.sort((a, b) => a.start.compareTo(b.start));
    return allEventsS;
  }

  static DateTime getMonday(DateTime date) {
    // we get the monday of the week of the date
    DateTime currentday = date;
    while (currentday.weekday != 1) {
      if (currentday.weekday == 7 || currentday.weekday == 6) {
        currentday = currentday.add(const Duration(days: 1));
      } else {
        currentday = currentday.subtract(const Duration(days: 1));
      }
    }
    return DateTime(currentday.year, currentday.month, currentday.day, 7);
  }

  void buildschedules() {
    all_events = all_events_sorted();

    DateTime start = getMonday(DateTime.now());

    for (var i = 0; i < 52; i++) {
      DateTime weektofillStart = start;
      DateTime weektofillEnd = weektofillStart.add(const Duration(days: 6));

      WeeklySchedule weektofill = WeeklySchedule(
        monday: [],
        tuesday: [],
        wednesday: [],
        thursday: [],
        friday: [],
      );

      for (var j = 0; j < all_events.length; j++) {
        if (all_events[j].start.isAfter(weektofillStart) &&
            all_events[j].end.isBefore(weektofillEnd)) {
          weektofill.addEvent(all_events[j]);
        }
      }
      schedules.add(weektofill);
      start = start.add(const Duration(days: 7));
    }
  }

  Future<File> writeICSData(String data) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/data.ics');
    await file.writeAsString(data);
    return file;
  }
}
