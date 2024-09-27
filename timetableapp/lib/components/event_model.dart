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

  empty() {
    return Event(
      summary: "",
      description: "",
      start: DateTime.now(),
      end: DateTime.now(),
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
}
