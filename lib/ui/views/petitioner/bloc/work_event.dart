import 'package:equatable/equatable.dart';

abstract class WorkEvent extends Equatable {
  const WorkEvent();

  @override
  List<Object?> get props => [];
}

class CheckWorkSession extends WorkEvent {
  const CheckWorkSession();
}

class StartWorkSession extends WorkEvent {
  final double latitude;
  final double longitude;
  final String? address;

  const StartWorkSession({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}

class EndWorkSession extends WorkEvent {
  final double latitude;
  final double longitude;
  final String? address;

  const EndWorkSession({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}
