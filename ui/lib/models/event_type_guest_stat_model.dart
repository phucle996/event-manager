class EventTypeGuestStatModel {
  final String eventType;
  final int totalGuests;
  final int checkedIn;

  EventTypeGuestStatModel({
    required this.eventType,
    required this.totalGuests,
    required this.checkedIn,
  });

  factory EventTypeGuestStatModel.fromJson(Map<String, dynamic> json) {
    return EventTypeGuestStatModel(
      eventType: json['event_type'] as String,
      totalGuests: json['total_guests'] as int,
      checkedIn: json['checked_in'] as int,
    );
  }
}
