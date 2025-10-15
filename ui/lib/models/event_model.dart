class EventModel {
  final String id;
  final String name;
  final String location;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final int? maxGuests;
  final String type;
  final List<String> imageUrls;

  EventModel({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.description,
    this.maxGuests,
    required this.type,
    this.imageUrls = const [],
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    List<String> _parseImages(dynamic data) {
      if (data is List) {
        return data.map((item) => item.toString()).toList();
      }
      return [];
    }

    return EventModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      type: json['type'] ?? 'Sự kiện mở',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      description: json['description'],
      maxGuests: json['max_guests'],
      // ✅ API trả về là "images_url" hoặc "image_urls"
      imageUrls: _parseImages(json['images_url'] ?? json['image_urls']),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "location": location,
    "status": status,
    "type": type,
    "description": description,
    "max_guests": maxGuests,
    "start_date": startDate.toUtc().toIso8601String(),
    "end_date": endDate.toUtc().toIso8601String(),
    // ✅ API yêu cầu key là "images_url"
    "images_url": imageUrls,
  };
}
