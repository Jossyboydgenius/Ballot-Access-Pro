import 'package:equatable/equatable.dart';
import 'package:ballot_access_pro/models/user_model.dart';

enum SignInStatus { initial, loading, success, failure }

class SignInState extends Equatable {
  final SignInStatus status;
  final UserModel? user;
  final String? errorMessage;

  const SignInState({
    this.status = SignInStatus.initial,
    this.user,
    this.errorMessage,
  });

  SignInState copyWith({
    SignInStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return SignInState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
} 