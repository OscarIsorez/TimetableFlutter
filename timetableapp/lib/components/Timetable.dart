import 'package:flutter/material.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:timetableapp/components/WeeklySchedule.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:icalendar/icalendar.dart' as ical;

class Timetable {
  final String url;
  String ics_String = "";
  Map<int, WeeklySchedule> weeklySchedules = {};

  List<Event> events = [];

  Timetable({required this.url});

  Future<void> loadData() async {
    final response = await http.get(Uri.parse(url));

    final body = response.body;

    final file = await writeICSData(body);

    // final openFile = await OpenFile.open(file.path);

    final icsObj = ICalendar.fromLines(File(file.path).readAsLinesSync());

    final jsonfile = await writeJSONData(jsonEncode(icsObj.toJson()));

    // final openFile = await OpenFile.open(jsonfile.path);
  }

  Future<File> writeICSData(String data) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/data.ics');
    await file.writeAsString(data);
    return file;
  }

  Future<File> writeJSONData(String data) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/data.json');
    await file.writeAsString(data);
    return file;
  }

  Future<void> convertICStoString() async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/data.ics');
    ics_String = file.readAsStringSync();
  }

  Future<void> convertToListOfEvents() async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/data.json');
    final jsonData = jsonDecode(file.readAsStringSync());
    print(jsonData);
    for (var event in jsonData['events']) {
      events.add(Event(
          summary: event['summary'],
          description: event['description'],
          start: DateTime.parse(event['start']),
          end: DateTime.parse(event['end']),
          location: event['location']));
    }
  }

  int getWeekOfTheDate(DateTime d) {
    /*
      @return the week of the date d (an int between 1 and 52)  
     */

    int week = 1;
    DateTime date = DateTime(d.year, 1, 1);
    while (date.weekday != 1) {
      date = date.add(Duration(days: 1));
    }
    while (date != d) {
      date = date.add(Duration(days: 7));
      week++;
    }
    return week;
  }

  Future<void> fillWeeklySchedules() async {
    await convertToListOfEvents();

    final DateTime date = DateTime.now();

    for (var event in events) {
      int weekOfthedate = getWeekOfTheDate(date);
      if (weeklySchedules.containsKey(weekOfthedate)) {
        weeklySchedules[weekOfthedate]!.addEvent(event);
      } else {
        weeklySchedules[weekOfthedate] = WeeklySchedule(
            monday: [], tuesday: [], wednesday: [], thursday: [], friday: []);
        weeklySchedules[weekOfthedate]!.addEvent(event);
      }
    }
  }
}
