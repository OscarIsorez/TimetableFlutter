import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
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
import 'package:timetableapp/sharedpreference_helper.dart';

class Timetable {
  // ------------------ ATTRIBUTES ------------------ //
  late DateTime lastUpdate;

  String url = "";
  List<WeeklySchedule> schedules = [];
  // ignore: non_constant_identifier_names
  var all_events = <Event>[];
  var infosToShare = "";
  SharedPreferencesHelper prefs = SharedPreferencesHelper();

  // ------------------ CONSTRUCTOR ------------------ //

  Timetable({required this.url});

  // ------------------ METHODS ------------------ //

  Future<List<WeeklySchedule>> generateEmptySchedules() async {
    return [];
  }

  Future<List<WeeklySchedule>> generateTimetable() async {
    schedules = [];
    all_events = [];
    if (!url.contains("http")) {
      infosToShare = "Please enter a URL";
      return generateEmptySchedules();
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        infosToShare =
            "Error while retrieving timetable,\nStatus-Code : ${response.statusCode}\nWould you like to access a backup?";
        return generateEmptySchedules();
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
      initColorSummaryMap();
    } catch (e) {
      infosToShare = "No network connection, please try again later";
      return generateEmptySchedules();
    }

    return schedules;
  }

  void initColorSummaryMap() async {
    // key : summary, value : index of the color
    for (var i = 0; i < all_events.length; i++) {
      if (prefs.getInt(all_events[i].summary) == null) {
        prefs.setInt(all_events[i].summary,
            (i % AppTheme.listOfColorsForCourses.length));
      }
    }
  }

  Future<File> writeICSData(String data) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/data.ics');
    await file.writeAsString(data);
    return file;
  }

  Future<String?> getStoredUrl() async {
    return prefs.getString('timetable_url');
  }

  Future<void> saveUrlToPreferences(String url) async {
    await prefs.setString('timetable_url', url);
  }

  List<Event> allEventsSorted() {
    List<Event> allEventsS = [];
    allEventsS = all_events;
    allEventsS.sort((a, b) => a.start.compareTo(b.start));
    return allEventsS;
  }

  static DateTime getMonday(DateTime date) {
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

  static DateTime getFirstDate(List<Event> events) {
    return getMonday(events[0].start);
  }

  void buildschedules() {
    all_events = allEventsSorted();

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
        saturday: [],
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

  ///
  /// @param time : DateTime
  /// @return String au format yyyy-MM-dd HH:mm
  String formatTime(DateTime time) {
    // String s =
    return "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    // return s.substring(0, s.length - 5);
  }

  String toJson() {
    String json = "{";

    json += "\"url\": \"$url\",";
    json += "\"lastUpdate\": \"${DateTime.now().toString()}\",";
    json += "\"schedules\": [";

    for (var i = 0; i < schedules.length; i++) {
      json += schedules[i].toJson();
      if (i != schedules.length - 1) {
        json += ",";
      }
    }
    return json + "]}";
  }

  static Timetable fromJson(Map<String, dynamic> json) {
    try {
      Timetable timetable = Timetable(url: json["url"]);
      timetable.lastUpdate = DateTime.parse(json["lastUpdate"]);
      timetable.schedules = [];
      for (var i = 0; i < json["schedules"].length; i++) {
        timetable.schedules.add(WeeklySchedule.fromJson(json["schedules"][i]));
      }
      return timetable;
    } catch (e) {
      // Handle the exception here
      print('Error while parsing JSON: $e');
      return Timetable(url: "");
    }
  }

  Future<void> saveTimetable(Timetable timetable) async {
    // Convert Timetable to JSON and store it as a String
    final timetableJson = timetable.toJson();

    await prefs.setString('timetable', timetableJson);
  }

  Future<Timetable?> loadTimetable() async {
    // Load the JSON string from SharedPreferences and convert it back to a Timetable object
    try {
      final timetableJson = prefs.getString('timetable');

      if (kDebugMode) {
        print('Loaded timetable: $timetableJson');
      }
      if (timetableJson != null) {
        return Timetable.fromJson(jsonDecode(timetableJson));
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error while loading timetable: $e');
      }
      return null;
    }
  }

  int getWeekIndex(DateTime now) {
    /* return the index of the week which now is inside */
    return 0;
  }

  List<Event> getUniqueEvents() {
    List<Event> uniqueEvents = [];

    for (var event in all_events) {
      if (!uniqueEvents.any((element) => element.summary == event.summary)) {
        uniqueEvents.add(event);
      }
    }
    return uniqueEvents;
  }

  List<String> getUniqueSummaryList() {
    List<String> uniqueSummaryList = [];

    for (var event in all_events) {
      if (!uniqueSummaryList.contains(event.summary)) {
        uniqueSummaryList.add(event.summary);
      }
    }
    return uniqueSummaryList;
  }
}
