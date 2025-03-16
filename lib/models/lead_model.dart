class LeadResponse {
  final List<LeadModel> docs;
  final int totalDocs;
  final int limit;
  final int totalPages;
  final int page;
  final int pagingCounter;
  final bool hasPrevPage;
  final bool hasNextPage;
  final dynamic prevPage;
  final dynamic nextPage;

  LeadResponse({
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

  factory LeadResponse.fromJson(Map<String, dynamic> json) {
    return LeadResponse(
      docs: (json['docs'] as List).map((e) => LeadModel.fromJson(e)).toList(),
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

class LeadModel {
  final String id;
  final String? address;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? note;
  final LeadPetitioner petitioner;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LeadVisit? visit;

  LeadModel({
    required this.id,
    this.address,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.note,
    required this.petitioner,
    required this.createdAt,
    required this.updatedAt,
    this.visit,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['_id'],
      address: json['address'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      note: json['note'],
      petitioner: LeadPetitioner.fromJson(json['petitioner']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      visit: json['visit'] != null ? LeadVisit.fromJson(json['visit']) : null,
    );
  }
}

class LeadPetitioner {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final String address;
  final String? picture;
  final String phone;

  LeadPetitioner({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
    required this.address,
    this.picture,
    required this.phone,
  });

  factory LeadPetitioner.fromJson(Map<String, dynamic> json) {
    return LeadPetitioner(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      country: json['country'],
      address: json['address'],
      picture: json['picture'],
      phone: json['phone'],
    );
  }
}

class LeadVisit {
  final String id;
  final String status;
  final double long;
  final double lat;

  LeadVisit({
    required this.id,
    required this.status,
    required this.long,
    required this.lat,
  });

  factory LeadVisit.fromJson(Map<String, dynamic> json) {
    return LeadVisit(
      id: json['_id'],
      status: json['status'],
      long: json['long'].toDouble(),
      lat: json['lat'].toDouble(),
    );
  }
} 