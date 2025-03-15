import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpSubmitted extends SignUpEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final String address;
  final String gender;
  final String country;

  SignUpSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.gender,
    required this.country,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        password,
        phone,
        address,
        gender,
        country,
      ];
}