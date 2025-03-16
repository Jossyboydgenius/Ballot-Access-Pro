import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ballot_access_pro/models/lead_model.dart';
import 'package:ballot_access_pro/services/petitioner_service.dart';
import 'package:ballot_access_pro/core/locator.dart';

// Events
abstract class LeadsEvent extends Equatable {
  const LeadsEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeads extends LeadsEvent {
  const LoadLeads();
}

// States
enum LeadsStatus { initial, loading, success, failure }

class LeadsState extends Equatable {
  final LeadsStatus status;
  final LeadResponse? leads;
  final String? error;

  const LeadsState({
    this.status = LeadsStatus.initial,
    this.leads,
    this.error,
  });

  LeadsState copyWith({
    LeadsStatus? status,
    LeadResponse? leads,
    String? error,
  }) {
    return LeadsState(
      status: status ?? this.status,
      leads: leads ?? this.leads,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, leads, error];
}

// Bloc
class LeadsBloc extends Bloc<LeadsEvent, LeadsState> {
  final PetitionerService _petitionerService = locator<PetitionerService>();

  LeadsBloc() : super(const LeadsState()) {
    on<LoadLeads>(_onLoadLeads);
  }

  Future<void> _onLoadLeads(
    LoadLeads event,
    Emitter<LeadsState> emit,
  ) async {
    emit(state.copyWith(status: LeadsStatus.loading));

    try {
      final response = await _petitionerService.getLeads();
      if (response.status && response.data != null) {
        emit(state.copyWith(
          status: LeadsStatus.success,
          leads: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: LeadsStatus.failure,
          error: response.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LeadsStatus.failure,
        error: 'Failed to load leads',
      ));
    }
  }
} 