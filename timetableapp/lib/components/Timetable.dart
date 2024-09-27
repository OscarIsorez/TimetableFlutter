import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timetableapp/components/App_Theme.dart';
import 'package:timetableapp/components/weekly_schedule_model.dart';
import 'package:timetableapp/components/event_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetableapp/utils.dart';

class Timetable {
  // ------------------ ATTRIBUTES ------------------ //
  static Map<String, Color> myColors = {};
  DateTime lastUpdate = DateTime.now();

  String url = "";
  List<WeeklySchedule> schedules = [];
  // ignore: non_constant_identifier_names
  var all_events = <Event>[];
  var infosToShare = "";

  // ------------------ CONSTRUCTOR ------------------ //

  Timetable({required this.url});

  // ------------------ METHODS ------------------ //

  void initMapOfColors(List<Event> events, List<Color?> colors) {
    myColors.clear();

    var shuffledColors = List.from(colors)..shuffle();
    var index = 0;
    for (var event in events) {
      if (index == shuffledColors.length) {
        index = 0;
      }
      if (myColors.containsKey(event.summary.substring(0, 3))) {
        continue;
      }
      if (event.summary.contains("CC")) {
        myColors.putIfAbsent(event.summary.substring(0, 3), () => Colors.red);
      } else {
        myColors.putIfAbsent(
            event.summary.substring(0, 3), () => shuffledColors[index]!);
      }
      index++;
    }
  }

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
        if (response.statusCode == 404) {
          infosToShare = "Error 404, URL not found";
        } else if (response.statusCode == 403) {
          infosToShare = "Error 403, Forbidden access";
        } else if (response.statusCode == 500) {
          infosToShare =
              "Internal server error.\nThat's not your fault, try again later ! ";
        } else {
          infosToShare =
              "Error while retrieving timetable,\nStatus-Code : ${response.statusCode}\nWould you like to access a backup?";
        }
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
      initMapOfColors(all_events, AppTheme.listOfColorsForCourses);
    } catch (e) {
      infosToShare = "No network connection, please try again later";
      return generateEmptySchedules();
    }

    return schedules;
  }

  Future<void> saveUrlToPreferences(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('timetable_url', url);
  }

  void buildschedules() {
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
    return "$json]}";
  }

  void fromJson(Map<String, dynamic> json) {
    url = json['url'];
    lastUpdate = DateTime.parse(json['lastUpdate']);
    schedules = [];
    for (var i = 0; i < json['schedules'].length; i++) {
      WeeklySchedule schedule = WeeklySchedule.empty();
      schedule = WeeklySchedule.fromJson(json['schedules'][i]);
      schedules.add(schedule);
    }
  }

  Future<void> saveTimetable(Timetable timetable) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert Timetable to JSON and store it as a String
    final timetableJson = timetable.toJson();

    prefs.setString('timetable', timetableJson);
  }

  void loadTimetable() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final timetableJson = prefs.getString('timetable');
      if (kDebugMode) {
        print('Loaded timetable: $timetableJson');
      }

      if (timetableJson != null) {
        final Map<String, dynamic> timetableMap = jsonDecode(timetableJson);
        fromJson(timetableMap);
      } else {
        if (kDebugMode) {
          print('No timetable found in shared preferences');
        }
      }
    } catch (e) {
      // Handle the exception here
      if (kDebugMode) {
        print('Error loading timetable: $e');
      }
      return null;
    }
  }
}
