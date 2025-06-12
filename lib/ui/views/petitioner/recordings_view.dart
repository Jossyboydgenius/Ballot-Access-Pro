import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/services/audio_service.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/models/audio_recording_model.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:ballot_access_pro/shared/utils/debug_utils.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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

  // Just Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;
  bool _isPlaying = false;
  String? _playbackErrorMessage;
  bool _isDownloading = false;

  // Audio playback state
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  // Cache tracking
  final Map<String, String> _cachedFiles = {};

  @override
  void initState() {
    super.initState();
    _loadRecordings();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // Listen for player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _position = _duration;
        });
      }
    });

    // Track position changes
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });

    // Track duration changes
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
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

        // Start preloading recordings in the background
        _preloadRecordings();
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

  // Preload recordings in the background
  void _preloadRecordings() {
    for (final recording in _recordings) {
      _downloadFile(recording.url, '${recording.id}.wav', showLoading: false);
    }
  }

  // Download the audio file to a local path for more reliable playback
  Future<String?> _downloadFile(String url, String fileName,
      {bool showLoading = true}) async {
    try {
      // Check if already in cache
      if (_cachedFiles.containsKey(url)) {
        if (showLoading) {
          setState(() {
            _isDownloading = false;
          });
        }
        return _cachedFiles[url];
      }

      if (showLoading) {
        setState(() {
          _isDownloading = true;
        });
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      // Check if file already exists in cache
      final file = File(filePath);
      if (await file.exists()) {
        print('File already in cache: $filePath');
        _cachedFiles[url] = filePath;

        if (showLoading) {
          setState(() {
            _isDownloading = false;
          });
        }
        return filePath;
      }

      // Log the URL for debugging
      print('Downloading file from URL: $url');

      // Use the URL directly as provided by the API without any transformations
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Write file to disk
        await file.writeAsBytes(response.bodyBytes);
        print('Downloaded file to: $filePath');
        _cachedFiles[url] = filePath;

        if (showLoading) {
          setState(() {
            _isDownloading = false;
          });
        }
        return filePath;
      } else {
        print('Failed to download file. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (showLoading) {
          setState(() {
            _isDownloading = false;
            _playbackErrorMessage =
                'Download failed (${response.statusCode}): ${response.body}';
          });
        }
        return null;
      }
    } catch (e) {
      print('Error downloading file: $e');
      if (showLoading) {
        setState(() {
          _isDownloading = false;
          _playbackErrorMessage = 'Download error: $e';
        });
      }
      return null;
    }
  }

  Future<void> _playRecording(AudioRecording recording) async {
    try {
      // Reset error message
      setState(() {
        _playbackErrorMessage = null;
      });

      // If the same recording is already playing, toggle play/pause
      if (_currentlyPlayingId == recording.id) {
        if (_isPlaying) {
          // Update UI immediately for better responsiveness
          setState(() {
            _isPlaying = false;
          });
          await _audioPlayer.pause();
        } else {
          // Update UI immediately for better responsiveness
          setState(() {
            _isPlaying = true;
          });
          await _audioPlayer.play();
        }
        return;
      }

      // If a different recording is playing, stop it
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      // First check if we already have the file cached
      final url = recording.url;
      final filename = '${recording.id}.wav';

      // Set initial state
      setState(() {
        _currentlyPlayingId = recording.id;
        _isPlaying = false;
        _position = Duration.zero;
        _duration = Duration.zero;
      });

      // Check if the file is already cached before showing download indicator
      final cachePath =
          '${(await getApplicationDocumentsDirectory()).path}/$filename';
      final isCached =
          _cachedFiles.containsKey(url) || await File(cachePath).exists();

      // Only show downloading indicator if not already cached
      if (!isCached) {
        setState(() {
          _isDownloading = true;
        });
      }

      // Download or get cached file
      final localPath =
          await _downloadFile(url, filename, showLoading: !isCached);

      if (localPath != null) {
        try {
          // Try to play from local file - update UI immediately before async operation
          setState(() {
            _isPlaying = true;
            _isDownloading = false;
          });

          await _audioPlayer.setFilePath(localPath);
          await _audioPlayer.play();
        } catch (e) {
          print('Error playing local file: $e');
          setState(() {
            _isDownloading = false;
            _isPlaying = false;
          });

          // If playing local file fails, try streaming directly
          try {
            // Update UI before async operation
            setState(() {
              _isPlaying = true;
            });

            await _audioPlayer.setUrl(url);
            await _audioPlayer.play();
          } catch (streamError) {
            print('Error streaming audio: $streamError');
            setState(() {
              _playbackErrorMessage = 'Playback error: $streamError';
              _isPlaying = false;
              _currentlyPlayingId = null;
            });

            // Show error and offer to open externally
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not play audio: $streamError'),
                action: SnackBarAction(
                  label: 'Open Externally',
                  onPressed: () => _openExternally(url),
                ),
                duration: const Duration(seconds: 10),
              ),
            );
          }
        }
      } else {
        // If download fails, try to play directly from URL
        setState(() {
          _isDownloading = false;
        });
        try {
          // Update UI before async operation
          setState(() {
            _isPlaying = true;
          });

          await _audioPlayer.setUrl(url);
          await _audioPlayer.play();
        } catch (e) {
          print('Error playing audio: $e');
          setState(() {
            _playbackErrorMessage = 'Playback error: $e';
            _isPlaying = false;
            _currentlyPlayingId = null;
          });

          // Show error and offer to open externally
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not play audio: $e'),
              action: SnackBarAction(
                label: 'Open Externally',
                onPressed: () => _openExternally(url),
              ),
              duration: const Duration(seconds: 10),
            ),
          );
        }
      }
    } catch (e) {
      print('General error in playback: $e');
      setState(() {
        _playbackErrorMessage = 'Error: $e';
        _isPlaying = false;
        _currentlyPlayingId = null;
        _isDownloading = false;
      });
    }
  }

  // Seek to a specific position in the audio
  Future<void> _seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  // Format duration as mm:ss
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _openExternally(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open URL externally'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening URL: $e'),
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
                          final bool isCurrentlyPlaying =
                              _currentlyPlayingId == recording.id;
                          final bool isLoading =
                              isCurrentlyPlaying && _isDownloading;

                          return Card(
                            margin: EdgeInsets.only(bottom: 16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.all(16.w),
                                  leading: Container(
                                    width: 48.r,
                                    height: 48.r,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: isLoading
                                        ? CircularProgressIndicator(
                                            strokeWidth: 2.w,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(AppColors.primary),
                                          )
                                        : IconButton(
                                            icon: Icon(
                                              isCurrentlyPlaying && _isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: AppColors.primary,
                                            ),
                                            onPressed: () =>
                                                _playRecording(recording),
                                          ),
                                  ),
                                  title: Text(
                                    'Recording ${index + 1}',
                                    style: AppTextStyle.semibold16,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Created: ${DateFormat('MMM dd, yyyy - hh:mm a').format(recording.createdAt.toLocal())}',
                                        style: AppTextStyle.regular12,
                                      ),
                                      if (isCurrentlyPlaying && _isDownloading)
                                        Padding(
                                          padding: EdgeInsets.only(top: 4.h),
                                          child: Text(
                                            'Downloading...',
                                            style:
                                                AppTextStyle.regular12.copyWith(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.open_in_new),
                                    onPressed: () =>
                                        _openExternally(recording.url),
                                  ),
                                  onTap: () => _playRecording(recording),
                                ),

                                // Playback progress bar for currently playing recording
                                if (_currentlyPlayingId == recording.id &&
                                    !_isDownloading)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 0,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              _formatDuration(_position),
                                              style: AppTextStyle.regular12,
                                            ),
                                            Expanded(
                                              child: Slider(
                                                value:
                                                    DebugUtils.safeSliderValue(
                                                  _position.inMilliseconds
                                                      .toDouble(),
                                                  0,
                                                  _duration.inMilliseconds > 0
                                                      ? _duration.inMilliseconds
                                                          .toDouble()
                                                      : 1.0,
                                                ),
                                                min: 0,
                                                max: DebugUtils
                                                    .safeSliderMaxValue(
                                                  0,
                                                  _duration.inMilliseconds > 0
                                                      ? _duration.inMilliseconds
                                                          .toDouble()
                                                      : 1.0,
                                                ),
                                                onChanged: (value) {
                                                  final safeValue = DebugUtils
                                                      .safeSliderValue(
                                                    value,
                                                    0,
                                                    _duration.inMilliseconds > 0
                                                        ? _duration
                                                            .inMilliseconds
                                                            .toDouble()
                                                        : 1.0,
                                                  );
                                                  _seekTo(Duration(
                                                    milliseconds:
                                                        safeValue.toInt(),
                                                  ));
                                                },
                                                activeColor: AppColors.primary,
                                              ),
                                            ),
                                            Text(
                                              _formatDuration(_duration),
                                              style: AppTextStyle.regular12,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                if (isCurrentlyPlaying &&
                                    _playbackErrorMessage != null)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 8.h),
                                    child: Text(
                                      _playbackErrorMessage!,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
