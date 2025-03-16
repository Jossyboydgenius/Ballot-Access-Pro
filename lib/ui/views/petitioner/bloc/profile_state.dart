import 'package:equatable/equatable.dart';
import 'package:ballot_access_pro/models/petitioner_model.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final PetitionerModel? petitioner;
  final String? error;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.petitioner,
    this.error,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    PetitionerModel? petitioner,
    String? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      petitioner: petitioner ?? this.petitioner,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, petitioner, error];
} 