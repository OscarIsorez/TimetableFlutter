import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timetableapp/components/App_Theme.dart';
import 'dart:io';

import 'package:timetableapp/components/Event.dart';
import 'package:timetableapp/components/WeeklySchedule.dart';

class TimetableProvider extends ChangeNotifier {
  String _url = "";
  DateTime _lastUpdate = DateTime.now();
  List<WeeklySchedule> _schedules = [];
  List<Event> _allEvents = [];
  String _infosToShare = "";
  Map<String, Color> _colorsMap = {};

  String get url => _url;
  DateTime get lastUpdate => _lastUpdate;
  List<WeeklySchedule> get schedules => _schedules;
  List<Event> get allEvents => _allEvents;
  String get infosToShare => _infosToShare;
  Map<String, Color> get colorsMap => _colorsMap;

  set schedules(List<WeeklySchedule> schedules) {
    _schedules = schedules;
  }

  Future<void> initTimetable() async {
    _url = await getStoredUrl() ?? "";
    await generateTimetable();
  }

  Future<String?> getStoredUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('timetable_url');
  }

  Future<void> saveUrlToPreferences(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('timetable_url', url);
  }

  Future<void> generateTimetable() async {
    _schedules = [];
    _allEvents = [];
    if (!_url.contains("http")) {
      _infosToShare = "Please enter a URL";
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode != 200) {
        _infosToShare =
            "Error while retrieving timetable,\nStatus-Code : ${response.statusCode}\nWould you like to access a backup?";
        notifyListeners();
        return;
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
            end: icsObj.data[i]['dtend'].toDateTime()!);
        _allEvents.add(event);
      }
      _buildSchedules();
      _initMapOfColors(_allEvents, AppTheme.listOfColorsForCourses);
      _lastUpdate = DateTime.now();
      notifyListeners();
    } catch (e) {
      _infosToShare = "No network connection, please try again later";
      notifyListeners();
    }
  }

  void _buildSchedules() {
    List<Event> sortedEvents = _allEventsSorted();

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

      for (var j = 0; j < sortedEvents.length; j++) {
        if (sortedEvents[j].start.isAfter(weektofillStart) &&
            sortedEvents[j].end.isBefore(weektofillEnd)) {
          weektofill.addEvent(sortedEvents[j]);
        }
      }
      _schedules.add(weektofill);
      start = start.add(const Duration(days: 7));
    }
  }

  void _initMapOfColors(List<Event> events, List<Color?> colors) {
    _colorsMap.clear();

    var shuffledColors = List.from(colors)..shuffle();
    var index = 0;
    for (var event in events) {
      if (index == shuffledColors.length) {
        index = 0;
      }
      if (_colorsMap.containsKey(event.summary.substring(0, 3))) {
        continue;
      }
      if (event.summary.contains("CC")) {
        _colorsMap[event.summary.substring(0, 3)] = Colors.red;
      } else {
        _colorsMap[event.summary.substring(0, 3)] = shuffledColors[index];
      }
      index++;
    }
  }

  List<Event> _allEventsSorted() {
    List<Event> allEventsS = List.from(_allEvents);
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

  Future<File> writeICSData(String data) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/data.ics');
    await file.writeAsString(data);
    return file;
  }

  String formatTime(DateTime time) {
    return "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String toJson() {
    String json = "{";

    json += "\"url\": \"$_url\",";
    json += "\"lastUpdate\": \"${_lastUpdate.toString()}\",";
    json += "\"schedules\": [";

    for (var i = 0; i < _schedules.length; i++) {
      json += _schedules[i].toJson();
      if (i != _schedules.length - 1) {
        json += ",";
      }
    }
    return json + "]}";
  }

  static TimetableProvider fromJson(Map<String, dynamic> json) {
    try {
      TimetableProvider timetableProvider = TimetableProvider();
      timetableProvider._url = json["url"];
      timetableProvider._lastUpdate = DateTime.parse(json["lastUpdate"]);
      timetableProvider._schedules = [];
      for (var i = 0; i < json["schedules"].length; i++) {
        timetableProvider._schedules
            .add(WeeklySchedule.fromJson(json["schedules"][i]));
      }
      return timetableProvider;
    } catch (e) {
      // Handle the exception here
      print('Error while parsing JSON: $e');
      return TimetableProvider();
    }
  }

  Future<void> saveTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final timetableJson = toJson();
    prefs.setString('timetable', timetableJson);
  }

  Future<TimetableProvider?> loadTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final timetableJson = prefs.getString('timetable');
    if (timetableJson != null) {
      return TimetableProvider.fromJson(jsonDecode(timetableJson));
    } else {
      return null;
    }
  }

  List<Event> getUniqueEvents() {
    List<Event> uniqueEvents = [];
    for (var event in _allEvents) {
      if (!uniqueEvents.any((element) => element.summary == event.summary)) {
        uniqueEvents.add(event);
      }
    }
    return uniqueEvents;
  }

  List<String> getUniqueSummaryList() {
    List<String> uniqueSummaryList = [];
    for (var event in _allEvents) {
      if (!uniqueSummaryList.contains(event.summary)) {
        uniqueSummaryList.add(event.summary);
      }
    }
    return uniqueSummaryList;
  }
}
