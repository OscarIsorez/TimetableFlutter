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

  static Event empty() {
    return Event(
      summary: "",
      description: "",
      start: DateTime(0, 0, 0),
      end: DateTime(8000, 8000, 8000),
      location: "",
    );
  }

  String toJson() {
    String json = "{";
    json += "\"summary\": \"$summary\",";
    json += "\"description\": \"$description\",";
    json += "\"start\": \"${start.toIso8601String()}\",";
    json += "\"end\": \"${end.toIso8601String()}\",";
    json += "\"location\": \"$location\"";
    json += "}";
    return json;
  }

  Event.fromJson(Map<String, dynamic> json)
      : summary = json['summary'],
        description = json['description'],
        start = DateTime.parse(json['start']),
        end = DateTime.parse(json['end']),
        location = json['location'];

  @override
  String toString() {
    return "Event{summary: $summary, description: $description, start: $start, end: $end, location: $location}\n";
  }
}
