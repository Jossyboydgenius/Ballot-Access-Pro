// lib/models/lead.dart
class Lead {
  final String id;
  final String name;
  final String address;
  final String? phoneNumber;
  final String notes;
  final String status;

  Lead({
    required this.id,
    required this.name,
    required this.address,
    this.phoneNumber,
    required this.notes,
    required this.status,
  });

  Lead copyWith({
    String? name,
    String? address,
    String? phoneNumber,
    String? notes,
    String? status,
  }) {
    return Lead(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}