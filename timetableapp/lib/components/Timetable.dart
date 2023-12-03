import 'package:flutter/material.dart';
import 'package:timetableapp/components/Event.dart';
import 'package:timetableapp/components/WeeklySchedule.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class Timetable {
  final String url;
  List<WeeklySchedule> weeklySchedules = [];

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

  Future<void> fillWeeklySchedules() async {
    print("fillWeeklySchedules");
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/data.json');
    final jsonData = jsonDecode(file.readAsStringSync());

    final sortedJson = sortbyweeks(jsonData);

    print("fillWeeklySchedules done");
  }

  void sortbyweeks(
    jsonData,
  )
  /* 
  @param jsonData : json data from the ics file
  @return a json file with weeks, which will contain the events of each week
   */
  {
    final currentWeek = DateTime.now().weekday;
    final currentDay = DateTime.now().day;
    final currentMonth = DateTime.now().month;

    final currentWeekEvents = [];
  }
}
