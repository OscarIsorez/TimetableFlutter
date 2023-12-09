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
    //  extracting data from ics file
    //  and converting it to a list of events
    //  and then adding it to the schedule
    final response = await http.get(Uri.parse(url));

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
          end: icsObj.data[i]['dtend'].toDateTime()!);

      all_events.add(event);
    }

    // we build the list of WeeklySchedle with the list of all the event we created just before
    buildschedules();
    return schedules;
  }

  List<Event> all_events_sorted() {
    List<Event> allEventsS = [];
    allEventsS = all_events;
    allEventsS.sort((a, b) => a.start.compareTo(b.start));
    return allEventsS;
  }

  DateTime getMonday(DateTime date) {
    // we get the monday of the week of the date
    DateTime monday = date;
    while (monday.weekday != 1) {
      if (monday.weekday == 7 || monday.weekday == 6) {
        monday = monday.add(const Duration(days: 1));
      } else {
        monday = monday.subtract(const Duration(days: 1));
      }
    }
    return monday;
  }

  void buildschedules() {
    /* we create a list of WeeklySchedule containing every event in all_events based on there start day.
    for instance, the first week will be the current week and the second week will be the next week. etc
    we check the start day of each event and add it to the corresponding WeeklySchedule 
     */
    var allEventsS = all_events_sorted();

    DateTime now = getMonday(DateTime.now());
    print(now);

    var start = now;

    for (var i = 0; i < 52; i++) {
      // weektofill will be between now, and now+i*7 days
      DateTime weektofillStart = start;
      DateTime weektofillEnd = now.add(Duration(days: i * 7));

      // we create a WeeklySchedule for the week we are filling
      WeeklySchedule weektofill = WeeklySchedule(
        monday: [],
        tuesday: [],
        wednesday: [],
        thursday: [],
        friday: [],
      );

      // we fill the WeeklySchedule with the events that are between weektofill_start and weektofill_end
      for (var j = 0; j < allEventsS.length; j++) {
        if (allEventsS[j].start.isAfter(weektofillStart) &&
            allEventsS[j].start.isBefore(weektofillEnd)) {
          weektofill.addEvent(allEventsS[j]);
        }
      }

      // we add the WeeklySchedule to the list of schedules
      schedules.add(weektofill);

      // we update the start of the next week
      start = now.add(Duration(days: i * 7));
    }
  }

  Future<File> writeICSData(String data) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/data.ics');
    await file.writeAsString(data);
    return file;
  }
}
