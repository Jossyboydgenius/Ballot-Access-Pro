class AudioRecordingResponse {
  final List<AudioRecording> audioRecordings;
  final String message;
  final bool status;
  final int statusCode;
  final dynamic error;

  AudioRecordingResponse({
    required this.audioRecordings,
    required this.message,
    required this.status,
    required this.statusCode,
    this.error,
  });

  factory AudioRecordingResponse.fromJson(Map<String, dynamic> json) {
    return AudioRecordingResponse(
      audioRecordings: (json['data']['audioRecordings'] as List)
          .map((e) => AudioRecording.fromJson(e))
          .toList(),
      message: json['message'],
      status: json['status'],
      statusCode: json['statusCode'],
      error: json['error'],
    );
  }
}

class AudioRecording {
  final String id;
  final String userId;
  final String filename;
  final String url;
  final int duration;
  final int size;
  final String contentType;
  final DateTime createdAt;
  final DateTime updatedAt;

  AudioRecording({
    required this.id,
    required this.userId,
    required this.filename,
    required this.url,
    required this.duration,
    required this.size,
    required this.contentType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AudioRecording.fromJson(Map<String, dynamic> json) {
    return AudioRecording(
      id: json['_id'],
      userId: json['userId'],
      filename: json['filename'],
      url: json['url'],
      duration: json['duration'] ?? 0,
      size: json['size'] ?? 0,
      contentType: json['contentType'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class AudioUploadResponse {
  final String url;
  final String message;
  final bool status;
  final int statusCode;
  final dynamic error;

  AudioUploadResponse({
    required this.url,
    required this.message,
    required this.status,
    required this.statusCode,
    this.error,
  });

  factory AudioUploadResponse.fromJson(Map<String, dynamic> json) {
    return AudioUploadResponse(
      url: json['data']['url'],
      message: json['message'],
      status: json['status'],
      statusCode: json['statusCode'],
      error: json['error'],
    );
  }
}
