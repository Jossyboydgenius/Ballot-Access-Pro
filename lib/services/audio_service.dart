import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../core/locator.dart';
import '../models/api_response_model.dart';
import '../models/audio_recording_model.dart';
import 'api/api.dart';

class AudioService {
  AudioService._privateConstructor();

  static final AudioService _instance = AudioService._privateConstructor();

  factory AudioService() {
    return _instance;
  }

  final Api _api = locator<Api>();
  final _audioRecorder = AudioRecorder();
  String? _recordingPath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  // Check microphone permission
  Future<bool> checkPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  // Start recording
  Future<bool> startRecording() async {
    if (_isRecording) return false;

    final hasPermission = await checkPermission();
    if (!hasPermission) {
      debugPrint('Microphone permission denied');
      return false;
    }

    try {
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final recordingPath = '${directory.path}/$timestamp.wav';
      _recordingPath = recordingPath;

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: recordingPath,
      );

      _isRecording = true;
      debugPrint('Recording started at $_recordingPath');
      return true;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return false;
    }
  }

  // Stop recording
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      debugPrint('Recording stopped. File saved at: $path');
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }

  // Upload recording to server
  Future<ApiResponseModel<String>> uploadRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ApiResponseModel(
          message: 'Audio file not found',
          status: false,
          statusCode: 404,
          data: null,
          error: 'File not found at path: $filePath',
        );
      }

      // Read file as bytes and convert to base64
      final bytes = await file.readAsBytes();
      final base64Audio = base64Encode(bytes);
      final audioData = 'data:audio/wav;base64,$base64Audio';

      // Send to server
      final response = await _api.postData(
        '/audio/upload',
        {'audio': audioData},
        hasHeader: true,
      );

      if (!response.isSuccessful) {
        return ApiResponseModel(
          message: response.message,
          status: false,
          statusCode: response.code ?? 400,
          data: null,
          error: response.message,
        );
      }

      final uploadResponse = AudioUploadResponse.fromJson(response.data);

      return ApiResponseModel(
        message: uploadResponse.message,
        status: true,
        statusCode: uploadResponse.statusCode,
        data: uploadResponse.url,
        error: null,
      );
    } catch (e) {
      debugPrint('Error uploading recording: $e');
      return ApiResponseModel(
        message: 'Failed to upload recording',
        status: false,
        statusCode: 500,
        data: null,
        error: e.toString(),
      );
    }
  }

  // Get all recordings
  Future<ApiResponseModel<List<AudioRecording>>> getRecordings() async {
    try {
      final response = await _api.getData('/audio', hasHeader: true);

      if (!response.isSuccessful) {
        return ApiResponseModel(
          message: response.message,
          status: false,
          statusCode: response.code ?? 400,
          data: [],
          error: response.message,
        );
      }

      final recordingsResponse = AudioRecordingResponse.fromJson(response.data);

      return ApiResponseModel(
        message: recordingsResponse.message,
        status: true,
        statusCode: recordingsResponse.statusCode,
        data: recordingsResponse.audioRecordings,
        error: null,
      );
    } catch (e) {
      debugPrint('Error fetching recordings: $e');
      return ApiResponseModel(
        message: 'Failed to fetch recordings',
        status: false,
        statusCode: 500,
        data: [],
        error: e.toString(),
      );
    }
  }

  // Dispose resources
  void dispose() {
    _audioRecorder.dispose();
  }
}
