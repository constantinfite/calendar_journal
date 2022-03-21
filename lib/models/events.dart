class Event {
  int? id;
  String? name;
  String? description;
  String? category;
  int? datetime;
  int? score;

  Event({this.name});

  eventMap() {
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['name'] = name;
    mapping['description'] = description;
    mapping['datetime'] = datetime;
    mapping['score'] = score;
    mapping['category'] = category;

    return mapping;
  }
}
