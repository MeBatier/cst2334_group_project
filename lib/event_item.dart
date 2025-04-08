/// A model class representing an event.
class Event {
  /// Event ID from the database.
  int? id;

  /// Name of the event.
  String name;

  /// Location where the event is held.
  String location;

  /// Description or details about the event.
  String description;

  /// Date of the event in YYYY-MM-DD format.
  String date;

  /// Time of the event in HH:MM format.
  String time;

  Event({
    this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.date,
    required this.time,
  });

  /// Converts a Map from the database into an Event object.
  factory Event.fromMap(Map<String, dynamic> json) => Event(
    id: json['id'],
    name: json['name'],
    location: json['location'],
    description: json['description'],
    date: json['date'],
    time: json['time'],
  );

  /// Converts this Event object into a Map for database storage.
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'location': location,
    'description': description,
    'date': date,
    'time': time,
  };
}
