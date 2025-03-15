import 'package:equatable/equatable.dart';
import 'package:ballot_access_pro/models/user_model.dart';

enum EmailVerificationStatus { initial, loading, success, failure }
enum ResendEmailStatus { initial, loading, success, failure }

class EmailVerificationState extends Equatable {
  final EmailVerificationStatus verificationStatus;
  final ResendEmailStatus resendStatus;
  final UserModel? user;
  final String? errorMessage;
  final String? resendErrorMessage;

  const EmailVerificationState({
    this.verificationStatus = EmailVerificationStatus.initial,
    this.resendStatus = ResendEmailStatus.initial,
    this.user,
    this.errorMessage,
    this.resendErrorMessage,
  });

  EmailVerificationState copyWith({
    EmailVerificationStatus? verificationStatus,
    ResendEmailStatus? resendStatus,
    UserModel? user,
    String? errorMessage,
    String? resendErrorMessage,
  }) {
    return EmailVerificationState(
      verificationStatus: verificationStatus ?? this.verificationStatus,
      resendStatus: resendStatus ?? this.resendStatus,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      resendErrorMessage: resendErrorMessage ?? this.resendErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        verificationStatus,
        resendStatus,
        user,
        errorMessage,
        resendErrorMessage,
      ];
} 