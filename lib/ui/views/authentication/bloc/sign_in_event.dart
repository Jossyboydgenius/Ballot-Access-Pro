import 'package:equatable/equatable.dart';

abstract class SignInEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignInSubmitted extends SignInEvent {
  final String email;
  final String password;

  SignInSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
} 