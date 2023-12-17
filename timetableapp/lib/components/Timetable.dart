import 'package:flutter/material.dart';
import 'package:timetableapp/components/WeeklySchedule.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:icalendar_parser/icalendar_parser.dart';

class Timetable {
  String url = "";
  List<WeeklySchedule> schedules = [];
  List<Event> all_events = [];

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
      tuesday: [],
      wednesday: events,
      thursday: events,
      friday: events,
    );
    for (var i = 0; i < 3; i++) {
      schedules.add(weekySh);
    }
  }

  Future<List<WeeklySchedule>> generateTimetable() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      AlertDialog(
        title: const Text('Error'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Error while fetching data'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Retry'),
            onPressed: () {
              generateTimetable();
            },
          ),
        ],
      );
      return <WeeklySchedule>[];
    }

    final body = response.body;

    final file = await writeICSData(body);

    // we fill  the list of events from file
    final icsObj = ICalendar.fromLines(File(file.path).readAsLinesSync());

    for (var i = 0; i < icsObj.data.length; i++) {
      Event event = Event(
          summary: icsObj.data[i]['summary'],
          description: icsObj.data[i]['description'],
          location: icsObj.data[i]['location'],
          start: icsObj.data[i]['dtstart'].toDateTime()!,
          // .add(const Duration(hours: 1)),
          end: icsObj.data[i]['dtend'].toDateTime()!
          );
      // .add(const Duration(hours: 1)));

      all_events.add(event);
    }

    buildschedules();

    return schedules;
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
    // print(start.toString());

    for (var i = 0; i < 52; i++) {
      // weektofill will be between now, and now+i*7 days
      DateTime weektofillStart = start;
      DateTime weektofillEnd = weektofillStart.add(const Duration(days: 6));
      // print(weektofillStart.toString());

      // we create a WeeklySchedule for the week we are filling
      WeeklySchedule weektofill = WeeklySchedule(
        monday: [],
        tuesday: [],
        wednesday: [],
        thursday: [],
        friday: [],
      );

      // we fill the WeeklySchedule with the events that are between weektofill_start and weektofill_end
      for (var j = 0; j < all_events.length; j++) {
        if (all_events[j].start.isAfter(weektofillStart) &&
            all_events[j].end.isBefore(weektofillEnd)) {
          weektofill.addEvent(all_events[j]);
        }
      }

      // we add the WeeklySchedule to the list of schedules
      schedules.add(weektofill);

      // we update the start of the next week
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
