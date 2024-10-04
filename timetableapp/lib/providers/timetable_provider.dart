import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:timetableapp/components/App_Theme.dart';
import 'package:timetableapp/components/event_model.dart';
import 'package:timetableapp/components/weekly_schedule_model.dart';
import 'package:timetableapp/utils.dart';

class ScheduleProvider with ChangeNotifier {
  List<WeekSchedule> _schedules = [];
  List<Event> _allEvents = [];
  String _url =
      "https://planning.univ-rennes1.fr/jsp/custom/modules/plannings/pn8Z8l38.shu";
  String _infosToShare = "";
  String _backupSchedule = '';
  late DateTime _lastUpdate;
  late DateTime _latestCourse = DateTime(1900, 1, 1, 8, 0);
  late DateTime _earliestCourse = DateTime(2900, 1, 1, 8, 0);
  Map<String, Color> myColors = {};

  List<WeekSchedule> get schedules => _schedules;
  String get infosToShare => _infosToShare;
  String get url => _url;

  // The courses with the latest and earliest hours
  DateTime get latestCourse => _latestCourse;
  DateTime get earliestCourse => _earliestCourse;

  set url(String newUrl) {
    _url = newUrl;
    notifyListeners();
  }

  Future<void> fetchSchedule() async {
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final body = response.body;
        final file = await writeICSData(body);
        final icsObj = ICalendar.fromLines(File(file.path).readAsLinesSync());

        _allEvents = [];
        for (var eventData in icsObj.data) {
          Event event = Event(
              summary: eventData['summary'],
              description: eventData['description'],
              location: eventData['location'],
              start: eventData['dtstart'].toDateTime()!,
              end: eventData['dtend'].toDateTime()!);
          _allEvents.add(event);
          _updateLatestAndEarliestCourseHours(event.start, event.end);
        }
        if (kDebugMode) {
          print("earliest course: $_earliestCourse");
          print("latest course: $_latestCourse");
        }

        buildSchedules();
        initMapOfColors(_allEvents, AppTheme.listOfColorsForCourses);

        _backupSchedule = body;
        await saveBackupToPreferences(_backupSchedule);
        notifyListeners();
      } else {
        _infosToShare = _handleHttpError(response.statusCode);
        loadBackup();
      }
    } catch (e) {
      _infosToShare = "No network connection, please try again later.";
      loadBackup();
    }
  }

  Future<File> writeICSData(String data) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/data.ics');
    await file.writeAsString(data);
    return file;
  }

  void buildSchedules() {
    _schedules = [];
    DateTime start = getMonday(DateTime.now());

    for (var i = 0; i < 52; i++) {
      DateTime weekStart = start;
      DateTime weekEnd = weekStart.add(const Duration(days: 6));

      WeekSchedule week = WeekSchedule(
        monday: [],
        tuesday: [],
        wednesday: [],
        thursday: [],
        friday: [],
      );

      for (var event in _allEvents) {
        if (event.start.isAfter(weekStart) && event.end.isBefore(weekEnd)) {
          week.addEvent(event);
        }
      }
      _schedules.add(week);
      start = start.add(const Duration(days: 7));
    }
  }

  void initMapOfColors(List<Event> events, List<Color?> colors) {
    var shuffledColors = List.from(colors)..shuffle();
    var index = 0;

    for (var event in events) {
      if (index == shuffledColors.length) index = 0;
      if (!myColors.containsKey(event.summary)) {
        myColors.putIfAbsent(
            event.summary,
            () => event.summary.contains("CC")
                ? Colors.red
                : shuffledColors[index]!);
        index++;
      }
    }
  }

  Color getCourseColor(String courseName) {
    return myColors[courseName] ?? Colors.grey;
  }

  Future<void> saveBackupToPreferences(String backup) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('backup_schedule', backup);
  }

  Future<void> loadBackup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? backup = prefs.getString('backup_schedule');
    if (backup != null) {
      try {
        final icsObj = ICalendar.fromString(backup);
        _allEvents = [];
        for (var eventData in icsObj.data) {
          Event event = Event(
              summary: eventData['summary'],
              description: eventData['description'],
              location: eventData['location'],
              start: eventData['dtstart'].toDateTime()!,
              end: eventData['dtend'].toDateTime()!);
          _allEvents.add(event);
        }
        buildSchedules();
        notifyListeners();
      } catch (e) {
        _infosToShare = "Error loading backup schedule.";
      }
    }
  }

  String _handleHttpError(int statusCode) {
    switch (statusCode) {
      case 404:
        return "Error 404, URL not found.";
      case 403:
        return "Error 403, Forbidden access.";
      case 500:
        return "Internal server error.";
      default:
        return "Error retrieving timetable, Status-Code: $statusCode";
    }
  }

  Future<void> saveTimetableToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final timetableJson = toJson();
    prefs.setString('timetable', timetableJson);
  }

  String toJson() {
    return jsonEncode({
      "url": _url,
      "lastUpdate": _lastUpdate.toString(),
      "schedules": _schedules.map((schedule) => schedule.toJson()).toList(),
    });
  }

  void _updateLatestAndEarliestCourseHours(DateTime start, DateTime end) {
    // we want to get the earliest hour and the lastest hour of the whole schedule
    if (start.hour < _earliestCourse.hour) {
      _earliestCourse = start;
    }
    if (end.hour > _latestCourse.hour) {
      _latestCourse = end;
    }
  }
}
