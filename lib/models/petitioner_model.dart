class PetitionerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final String address;
  final List<String> fcmToken;
  final String gender;
  final String? picture;
  final String phone;
  final String status;
  final String type;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime? lastActive;
  final Location? location;
  final List<Territory> territories;
  final Settings? settings;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
    required this.fcmToken,
    required this.gender,
    this.picture,
    required this.phone,
    required this.status,
    required this.type,
    required this.emailVerified,
    required this.phoneVerified,
    this.lastActive,
    this.location,
    required this.territories,
    this.settings,
    this.createdAt,
    this.updatedAt,
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
      fcmToken: json['fcmToken'] != null 
          ? (json['fcmToken'] as List<dynamic>).map((e) => e as String).toList()
          : <String>[],
      gender: json['gender'] as String,
      picture: json['picture'] as String?,
      phone: json['phone'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      emailVerified: json['emailVerified'] as bool,
      phoneVerified: json['phoneVerified'] as bool,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      location: json['location'] != null 
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      territories: json['territories'] != null
          ? (json['territories'] as List<dynamic>)
              .map((e) => Territory.fromJson(e as Map<String, dynamic>))
              .toList()
          : <Territory>[],
      settings: json['settings'] != null
          ? Settings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      signatures: json['signatures'] as int? ?? 0,
      pendingRevisits: json['pendingRevisits'] as int? ?? 0,
      housevisited: json['housevisited'] as int? ?? 0,
      successRate: json['successRate'] is String
          ? double.parse(json['successRate'])
          : (json['successRate'] as num).toDouble(),
    );
  }

  // Add a helper method to get the currently assigned territory
  Territory? get assignedTerritory {
    return territories.isNotEmpty ? territories.first : null;
  }

  // Add a method to get the assigned territory ID or an empty string if none
  String get assignedTerritoryId {
    return assignedTerritory?.id ?? '';
  }

  // Add a method to get the assigned territory name or "No Territory" if none
  String get assignedTerritoryName {
    return assignedTerritory?.name ?? 'No Territory';
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

class Territory {
  final String id;
  final String name;
  final String description;
  final String priority;
  final int estimatedHouses;
  final List<String> petitioners;
  final Boundary boundary;
  final DateTime createdAt;
  final DateTime updatedAt;

  Territory({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    required this.estimatedHouses,
    required this.petitioners,
    required this.boundary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Territory.fromJson(Map<String, dynamic> json) {
    return Territory(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      estimatedHouses: json['estimatedHouses'] as int,
      petitioners: (json['petitioners'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      boundary: Boundary.fromJson(json['boundary'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Add toString method to allow Territory to be used as String
  @override
  String toString() {
    return name;
  }

  // Add getter for territory ID for easier access
  String get territoryId => id;
}

class Boundary {
  final String type;
  final String label;
  final List<Path> paths;

  Boundary({
    required this.type,
    required this.label,
    required this.paths,
  });

  factory Boundary.fromJson(Map<String, dynamic> json) {
    return Boundary(
      type: json['type'] as String,
      label: json['label'] as String,
      paths: (json['paths'] as List<dynamic>)
          .map((e) => Path.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Path {
  final String id;
  final double lat;
  final double lng;

  Path({
    required this.id,
    required this.lat,
    required this.lng,
  });

  factory Path.fromJson(Map<String, dynamic> json) {
    return Path(
      id: json['_id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class Settings {
  final bool emailNotification;
  final bool inAppNotification;
  final bool locationTrackingEnabled;

  Settings({
    required this.emailNotification,
    required this.inAppNotification,
    required this.locationTrackingEnabled,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      emailNotification: json['emailNotification'] as bool,
      inAppNotification: json['inAppNotification'] as bool,
      locationTrackingEnabled: json['locationTrackingEnabled'] as bool? ?? true,
    );
  }
}
