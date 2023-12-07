import 'package:timetableapp/components/WeeklySchedule.dart';
import 'package:flutter/material.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:timetableapp/components/WeeklySchedule.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:icalendar_parser/icalendar_parser.dart';

class Timetable {
  String url = "";
  List<WeeklySchedule> schedules = [];

  // ------------------ CONSTRUCTOR ------------------ //

  Timetable({required this.url});

  // ------------------ METHODS ------------------ //

  generateInitSchedles() {

    List<Event> events = [
      Event(
          summary: "the summary",
          description: " the description",
          location: "the location",
          start: DateTime.now(),
          end: DateTime.now()),
      Event(
          summary: "the summary",
          description: " the description",
          location: "the location",
          start: DateTime.now(),
          end: DateTime.now()),
    ];
    WeeklySchedule weekySh = WeeklySchedule(
      monday: events,
      tuesday: events,
      wednesday: events,
      thursday: events,
      friday: events,
    );
    for (var i = 0; i < 10; i++) {
      schedules.add(weekySh);
    }
   
  }

  Future<List<WeeklySchedule>> generateTimetable() async {
    //  extracting data from ics file
    //  and converting it to a list of events
    //  and then adding it to the schedule
    final response = await http.get(Uri.parse(url));

    final body = response.body;

    final file = await writeICSData(body);

    // we fill  the list of events from file
    final icsObj = ICalendar.fromLines(File(file.path).readAsLinesSync());

    // for (var i = 0; i < icsObj.events.length; i++) {
    //   events.add(Event(
    //       start: icsObj.events[i].dtstart,
    //       end: icsObj.events[i].dtend,
    //       location: icsObj.events[i].location,
    //       description: icsObj.events[i].description,
    //       summary: icsObj.events[i].summary));
    // }

    
    // we fill the schedule with the events
    generateInitSchedles();
    
    return schedules;
  }

  Future<File> writeICSData(String data) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/data.ics');
    await file.writeAsString(data);
    return file;
  }
}
