import 'package:equatable/equatable.dart';
import 'package:ballot_access_pro/models/work_session_model.dart';

enum WorkStatus { initial, loading, active, inactive, success, failure }

class WorkState extends Equatable {
  final WorkStatus status;
  final WorkSession? activeSession;
  final String? errorMessage;

  const WorkState({
    this.status = WorkStatus.initial,
    this.activeSession,
    this.errorMessage,
  });

  WorkState copyWith({
    WorkStatus? status,
    WorkSession? activeSession,
    String? errorMessage,
  }) {
    return WorkState(
      status: status ?? this.status,
      activeSession: activeSession ?? this.activeSession,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isWorking => status == WorkStatus.active && activeSession != null;

  @override
  List<Object?> get props => [status, activeSession, errorMessage];
}
