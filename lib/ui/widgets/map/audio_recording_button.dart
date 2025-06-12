// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
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
  bool _uploadFailed = false;
  String? _lastRecordingPath;
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
    // If in retry state, attempt to upload the last recording
    if (_uploadFailed && _lastRecordingPath != null) {
      await _uploadRecording(_lastRecordingPath!);
      return;
    }

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
        await _uploadRecording(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save recording'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isRecording = false;
          _isUploading = false;
        });
      }
    } else {
      // Start recording
      final hasPermission = await _audioService.checkPermission();

      if (hasPermission) {
        final success = await _audioService.startRecording();
        if (success) {
          setState(() {
            _isRecording = true;
            _uploadFailed = false;
            _lastRecordingPath = null;
          });

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

  Future<void> _uploadRecording(String filePath) async {
    setState(() {
      _isUploading = true;
      _uploadFailed = false;
    });

    final result = await _audioService.uploadRecording(filePath);

    if (result.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _isRecording = false;
        _isUploading = false;
        _uploadFailed = false;
        _lastRecordingPath = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload recording: ${result.message}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _uploadRecording(filePath),
          ),
        ),
      );
      setState(() {
        _isRecording = false;
        _isUploading = false;
        _uploadFailed = true;
        _lastRecordingPath = filePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'record',
      mini: true,
      backgroundColor: Colors.white,
      onPressed: _isUploading ? null : _toggleRecording,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return _isUploading
              ? SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isRecording ? Colors.red : AppColors.primary,
                    ),
                  ),
                )
              : Icon(
                  _uploadFailed
                      ? Icons.refresh
                      : (_isRecording ? Icons.stop : Icons.mic),
                  color: _uploadFailed
                      ? Colors.red
                      : (_isRecording ? Colors.red : AppColors.primary),
                  size: 20.r,
                );
        },
      ),
    );
  }
}
