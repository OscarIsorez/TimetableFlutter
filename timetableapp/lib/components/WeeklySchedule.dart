import 'package:timetableapp/components/Event.dart';

class WeeklySchedule {
  List<Event> monday = [];
  List<Event> tuesday = [];
  List<Event> wednesday = [];
  List<Event> thursday = [];
  List<Event> friday = [];

  WeeklySchedule(
      {required this.monday,
      required this.tuesday,
      required this.wednesday,
      required this.thursday,
      required this.friday});

  List<List<Event>> get events {
    return [monday,tuesday,wednesday,thursday,friday];
  }

  void addEvent(Event event) {
    switch (event.start.weekday) {
      case 1:
        monday.add(event);
        break;
      case 2:
        tuesday.add(event);
        break;
      case 3:
        wednesday.add(event);
        break;
      case 4:
        thursday.add(event);
        break;
      case 5:
        friday.add(event);
        break;
      default:
        break;
    }
  }

  void sortEvents() {
    monday.sort((a, b) => a.start.compareTo(b.start));
    tuesday.sort((a, b) => a.start.compareTo(b.start));
    wednesday.sort((a, b) => a.start.compareTo(b.start));
    thursday.sort((a, b) => a.start.compareTo(b.start));
    friday.sort((a, b) => a.start.compareTo(b.start));
  }

  void removeEvent(Event event) {
    switch (event.start.weekday) {
      case 1:
        monday.remove(event);
        break;
      case 2:
        tuesday.remove(event);
        break;
      case 3:
        wednesday.remove(event);
        break;
      case 4:
        thursday.remove(event);
        break;
      case 5:
        friday.remove(event);
        break;
      default:
        break;
    }
  }

  static WeeklySchedule fromJson(Map<String, dynamic> json) {
    
    return WeeklySchedule(
      monday: json['monday'],
      tuesday: json['tuesday'],
      wednesday: json['wednesday'],
      thursday: json['thursday'],
      friday: json['friday'],
    );
  }

  String toJson() {
    String json = "{";
    json += "\"monday\": [";
    for (var i = 0; i < monday.length; i++) {
      json += monday[i].toJson();
      if (i != monday.length - 1) {
        json += ",";
      }
    }
    json += "],";
    json += "\"tuesday\": [";
    for (var i = 0; i < tuesday.length; i++) {
      json += tuesday[i].toJson();
      if (i != tuesday.length - 1) {
        json += ",";
      }
    }
    json += "],";
    json += "\"wednesday\": [";
    for (var i = 0; i < wednesday.length; i++) {
      json += wednesday[i].toJson();
      if (i != wednesday.length - 1) {
        json += ",";
      }
    }
    json += "],";
    json += "\"thursday\": [";
    for (var i = 0; i < thursday.length; i++) {
      json += thursday[i].toJson();
      if (i != thursday.length - 1) {
        json += ",";
      }
    }
    json += "],";
    json += "\"friday\": [";
    for (var i = 0; i < friday.length; i++) {
      json += friday[i].toJson();
      if (i != friday.length - 1) {
        json += ",";
      }
    }
    json += "]}";
    return json;
  }


}
