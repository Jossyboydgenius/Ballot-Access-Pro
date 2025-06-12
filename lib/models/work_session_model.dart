class WorkSessionResponse {
  final List<WorkSession> docs;
  final int totalDocs;
  final int limit;
  final int totalPages;
  final int page;
  final int pagingCounter;
  final bool hasPrevPage;
  final bool hasNextPage;
  final dynamic prevPage;
  final dynamic nextPage;

  WorkSessionResponse({
    required this.docs,
    required this.totalDocs,
    required this.limit,
    required this.totalPages,
    required this.page,
    required this.pagingCounter,
    required this.hasPrevPage,
    required this.hasNextPage,
    this.prevPage,
    this.nextPage,
  });

  factory WorkSessionResponse.fromJson(Map<String, dynamic> json) {
    return WorkSessionResponse(
      docs: (json['docs'] as List).map((e) => WorkSession.fromJson(e)).toList(),
      totalDocs: json['totalDocs'],
      limit: json['limit'],
      totalPages: json['totalPages'],
      page: json['page'],
      pagingCounter: json['pagingCounter'],
      hasPrevPage: json['hasPrevPage'],
      hasNextPage: json['hasNextPage'],
      prevPage: json['prevPage'],
      nextPage: json['nextPage'],
    );
  }
}

class WorkSession {
  final String id;
  final String petitioner;
  final DateTime startTime;
  final DateTime? endTime;
  final WorkLocation startLocation;
  final WorkLocation? endLocation;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkSession({
    required this.id,
    required this.petitioner,
    required this.startTime,
    this.endTime,
    required this.startLocation,
    this.endLocation,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkSession.fromJson(Map<String, dynamic> json) {
    return WorkSession(
      id: json['_id'],
      petitioner: json['petitioner'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      startLocation: WorkLocation.fromJson(json['startLocation']),
      endLocation: json['endLocation'] != null
          ? WorkLocation.fromJson(json['endLocation'])
          : null,
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Calculate duration in hours (for active sessions, use current time)
  String get duration {
    final end = endTime ?? DateTime.now();
    final difference = end.difference(startTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')} hrs';
    } else {
      return '${minutes.toString().padLeft(2, '0')} mins';
    }
  }
}

class WorkLocation {
  final double latitude;
  final double longitude;
  final String? address;

  WorkLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory WorkLocation.fromJson(Map<String, dynamic> json) {
    return WorkLocation(
      latitude: json['latitude'] is int
          ? (json['latitude'] as int).toDouble()
          : json['latitude'],
      longitude: json['longitude'] is int
          ? (json['longitude'] as int).toDouble()
          : json['longitude'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'long': longitude,
      if (address != null) 'address': address,
    };
  }
}
