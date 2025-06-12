import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/ui/views/petitioner/bloc/work_bloc.dart';
import 'package:ballot_access_pro/ui/views/petitioner/bloc/work_event.dart';
import 'package:ballot_access_pro/ui/views/petitioner/bloc/work_state.dart';
import 'package:ballot_access_pro/shared/utils/debug_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class WorkControlsWidget extends StatefulWidget {
  const WorkControlsWidget({super.key});

  @override
  State<WorkControlsWidget> createState() => _WorkControlsWidgetState();
}

class _WorkControlsWidgetState extends State<WorkControlsWidget> {
  Timer? _timer;
  String _currentDuration = '0 mins';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime startTime) {
    // Update immediately
    _updateDuration(startTime);

    // Then update every second
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateDuration(startTime);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _updateDuration(DateTime startTime) {
    final now = DateTime.now();
    final difference = now.difference(startTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    setState(() {
      if (hours > 0) {
        _currentDuration =
            '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} hrs';
      } else {
        _currentDuration =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} mins';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkBloc, WorkState>(
      listener: (context, state) {
        if (state.status == WorkStatus.active && state.activeSession != null) {
          _startTimer(state.activeSession!.startTime);
        } else {
          _stopTimer();
        }
      },
      builder: (context, state) {
        final isLoading = state.status == WorkStatus.loading;
        final isWorking = state.status == WorkStatus.active;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show active work session info if working
              if (isWorking && state.activeSession != null) ...[
                Text(
                  'Working since:',
                  style:
                      AppTextStyle.regular12.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  DateFormat('h:mm a')
                      .format(state.activeSession!.startTime.toLocal()),
                  style: AppTextStyle.semibold14,
                ),
                Text(
                  'Duration: $_currentDuration',
                  style:
                      AppTextStyle.regular12.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: 8.h),
              ],

              // Button
              SizedBox(
                width: 140.w,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => _handleWorkAction(context, isWorking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWorking ? Colors.red : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                      : Text(
                          isWorking ? 'Stop Work' : 'Start Work',
                          style: AppTextStyle.semibold14
                              .copyWith(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleWorkAction(BuildContext context, bool isWorking) async {
    try {
      // In debug mode, use a fixed position to prevent any potential issues
      Position position;
      if (DebugUtils.isDebugMode) {
        // Use a valid fixed position for debugging (Ghana coordinates)
        position = Position(
          longitude: -0.1870,
          latitude: 5.6037,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      } else {
        position = await Geolocator.getCurrentPosition();
      }

      if (isWorking) {
        context.read<WorkBloc>().add(EndWorkSession(
              latitude: position.latitude,
              longitude: position.longitude,
            ));
      } else {
        context.read<WorkBloc>().add(StartWorkSession(
              latitude: position.latitude,
              longitude: position.longitude,
            ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get current location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
