import 'package:equatable/equatable.dart';

abstract class EmailVerificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class VerifyEmailSubmitted extends EmailVerificationEvent {
  final String code;
  final String userId;

  VerifyEmailSubmitted({
    required this.code,
    required this.userId,
  });

  @override
  List<Object?> get props => [code, userId];
}

class ResendEmailVerification extends EmailVerificationEvent {
  final String userId;

  ResendEmailVerification({required this.userId});

  @override
  List<Object?> get props => [userId];
} 