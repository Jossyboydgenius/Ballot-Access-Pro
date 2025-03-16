class HouseVisitResponse {
  final List<HouseVisitModel> docs;
  final int totalDocs;
  final int limit;
  final int totalPages;
  final int page;
  final int pagingCounter;
  final bool hasPrevPage;
  final bool hasNextPage;
  final dynamic prevPage;
  final dynamic nextPage;

  HouseVisitResponse({
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

  factory HouseVisitResponse.fromJson(Map<String, dynamic> json) {
    return HouseVisitResponse(
      docs: (json['docs'] as List).map((e) => HouseVisitModel.fromJson(e)).toList(),
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

class HouseVisitModel {
  final String id;
  final VisitVoter? voter;
  final VisitPetitioner petitioner;
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

  HouseVisitModel({
    required this.id,
    this.voter,
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

  factory HouseVisitModel.fromJson(Map<String, dynamic> json) {
    return HouseVisitModel(
      id: json['_id'],
      voter: json['voter'] != null ? VisitVoter.fromJson(json['voter']) : null,
      petitioner: VisitPetitioner.fromJson(json['petitioner']),
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

class VisitVoter {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  VisitVoter({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  factory VisitVoter.fromJson(Map<String, dynamic> json) {
    return VisitVoter(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

class VisitPetitioner {
  final String id;
  final String firstName;
  final String lastName;

  VisitPetitioner({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory VisitPetitioner.fromJson(Map<String, dynamic> json) {
    return VisitPetitioner(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
} 