import 'dart:async';
import 'package:ballot_access_pro/core/flavor_config.dart';
import 'package:ballot_access_pro/core/locator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'dart:convert';

class SocketService {
  static SocketService? _instance;
  IO.Socket? _socket;
  String? _userId;
  bool _isConnected = false;
  final _eventListeners = <String, List<Function(dynamic)>>{};
  Timer? _reconnectTimer;
  final int _reconnectInterval = 5000; // 5 seconds

  // Stream controller for connection status
  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  SocketService._internal() {
    // Constructor doesn't initialize socket anymore
  }

  static SocketService getInstance() {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  bool get isConnected => _isConnected;
  
  String? getUserId() => _userId;

  Future<void> connect(String userId) async {
    if (_socket != null && _socket!.connected) {
      // Already connected
      return;
    }

    _userId = userId;
    
    // Get the socket URL from the environment
    String socketUrl = locator<AppFlavorConfig>().socketUrl;
    
    try {
      debugPrint('📡 Connecting to Socket.IO: $socketUrl');
      
      // Initialize Socket.IO with proper options
      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling']) // Allow fallback to polling if WebSocket fails
            .enableReconnection() // Enable automatic reconnection
            .setQuery({'accessID': userId}) // Add userId as query parameter
            .setTimeout(10000) // Increase timeout to 10 seconds
            .setReconnectionDelay(1000) // Start with 1 second delay for reconnections
            .setReconnectionAttempts(double.infinity) // Keep trying to reconnect
            .build(),
      );
      
      _setupListeners();
      
      // Connect the socket if not auto-connected
      if (!_socket!.connected) {
        _socket!.connect();
      }
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
    });
    
    _socket?.onDisconnect((_) {
      debugPrint('Socket.IO connection closed');
      _setConnectionStatus(false);
    });
    
    _socket?.onConnectError((error) {
      debugPrint('❌ Socket.IO connection error: $error');
      _setConnectionStatus(false);
    });
    
    _socket?.onError((error) {
      debugPrint('❌ Socket.IO error: $error');
    });
    
    // Listen for location_update events
    _socket?.on('location_update', (data) {
      debugPrint('📥 Received Socket.IO message: $data');
      
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
  }

  void _setConnectionStatus(bool status) {
    if (_isConnected != status) {
      _isConnected = status;
      debugPrint('Socket.IO connection status: ${_isConnected ? 'Connected' : 'Disconnected'}');
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
        connect(_userId!);
      }
    });
  }
  
  void sendTrackEvent(Map<String, dynamic> locationData) {
    if (_socket == null || !_isConnected) {
      debugPrint('❌ Cannot send track event: Socket.IO not connected');
      return;
    }

    try {
      debugPrint('📤 Sending track event via Socket.IO');
      _socket?.emit('track', locationData);
    } catch (e) {
      debugPrint('❌ Error sending track event: $e');
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

  // Original emit method
  void emit(String event, Map<String, dynamic> data) {
    if (_socket == null || !_isConnected) {
      debugPrint('❌ Socket not connected, cannot emit $event');
      return;
    }
    
    try {
      final eventData = {
        "type": event,
        "data": data
      };
      
      debugPrint('📤 Emitting event: $event with data: ${jsonEncode(eventData)}');
      _socket?.emit(event, eventData);
    } catch (e) {
      debugPrint('🔴 Error emitting event $event: $e');
    }
  }

  // Original on method
  void on(String event, Function(dynamic) callback) {
    if (_socket != null) {
      _socket?.on(event, callback);
    }
  }

  // Original off method
  void off(String event) {
    if (_socket != null) {
      _socket?.off(event);
    }
  }

  void close() {
    debugPrint('Closing Socket.IO connection');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _setConnectionStatus(false);
    _reconnectTimer?.cancel();
  }

  void dispose() {
    close();
    _connectionStatusController.close();
    _instance = null;
  }
} 