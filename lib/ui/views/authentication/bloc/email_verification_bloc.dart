import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ballot_access_pro/services/auth_service.dart';
import 'package:ballot_access_pro/services/local_storage_service.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'email_verification_event.dart';
import 'email_verification_state.dart';

class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  final AuthService _authService = locator<AuthService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();

  EmailVerificationBloc() : super(const EmailVerificationState()) {
    on<VerifyEmailSubmitted>(_onVerifyEmailSubmitted);
    on<ResendEmailVerification>(_onResendEmailVerification);
  }

  Future<void> _onVerifyEmailSubmitted(
    VerifyEmailSubmitted event,
    Emitter<EmailVerificationState> emit,
  ) async {
    emit(state.copyWith(verificationStatus: EmailVerificationStatus.loading));

    try {
      final response = await _authService.verifyEmail(
        code: event.code,
        userId: event.userId,
      );

      if (response.status && response.data != null) {
        // Save JWT token to local storage
        await _storageService.saveStorageValue(
          LocalStorageKeys.accessToken,
          response.data!.jwt!,
        );

        emit(state.copyWith(
          verificationStatus: EmailVerificationStatus.success,
          user: response.data,
        ));
      } else {
        emit(state.copyWith(
          verificationStatus: EmailVerificationStatus.failure,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        verificationStatus: EmailVerificationStatus.failure,
        errorMessage: 'Incorrect Email Verification Code',
      ));
    }
  }

  Future<void> _onResendEmailVerification(
    ResendEmailVerification event,
    Emitter<EmailVerificationState> emit,
  ) async {
    emit(state.copyWith(resendStatus: ResendEmailStatus.loading));

    try {
      final response = await _authService.resendVerificationEmail(
        userId: event.userId,
      );

      if (response.status) {
        emit(state.copyWith(
          resendStatus: ResendEmailStatus.success,
          user: response.data,
        ));
      } else {
        emit(state.copyWith(
          resendStatus: ResendEmailStatus.failure,
          resendErrorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        resendStatus: ResendEmailStatus.failure,
        resendErrorMessage: 'Failed to resend verification email.',
      ));
    }
  }
} 