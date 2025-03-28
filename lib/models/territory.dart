class Territory {
  final String id;
  final String name;
  final String description;
  final String priority;
  final int estimatedHouses;
  final List<TerritoryPetitioner> petitioners;
  final Boundary? boundary;
  final String status;
  final int progress;
  final int totalHousesSigned;
  final int totalHousesVisited;

  Territory({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    required this.estimatedHouses,
    required this.petitioners,
    this.boundary,
    required this.status,
    required this.progress,
    required this.totalHousesSigned,
    required this.totalHousesVisited,
  });

  factory Territory.fromJson(Map<String, dynamic> json) {
    return Territory(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      priority: json['priority'],
      estimatedHouses: json['estimatedHouses'],
      petitioners: (json['petitioners'] as List)
          .map((p) => TerritoryPetitioner.fromJson(p))
          .toList(),
      boundary: json['boundary'] != null ? Boundary.fromJson(json['boundary']) : null,
      status: json['status'],
      progress: json['progress'],
      totalHousesSigned: json['totalHousesSigned'],
      totalHousesVisited: json['totalHousesVisited'],
    );
  }
}

class Boundary {
  final String type;
  final String label;
  final List<PathPoint> paths;

  Boundary({
    required this.type,
    required this.label,
    required this.paths,
  });

  factory Boundary.fromJson(Map<String, dynamic> json) {
    return Boundary(
      type: json['type'] ?? '',
      label: json['label'] ?? '',
      paths: (json['paths'] as List)
          .map((p) => PathPoint.fromJson(p))
          .toList(),
    );
  }
}

class PathPoint {
  final double lat;
  final double lng;

  PathPoint({required this.lat, required this.lng});

  factory PathPoint.fromJson(Map<String, dynamic> json) {
    return PathPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class TerritoryPetitioner {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  TerritoryPetitioner({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory TerritoryPetitioner.fromJson(Map<String, dynamic> json) {
    return TerritoryPetitioner(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
    );
  }
} 