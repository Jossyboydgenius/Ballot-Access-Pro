import 'package:ballot_access_pro/shared/navigation/app_routes.dart';
import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ballot_access_pro/services/petitioner_service.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:ballot_access_pro/services/local_storage_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import 'package:flutter/foundation.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final PetitionerService _petitionerService = locator<PetitionerService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();

  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final token = await _storageService.getStorageValue(LocalStorageKeys.accessToken);
      if (token == null) {
        emit(state.copyWith(
          status: ProfileStatus.failure,
          error: 'Not authenticated. Please sign in again.',
        ));
        NavigationService.pushReplacementNamed(AppRoutes.signInView);
        return;
      }

      debugPrint('Getting petitioner profile');
      final response = await _petitionerService.getPetitionerProfile();

      if (response.status && response.data != null) {
        debugPrint('Profile data received: ${response.data}');
        emit(state.copyWith(
          status: ProfileStatus.success,
          petitioner: response.data,
        ));
      } else {
        debugPrint('Profile fetch failed: ${response.message}');
        if (response.statusCode == 401) {
          await _storageService.clearToken();
          NavigationService.pushReplacementNamed(AppRoutes.signInView);
        }
        emit(state.copyWith(
          status: ProfileStatus.failure,
          error: response.message,
        ));
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading profile: $e\n$stackTrace');
      emit(state.copyWith(
        status: ProfileStatus.failure,
        error: 'Failed to load profile',
      ));
    }
  }

  Future<void> _onSignOut(
    SignOut event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _storageService.clearToken();
      emit(state.copyWith(status: ProfileStatus.initial));
      NavigationService.pushReplacementNamed(AppRoutes.signInView);
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        error: 'Failed to sign out',
      ));
    }
  }
} 