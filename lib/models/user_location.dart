class UserLocation {
  final String id;
  final String name;
  final String photo;
  final double latitude;
  final double longitude;

  UserLocation({
    required this.id,
    required this.name,
    required this.photo,
    required this.latitude,
    required this.longitude,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      photo: json['photo'] as String,
      latitude: double.parse(json['latitude'] as String),
      longitude: double.parse(json['longitude'] as String),
    );
  }
} 