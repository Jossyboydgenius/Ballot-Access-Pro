import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ballot_access_pro/services/work_service.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:flutter/foundation.dart';
import 'work_event.dart';
import 'work_state.dart';

class WorkBloc extends Bloc<WorkEvent, WorkState> {
  final WorkService _workService = locator<WorkService>();

  WorkBloc() : super(const WorkState()) {
    on<CheckWorkSession>(_onCheckWorkSession);
    on<StartWorkSession>(_onStartWorkSession);
    on<EndWorkSession>(_onEndWorkSession);
  }

  Future<void> _onCheckWorkSession(
    CheckWorkSession event,
    Emitter<WorkState> emit,
  ) async {
    emit(state.copyWith(status: WorkStatus.loading));

    try {
      final response = await _workService.getActiveWorkSession();

      if (response.status && response.data != null) {
        emit(state.copyWith(
          status: WorkStatus.active,
          activeSession: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: WorkStatus.inactive,
        ));
      }
    } catch (e) {
      debugPrint('Error checking work session: $e');
      emit(state.copyWith(
        status: WorkStatus.inactive,
        errorMessage: 'Failed to check work session status',
      ));
    }
  }

  Future<void> _onStartWorkSession(
    StartWorkSession event,
    Emitter<WorkState> emit,
  ) async {
    emit(state.copyWith(status: WorkStatus.loading));

    try {
      final response = await _workService.startWork(
        longitude: event.longitude,
        latitude: event.latitude,
        address: event.address,
      );

      if (response.status && response.data != null) {
        emit(state.copyWith(
          status: WorkStatus.active,
          activeSession: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: WorkStatus.failure,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      debugPrint('Error starting work session: $e');
      emit(state.copyWith(
        status: WorkStatus.failure,
        errorMessage: 'Failed to start work session',
      ));
    }
  }

  Future<void> _onEndWorkSession(
    EndWorkSession event,
    Emitter<WorkState> emit,
  ) async {
    emit(state.copyWith(status: WorkStatus.loading));

    try {
      final response = await _workService.endWork(
        longitude: event.longitude,
        latitude: event.latitude,
        address: event.address,
      );

      if (response.status && response.data != null) {
        emit(state.copyWith(
          status: WorkStatus.inactive,
          activeSession: null,
        ));
      } else {
        emit(state.copyWith(
          status: WorkStatus.failure,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      debugPrint('Error ending work session: $e');
      emit(state.copyWith(
        status: WorkStatus.failure,
        errorMessage: 'Failed to end work session',
      ));
    }
  }
}
