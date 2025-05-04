import 'dart:async';
import 'package:ballot_access_pro/core/flavor_config.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:flutter/foundation.dart';
import 'dart:convert';

class SocketService {
  static SocketService? _instance;
  socket_io.Socket? _socket;
  String? _userId;
  bool _isConnected = false;
  final _eventListeners = <String, List<Function(dynamic)>>{};
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  final int _reconnectInterval = 5000; // 5 seconds
  final int _heartbeatInterval = 30000; // 30 seconds

  // Stream controller for connection status
  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  SocketService._internal() {
    // Empty constructor
  }

  static SocketService getInstance() {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  bool get isConnected => _isConnected;

  String? getUserId() => _userId;

  Future<void> connect(String userId) async {
    if (_socket != null && _socket!.connected) {
      // Already connected - but ensure the userId is updated
      _userId = userId;
      debugPrint('📡 Socket already connected, updating userId to: $userId');
      return;
    }

    _userId = userId;

    // Get the socket URL from the environment
    String socketUrl = locator<AppFlavorConfig>().socketUrl;

    try {
      debugPrint('📡 Connecting to Socket.IO: $socketUrl with userId: $userId');

      // Initialize Socket.IO with proper options
      _socket = socket_io.io(
        socketUrl,
        socket_io.OptionBuilder()
            .setTransports([
              'websocket',
              'polling'
            ]) // Allow fallback to polling if WebSocket fails
            .enableReconnection() // Enable automatic reconnection
            .setQuery({'accessID': userId}) // Add userId as query parameter
            .setTimeout(10000) // Increase timeout to 10 seconds
            .setReconnectionDelay(
                1000) // Start with 1 second delay for reconnections
            .setReconnectionAttempts(
                double.infinity) // Keep trying to reconnect
            .enableAutoConnect() // Auto-connect when socket is created
            .build(),
      );

      _setupListeners();

      // Connect the socket if not auto-connected
      if (!_socket!.connected) {
        // Fix: Remove the argument - socket.connect() doesn't take arguments
        _socket!.connect();
      }

      // Start heartbeat to keep connection alive
      _startHeartbeat();
    } catch (e, stack) {
      debugPrint('❌ Socket.IO connection error: $e');
      debugPrint('Stack trace: $stack');
      _handleConnectionError();
    }
  }

  void _setupListeners() {
    _socket?.onConnect((_) {
      debugPrint('📡 Socket.IO connected successfully!');
      _setConnectionStatus(true);

      // Send a ping immediately after connection to announce presence
      _sendPing();

      // Restart heartbeat timer on successful connection
      _startHeartbeat();
    });

    _socket?.onDisconnect((_) {
      debugPrint('⚠️ Socket.IO connection closed');
      _setConnectionStatus(false);

      // Try to reconnect
      _handleConnectionError();
    });

    _socket?.onConnectError((error) {
      debugPrint('❌ Socket.IO connection error: $error');
      _setConnectionStatus(false);

      // Try to reconnect
      _handleConnectionError();
    });

    _socket?.onError((error) {
      debugPrint('❌ Socket.IO error: $error');
    });

    // Listen for location_update events
    _socket?.on('location_update', (data) {
      debugPrint('📥 Received Socket.IO message (location_update): $data');

      try {
        if (_eventListeners.containsKey('location_update')) {
          for (final listener in _eventListeners['location_update']!) {
            listener(data);
          }
        }
      } catch (e) {
        debugPrint('❌ Error handling Socket.IO message: $e');
      }
    });

    // Listen for pong responses
    _socket?.on('pong', (data) {
      debugPrint('📥 Received pong from server: $data');
    });
  }

  void _setConnectionStatus(bool status) {
    if (_isConnected != status) {
      _isConnected = status;
      debugPrint(
          'Socket.IO connection status: ${_isConnected ? 'Connected ✅' : 'Disconnected ❌'}');
      _connectionStatusController.add(_isConnected);
    }
  }

  void _handleConnectionError() {
    // Socket.IO handles reconnection automatically, but we'll set our status
    _setConnectionStatus(false);

    // If socket.io automatic reconnection fails, we can implement our own backup mechanism
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: _reconnectInterval), () {
      if (_userId != null && (_socket == null || !_socket!.connected)) {
        debugPrint('🔄 Manual reconnection attempt for Socket.IO...');

        // Force socket to reconnect
        _socket?.connect();

        // If still not connected, recreate the socket
        if (_socket == null || !_socket!.connected) {
          connect(_userId!);
        }
      }
    });
  }

  void _startHeartbeat() {
    // Cancel any existing heartbeat timer
    _heartbeatTimer?.cancel();

    // Start a new heartbeat timer
    _heartbeatTimer =
        Timer.periodic(Duration(milliseconds: _heartbeatInterval), (timer) {
      _sendPing();
    });
  }

  void _sendPing() {
    try {
      if (_socket != null && _isConnected) {
        debugPrint('💓 Sending heartbeat ping');
        _socket?.emit('ping', {
          'userId': _userId,
          'timestamp': DateTime.now().millisecondsSinceEpoch
        });
      }
    } catch (e) {
      debugPrint('❌ Error sending ping: $e');
    }
  }

  void sendTrackEvent(Map<String, dynamic> locationData) {
    if (_socket == null) {
      debugPrint('❌ Cannot send track event: Socket not initialized');

      // Try to reconnect if userId is available
      if (_userId != null) {
        debugPrint('🔄 Attempting to reconnect before sending track event');
        connect(_userId!); // This returns Future<void>, don't use then here

        // Schedule a delayed retry after connection attempt
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (_isConnected) {
            _sendTrackEventInternal(locationData);
          } else {
            debugPrint('❌ Still not connected, could not send track event');
          }
        });
      }
      return;
    }

    if (!_isConnected) {
      debugPrint('❌ Cannot send track event: Socket not connected');

      // Try to reconnect
      _socket?.connect();

      // Schedule a delayed retry after connection attempt
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_isConnected) {
          _sendTrackEventInternal(locationData);
        } else {
          debugPrint('❌ Still not connected, could not send track event');
        }
      });
      return;
    }

    _sendTrackEventInternal(locationData);
  }

  void _sendTrackEventInternal(Map<String, dynamic> locationData) {
    try {
      debugPrint(
          '📤 Sending track event via Socket.IO: ${locationData['latitude']}, ${locationData['longitude']}');
      _socket?.emit('track', locationData);
    } catch (e) {
      debugPrint('❌ Error sending track event: $e');

      // If we get an error, try to reconnect
      _handleConnectionError();
    }
  }

  void addListener(String eventType, Function(dynamic) callback) {
    _eventListeners[eventType] ??= [];
    _eventListeners[eventType]!.add(callback);
  }

  void removeListener(String eventType, Function(dynamic) callback) {
    if (_eventListeners.containsKey(eventType)) {
      _eventListeners[eventType]!.remove(callback);
    }
  }

  void emit(String event, Map<String, dynamic> data) {
    if (_socket == null || !_isConnected) {
      debugPrint('❌ Socket not connected, cannot emit $event');
      return;
    }

    try {
      final eventData = {"type": event, "data": data};

      debugPrint(
          '📤 Emitting event: $event with data: ${jsonEncode(eventData)}');
      _socket?.emit(event, eventData);
    } catch (e) {
      debugPrint('🔴 Error emitting event $event: $e');
    }
  }

  void on(String event, Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on(event, callback);
    }
  }

  void off(String event) {
    if (_socket != null) {
      _socket?.off(event);
    }
  }

  void close() {
    debugPrint('Closing Socket.IO connection');
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _setConnectionStatus(false);
  }

  void dispose() {
    close();
    _connectionStatusController.close();
    _instance = null;
  }
}
