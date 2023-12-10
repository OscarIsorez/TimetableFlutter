
class Event {
  final String summary;
  final String description;
  final DateTime start;
  final DateTime end;
  final String location;

  Event({
    required this.summary,
    required this.description,
    required this.start,
    required this.end,
    required this.location,
  });


  empty(){
    return Event(
      summary: "",
      description: "",
      start: DateTime.now(),
      end: DateTime.now(),
      location: "",
    );
  }

}

