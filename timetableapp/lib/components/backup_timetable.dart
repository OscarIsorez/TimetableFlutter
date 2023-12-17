import 'package:flutter/material.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:timetableapp/components/WeeklySchedule.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class backup_timetable {
  final String url;
  String ics_String = "";
  Map<int, WeeklySchedule> weeklySchedules = {};


  List<Event> events = [];

  backup_timetable({required this.url});

  Future<void> loadData() async {
    final response = await http.get(Uri.parse(url));

    final body = response.body;

    final file = await writeICSData(body);

    // final openFile = await OpenFile.open(file.path);



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
    for (var event in jsonData['data']) {
      events.add(Event(
          summary: event['summary'],
          description: event['description'],
          start: DateTime.parse(event['dtstart']['dt']),
          end: DateTime.parse(event['dtend']['dt']),
          location: event['location']));
    }
  }

  int getWeekOfTheDate(DateTime d) {
    /*
      @return the week of the date d (an int between 1 and 52)  
     */
    int weekOfTheDate = 1;
    DateTime date = DateTime(d.year, 1, 1);
    while (date != d) {
      date = date.add(const Duration(days: 1));
      if (date.weekday == 1) {
        weekOfTheDate++;
      }
      if (weekOfTheDate == 53) {
        weekOfTheDate = 1;
        break;
      }
    }

    return weekOfTheDate;
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



  

  Widget buildDay(List<Event> day) {
    /* 
      will return a column. this column will be composed with grey spaces, and the events
      we will start the day at 8.0, and finish at 19.0. we will increment by O.25
      if the event equals the hour, we will add the event and will calculate the height of the event by the difference between the start and the end ( modulo 0.25)
      if the event is not equal to the hour, we will add a grey space and increment the hour by 0.25

      for intance: day = [coursefrom8h15To9h, coursefrom9h15To10h]
      we will have a column starting with one grey space, then the first event which will be 3 grey spaces high, then 1 grey space, then the second event which will be 3 grey spaces high, then 36 grey spaces bc we are at 10h and we need to go to 19h
      antoher instance: day = [coursefrom10to11h30] we will start with 8 grey spaces, then the event which will be 6 grey spaces high, then 30 grey spaces bc we are at 11h30 and we need to go to 19h
     */

    // We will start at 8.0 and finish at 19.0
    double hour = 8.0;

    // We will increment by 0.25
    double increment = 0.25;

    
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        padding: const EdgeInsets.all(1),
        child: Column(
          children: [
            for (var event in day)
              Column(
                children: [
                  // Grey spaces
                  Container(
                    height: (event.start.hour - hour) * 4 * 7,
                    width: 100,
                    color: Colors.grey[300],
                  ),

                  // Event
                  Container(
                    height: (event.end.hour - event.start.hour) * 4 * 7,
                    width: 100,
                    color: Colors.blue,
                    child: Center(
                      child: Text(
                        event.summary,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Grey spaces
                  Container(
                    height: (19.0 - event.end.hour) * 4 * 7,
                    width: 100,
                    color: Colors.grey[300],
                  ),
                ],
              ),
          ],
        ),
      ),
    );





    



  }

  Widget buildWeeklySchedule(WeeklySchedule weeklySchedule) {
    return SizedBox(
      width: 100,
      child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return buildDay(weeklySchedule.events[index]);
          }),
    );
  }

}
