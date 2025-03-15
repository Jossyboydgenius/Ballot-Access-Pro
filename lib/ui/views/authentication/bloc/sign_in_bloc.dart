import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ballot_access_pro/services/auth_service.dart';
import 'package:ballot_access_pro/services/local_storage_service.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'sign_in_event.dart';
import 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthService _authService = locator<AuthService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();

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
        // Save the JWT token to local storage
        await _storageService.saveStorageValue(
          LocalStorageKeys.accessToken,
          response.data!.jwt!,
        );

        emit(state.copyWith(
          status: SignInStatus.success,
          user: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: SignInStatus.failure,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SignInStatus.failure,
        errorMessage: 'Incorrect email or Password',
      ));
    }
  }
} 