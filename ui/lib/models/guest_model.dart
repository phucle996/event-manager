class GuestModel {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? eventId;

  const GuestModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.eventId,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['name'] ?? '').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      eventId: json['event_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'event_id': eventId,
    };
  }

  bool get hasEmail => (email ?? '').trim().isNotEmpty;

  bool get hasPhone => (phone ?? '').trim().isNotEmpty;

  /// Derives a creation timestamp from the MongoDB ObjectID if possible.
  DateTime? get createdAt {
    if (id.length != 24) return null;
    final timestampHex = id.substring(0, 8);
    final seconds = int.tryParse(timestampHex, radix: 16);
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    ).toLocal();
  }
}
