class PetitionerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final String address;
  final String? fcmToken;
  final String gender;
  final String? picture;
  final String phone;
  final String status;
  final String type;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime? lastActive;
  final Location location;
  final List<String> territories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int signatures;
  final int pendingRevisits;
  final int housevisited;
  final double successRate;

  PetitionerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
    required this.address,
    this.fcmToken,
    required this.gender,
    this.picture,
    required this.phone,
    required this.status,
    required this.type,
    required this.emailVerified,
    required this.phoneVerified,
    this.lastActive,
    required this.location,
    required this.territories,
    required this.createdAt,
    required this.updatedAt,
    required this.signatures,
    required this.pendingRevisits,
    required this.housevisited,
    required this.successRate,
  });

  factory PetitionerModel.fromJson(Map<String, dynamic> json) {
    return PetitionerModel(
      id: json['_id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      country: json['country'] as String,
      address: json['address'] as String,
      fcmToken: json['fcmToken'] as String?,
      gender: json['gender'] as String,
      picture: json['picture'] as String?,
      phone: json['phone'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      emailVerified: json['emailVerified'] as bool,
      phoneVerified: json['phoneVerified'] as bool,
      lastActive: json['lastActive'] != null ? DateTime.parse(json['lastActive']) : null,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      territories: (json['territories'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      signatures: json['signatures'] as int,
      pendingRevisits: json['pendingRevisits'] as int,
      housevisited: json['housevisited'] as int,
      successRate: json['successRate'] is String 
          ? double.parse(json['successRate'])
          : (json['successRate'] as num).toDouble(),
    );
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
} 