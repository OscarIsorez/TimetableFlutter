
class Event {
  String summary;
  String description;
  DateTime start;
  DateTime end;
  String location;

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

  Event.fromJson(Map<String, dynamic> json)
      : summary = json['summary'],
        description = json['description'],
        start = json['start'].toDateTime()!,
        end = json['end'].toDateTime()!,
        location = json['location'];

}

