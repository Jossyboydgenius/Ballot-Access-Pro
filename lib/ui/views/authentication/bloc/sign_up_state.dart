import 'package:equatable/equatable.dart';
import 'package:ballot_access_pro/models/user_model.dart';

enum SignUpStatus { initial, loading, success, failure }

class SignUpState extends Equatable {
  final SignUpStatus status;
  final UserModel? user;
  final String? errorMessage;

  const SignUpState({
    this.status = SignUpStatus.initial,
    this.user,
    this.errorMessage,
  });

  SignUpState copyWith({
    SignUpStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return SignUpState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}