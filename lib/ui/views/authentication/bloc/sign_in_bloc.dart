import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ballot_access_pro/services/auth_service.dart';
import 'package:ballot_access_pro/services/local_storage_service.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:ballot_access_pro/services/fcm_service.dart';
import 'package:flutter/material.dart';
import 'sign_in_event.dart';
import 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthService _authService = locator<AuthService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final FCMService _fcmService = locator<FCMService>();

  SignInBloc() : super(const SignInState()) {
    on<SignInSubmitted>(_onSignInSubmitted);
  }

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    emit(state.copyWith(status: SignInStatus.loading));

    try {
      final response = await _authService.login(
        email: event.email,
        password: event.password,
      );

      if (response.status && response.data != null) {
        // Save both JWT token and user ID
        await _storageService.saveStorageValue(
          LocalStorageKeys.accessToken,
          response.data!.jwt!,
        );

        // Save user ID too if available
        await _storageService.saveStorageValue(
          LocalStorageKeys.userId,
          response.data!.id!,
        );

        // Update FCM token after successful login
        try {
          debugPrint('Updating FCM token after successful login');
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
          status: SignInStatus.success,
          user: response.data,
        ));
      } else {
        // Use the error message from the API response
        emit(state.copyWith(
          status: SignInStatus.failure,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SignInStatus.failure,
        errorMessage: 'Incorrect email or password.',
      ));
    }
  }
}
