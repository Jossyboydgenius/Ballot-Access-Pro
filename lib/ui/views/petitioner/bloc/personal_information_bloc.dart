import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ballot_access_pro/models/petitioner_model.dart';
import 'package:ballot_access_pro/services/petitioner_service.dart';
import 'package:ballot_access_pro/core/locator.dart';

// Events
abstract class PersonalInformationEvent extends Equatable {
  const PersonalInformationEvent();

  @override
  List<Object?> get props => [];
}

class LoadPersonalInformation extends PersonalInformationEvent {
  const LoadPersonalInformation();
}

// States
enum PersonalInformationStatus { initial, loading, success, failure }

class PersonalInformationState extends Equatable {
  final PersonalInformationStatus status;
  final PetitionerModel? petitioner;
  final String? error;

  const PersonalInformationState({
    this.status = PersonalInformationStatus.initial,
    this.petitioner,
    this.error,
  });

  PersonalInformationState copyWith({
    PersonalInformationStatus? status,
    PetitionerModel? petitioner,
    String? error,
  }) {
    return PersonalInformationState(
      status: status ?? this.status,
      petitioner: petitioner ?? this.petitioner,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, petitioner, error];
}

// Bloc
class PersonalInformationBloc
    extends Bloc<PersonalInformationEvent, PersonalInformationState> {
  final PetitionerService _petitionerService = locator<PetitionerService>();

  PersonalInformationBloc() : super(const PersonalInformationState()) {
    on<LoadPersonalInformation>(_onLoadPersonalInformation);
  }

  Future<void> _onLoadPersonalInformation(
    LoadPersonalInformation event,
    Emitter<PersonalInformationState> emit,
  ) async {
    emit(state.copyWith(status: PersonalInformationStatus.loading));

    try {
      final response = await _petitionerService.getPetitionerProfile();

      if (response.status && response.data != null) {
        emit(state.copyWith(
          status: PersonalInformationStatus.success,
          petitioner: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: PersonalInformationStatus.failure,
          error: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PersonalInformationStatus.failure,
        error: 'Failed to load personal information',
      ));
    }
  }
} 