class TerritoryHouses {
  final List<HouseVisit> docs;
  final int totalDocs;
  final int limit;
  final int totalPages;
  final int page;
  final int pagingCounter;
  final bool hasPrevPage;
  final bool hasNextPage;
  final dynamic prevPage;
  final dynamic nextPage;

  TerritoryHouses({
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

  factory TerritoryHouses.fromJson(Map<String, dynamic> json) {
    return TerritoryHouses(
      docs: (json['docs'] as List).map((x) => HouseVisit.fromJson(x)).toList(),
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

class HouseVisit {
  final String id;
  final Petitioner petitioner;
  final String territory;
  final String status;
  final String statusColor;
  final String address;
  final String notes;
  final int registeredVoters;
  final double long;
  final double lat;
  final DateTime createdAt;
  final DateTime updatedAt;

  HouseVisit({
    required this.id,
    required this.petitioner,
    required this.territory,
    required this.status,
    required this.statusColor,
    required this.address,
    required this.notes,
    required this.registeredVoters,
    required this.long,
    required this.lat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HouseVisit.fromJson(Map<String, dynamic> json) {
    return HouseVisit(
      id: json['_id'],
      petitioner: Petitioner.fromJson(json['petitioner']),
      territory: json['territory'],
      status: json['status'],
      statusColor: json['statusColor'],
      address: json['address'],
      notes: json['notes'] ?? '',
      registeredVoters: json['registeredVoters'],
      long: json['long'].toDouble(),
      lat: json['lat'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Petitioner {
  final String id;
  final String firstName;
  final String lastName;

  Petitioner({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory Petitioner.fromJson(Map<String, dynamic> json) {
    return Petitioner(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
} 