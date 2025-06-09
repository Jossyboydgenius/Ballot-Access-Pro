import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/services/audio_service.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/models/audio_recording_model.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class RecordingsView extends StatefulWidget {
  const RecordingsView({Key? key}) : super(key: key);

  @override
  State<RecordingsView> createState() => _RecordingsViewState();
}

class _RecordingsViewState extends State<RecordingsView> {
  final AudioService _audioService = locator<AudioService>();
  bool _isLoading = true;
  List<AudioRecording> _recordings = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }

  Future<void> _loadRecordings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _audioService.getRecordings();

      if (result.status) {
        setState(() {
          _recordings = result.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _playRecording(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open recording: $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recordings',
          style: AppTextStyle.semibold18.copyWith(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecordings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48.r,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error loading recordings',
                        style: AppTextStyle.semibold16,
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.regular14.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: _loadRecordings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _recordings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mic_off,
                            size: 48.r,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No recordings found',
                            style: AppTextStyle.semibold16,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Tap the microphone button to start recording',
                            style: AppTextStyle.regular14.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRecordings,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _recordings.length,
                        itemBuilder: (context, index) {
                          final recording = _recordings[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 16.h),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.w),
                              leading: Container(
                                width: 48.r,
                                height: 48.r,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.audiotrack,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(
                                'Recording ${index + 1}',
                                style: AppTextStyle.semibold16,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Created: ${DateFormat('MMM dd, yyyy - hh:mm a').format(recording.createdAt.toLocal())}',
                                    style: AppTextStyle.regular12,
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.play_arrow),
                                color: AppColors.primary,
                                onPressed: () => _playRecording(recording.url),
                              ),
                              onTap: () => _playRecording(recording.url),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
