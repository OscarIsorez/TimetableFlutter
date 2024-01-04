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


}
