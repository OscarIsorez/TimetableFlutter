

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timetableapp/components/Event.dart';


class Data {
  String icsUrl;

  Data({required this.icsUrl});


  @override
  String toString() {
    return 'Data{icsUrl: $icsUrl}';
  }

  extractDataFromLink(){
    /* 
    @return a list of events
     */
    fetchICalData(icsUrl);
  }

  Future<void> fetchICalData(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final iCalData = response.body;
      final iCalEvents = parseICalendar(iCalData);

      // setState(() {
      //   events = iCalEvents;
      // });
    } else {
      throw Exception('Failed to load iCalendar data');
    }
  }

  List<Event> parseICalendar(String iCalData) {
    final events = <Event>[];

    final lines = LineSplitter.split(iCalData).toList();

    String summary = '';
    String description = '';
    DateTime start = DateTime.now();
    DateTime end = DateTime.now();
    String location = '';

    for (var line in lines) {
      if (line.startsWith('SUMMARY:')) {
        summary = line.substring('SUMMARY:'.length);
      } else if (line.startsWith('DESCRIPTION:')) {
        description = line.substring('DESCRIPTION:'.length);
      } else if (line.startsWith('DTSTART:')) {
        start = DateTime.parse(line.substring('DTSTART:'.length));
      } else if (line.startsWith('DTEND:')) {
        end = DateTime.parse(line.substring('DTEND:'.length));
      } else if (line.startsWith('LOCATION:')) {
        location = line.substring('LOCATION:'.length);

        final event = Event(
          summary: summary,
          description: description,
          start: start,
          end: end,
          location: location,
        );

        events.add(event);
      }
    }

    return events;
  }

}