import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ballot_access_pro/services/auth_service.dart';
import 'package:ballot_access_pro/services/local_storage_service.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:ballot_access_pro/services/fcm_service.dart';
import 'package:flutter/material.dart';
import 'sign_up_event.dart';
import 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthService _authService = locator<AuthService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final FCMService _fcmService = locator<FCMService>();

  SignUpBloc() : super(const SignUpState()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(state.copyWith(status: SignUpStatus.loading));

    try {
      final response = await _authService.register(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        phone: event.phone,
        address: event.address,
        gender: event.gender,
        country: event.country,
      );

      if (response.status && response.data != null) {
        if (response.data!.jwt != null) {
          await _storageService.saveStorageValue(
            LocalStorageKeys.accessToken,
            response.data!.jwt!,
          );
        }

        await _storageService.saveStorageValue(
          LocalStorageKeys.userId,
          response.data!.id,
        );

        // Update FCM token after successful registration
        try {
          debugPrint('Updating FCM token after successful registration');
          String? fcmToken = await _fcmService.getToken();

          if (fcmToken != null) {
            final updated = await _fcmService.updateTokenOnServer(fcmToken);
            debugPrint('FCM token update result: $updated');
          } else {
            debugPrint('No FCM token available to update');
          }
        } catch (e) {
          debugPrint('Error updating FCM token: $e');
          // Continue even if FCM token update fails
        }

        emit(state.copyWith(
          status: SignUpStatus.success,
          user: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: SignUpStatus.failure,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SignUpStatus.failure,
        errorMessage: 'An unexpected error occurred. Please try again.',
      ));
    }
  }
}
