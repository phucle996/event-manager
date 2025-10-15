class EventGuestStatModel {
  final String eventId;
  final String eventName;
  final String? location;
  final int totalGuests;
  final int checkedIn;

  const EventGuestStatModel({
    required this.eventId,
    required this.eventName,
    this.location,
    required this.totalGuests,
    required this.checkedIn,
  });

  factory EventGuestStatModel.fromJson(Map<String, dynamic> json) {
    return EventGuestStatModel(
      eventId: (json['event_id'] ?? '').toString(),
      eventName: (json['event_name'] ?? '').toString(),
      location: json['location']?.toString(),
      totalGuests: _toInt(json['total_guests']),
      checkedIn: _toInt(json['checked_in']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
