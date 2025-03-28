import 'package:ballot_access_pro/core/flavor_config.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static SocketService? _instance;
  late IO.Socket socket;
  final String accessId;
  bool _isConnecting = false;
  bool isInitialized = false;
  bool isConnected = false;

  SocketService._internal(this.accessId) {
    // Constructor doesn't initialize socket anymore
  }

  static SocketService getInstance(String token, String userId) {
    _instance ??= SocketService._internal(userId);
    
    if (!_instance!.isInitialized) {
      _instance!._initSocket(token, userId);
    }
    
    return _instance!;
  }

  void _initSocket(String token, String userId) {
    try {
      final baseUrl = locator<AppFlavorConfig>().socketUrl;
      final url = '$baseUrl?accessID=$userId';
      
      debugPrint('Initializing socket with URL: $url');
      
      socket = IO.io(
        url,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableAutoConnect()
            .enableForceNew()
            .build(),
      );
      
      _setupBaseListeners();
      isInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('Error initializing socket: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _setupBaseListeners() {
    socket.onConnect((_) {
      debugPrint('Socket connected successfully');
      _isConnecting = false;
      isConnected = true;
    });

    socket.onDisconnect((_) {
      debugPrint('Socket disconnected');
      isConnected = false;
    });

    socket.onConnectError((data) {
      debugPrint('Socket connection error: $data');
      isConnected = false;
    });

    socket.onError((data) {
      debugPrint('Socket error: $data');
    });
  }

  void emit(String event, Map<String, dynamic> data) {
    if (isInitialized) {
      socket.emit(event, data);
    } else {
      debugPrint('Socket not initialized, cannot emit $event');
    }
  }

  void on(String event, Function(dynamic) callback) {
    if (isInitialized) {
      socket.on(event, callback);
    }
  }

  void off(String event) {
    if (isInitialized) {
      socket.off(event);
    }
  }

  void dispose() {
    if (isInitialized) {
      socket.off('connect');
      socket.off('disconnect');
      socket.off('connect_error');
      socket.off('error');
      socket.off('location_update');
    }
  }
} 