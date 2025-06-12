// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/services/audio_service.dart';
import 'package:ballot_access_pro/shared/utils/debug_utils.dart';
import 'package:ballot_access_pro/core/locator.dart';

class AudioRecordingButton extends StatefulWidget {
  const AudioRecordingButton({Key? key}) : super(key: key);

  @override
  State<AudioRecordingButton> createState() => _AudioRecordingButtonState();
}

class _AudioRecordingButtonState extends State<AudioRecordingButton>
    with SingleTickerProviderStateMixin {
  final AudioService _audioService = locator<AudioService>();
  bool _isRecording = false;
  bool _isUploading = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    // Handle specially in debug mode to prevent errors
    if (DebugUtils.isDebugMode) {
      if (_isRecording) {
        // Simulate stopping recording in debug mode
        setState(() => _isUploading = true);

        // Simulate delay
        await Future.delayed(const Duration(seconds: 1));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording uploaded successfully (Debug Mode)'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isRecording = false;
          _isUploading = false;
        });
      } else {
        // Simulate starting recording in debug mode
        setState(() => _isRecording = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording started (Debug Mode)'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    // Normal behavior for release mode
    if (_isRecording) {
      // Stop recording
      setState(() => _isUploading = true);

      final filePath = await _audioService.stopRecording();

      if (filePath != null) {
        // Upload the recording
        final result = await _audioService.uploadRecording(filePath);

        if (result.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload recording: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save recording'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isRecording = false;
        _isUploading = false;
      });
    } else {
      // Start recording
      final hasPermission = await _audioService.checkPermission();

      if (hasPermission) {
        final success = await _audioService.startRecording();
        if (success) {
          setState(() => _isRecording = true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording started'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start recording'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission denied'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          if (_isRecording) ...[
            Text(
              'Recording...',
              style: AppTextStyle.regular12.copyWith(color: Colors.red),
            ),
            SizedBox(height: 4.h),
            // Wave indicator for recording
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  width: 3.w,
                  height: (10 + index * 2).h,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],

          // Recording button
          GestureDetector(
            onTap: _isUploading ? null : _toggleRecording,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRecording ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isUploading
                          ? Colors.grey
                          : _isRecording
                              ? Colors.red
                              : AppColors.primary,
                    ),
                    child: _isUploading
                        ? Center(
                            child: SizedBox(
                              width: 24.r,
                              height: 24.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 24.r,
                          ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _isUploading
                ? 'Uploading...'
                : _isRecording
                    ? 'Tap to stop'
                    : 'Record',
            style: AppTextStyle.regular12,
          ),
        ],
      ),
    );
  }
}
