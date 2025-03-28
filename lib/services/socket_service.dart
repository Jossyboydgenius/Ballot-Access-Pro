import 'package:ballot_access_pro/core/flavor_config.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static SocketService? _instance;
  late IO.Socket socket;
  final String accessId;
  bool _isConnecting = false;

  SocketService._internal(this.accessId) {
    _initSocket();
  }

  static SocketService getInstance(String accessId) {
    _instance ??= SocketService._internal(accessId);
    return _instance!;
  }

  void _initSocket() {
    try {
      final baseUrl = locator<AppFlavorConfig>().socketUrl;
      final url = '$baseUrl?accessID=$accessId';
      debugPrint('Initializing socket connection to: $url');
      
      socket = IO.io(
        url,
        IO.OptionBuilder()
          .setTransports(['websocket'])
          .setReconnectionAttempts(10)
          .setReconnectionDelay(3000)
          .setReconnectionDelayMax(10000)
          .setTimeout(20000)
          .enableReconnection()
          .enableAutoConnect()
          .setExtraHeaders({
            'Connection': 'upgrade',
            'Upgrade': 'websocket',
            'Authorization': 'Bearer $accessId'
          })
          .build()
      );

      _setupSocketListeners();
    } catch (e, stackTrace) {
      debugPrint('Error initializing socket: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _setupSocketListeners() {
    socket.onConnect((_) {
      debugPrint('Socket connected successfully');
      _isConnecting = false;
    });

    socket.onConnecting((_) {
      debugPrint('Socket attempting to connect...');
      _isConnecting = true;
    });

    socket.onDisconnect((_) {
      debugPrint('Socket disconnected');
      _isConnecting = false;
      _attemptReconnect();
    });

    socket.onError((error) {
      debugPrint('Socket error: $error');
      if (!_isConnecting) {
        _attemptReconnect();
      }
    });

    socket.onConnectError((error) {
      debugPrint('Socket connection error: $error');
      if (!_isConnecting) {
        _attemptReconnect();
      }
    });

    socket.onConnectTimeout((_) {
      debugPrint('Socket connection timeout');
      if (!_isConnecting) {
        _attemptReconnect();
      }
    });
  }

  void _attemptReconnect() {
    if (!_isConnecting && !socket.connected) {
      debugPrint('Attempting to reconnect socket...');
      socket.connect();
    }
  }

  void emit(String event, dynamic data) {
    if (socket.connected) {
      socket.emit(event, data);
    } else {
      debugPrint('Socket not connected. Cannot emit event: $event');
      _attemptReconnect();
    }
  }

  void dispose() {
    socket.dispose();
    _instance = null;
  }

  bool get isInitialized => socket != null;
} 