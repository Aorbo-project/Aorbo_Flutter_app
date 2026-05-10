import 'dart:developer';
import 'package:arobo_app/models/chat/message_model.dart';
import 'package:arobo_app/repository/network_url.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  // Singleton pattern
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  final Map<String, List<Function>> _listeners = {};

  bool get isConnected => _socket?.connected ?? false;

  /// Connect to Socket.IO server
  Future<void> connect({required int customerId}) async {
    try {
      if (_socket != null && _socket!.connected) {
        log('Socket already connected');
        return;
      }

      _socket = io.io(
        NetworkUrl.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionAttempts(5)
            .build(),
      );

      _socket!.onConnect((_) {
        log('✅ Socket connected');
        // Join as customer
        _socket!.emit('user:join', {
          'userType': 'customer',
          'userId': customerId,
        });
      });

      _socket!.on('user:joined', (data) {
        log('✅ User joined: $data');
        _notifyListeners('connected', data);
      });

      _socket!.onDisconnect((_) {
        log('❌ Socket disconnected');
        _notifyListeners('disconnected', null);
      });

      _socket!.onError((error) {
        log('❌ Socket error: $error');
        _notifyListeners('error', error);
      });

      // Listen for incoming messages
      _socket!.on('message:received', (data) {
        log('📩 Message received: $data');
        try {
          final message = MessageModel.fromJson(data);
          _notifyListeners('message:received', message);
        } catch (e) {
          log('Error parsing message: $e');
        }
      });

      // Listen for messages marked as read
      _socket!.on('messages:marked_read', (data) {
        log('✅ Messages marked as read: $data');
        _notifyListeners('messages:marked_read', data);
      });

      // Listen for typing indicators
      _socket!.on('user:typing', (data) {
        log('⌨️ User typing: $data');
        _notifyListeners('user:typing', data);
      });

      _socket!.on('user:stop_typing', (data) {
        log('⌨️ User stopped typing: $data');
        _notifyListeners('user:stop_typing', data);
      });

      // Listen for chat joined
      _socket!.on('chat:joined', (data) {
        log('✅ Chat joined: $data');
        _notifyListeners('chat:joined', data);
      });

      _socket!.connect();
    } catch (e) {
      log('Error connecting to socket: $e');
      rethrow;
    }
  }

  /// Join a specific chat room
  void joinChat({required int chatId}) {
    if (_socket == null || !_socket!.connected) {
      log('⚠️ Socket not connected. Cannot join chat.');
      return;
    }

    _socket!.emit('chat:join', {
      'chatId': chatId,
    });
    log('🔗 Joining chat: $chatId');
  }

  /// Send a message
  void sendMessage({
    required int chatId,
    required String message,
    required int senderId,
  }) {
    if (_socket == null || !_socket!.connected) {
      log('⚠️ Socket not connected. Cannot send message.');
      return;
    }

    _socket!.emit('message:send', {
      'chatId': chatId,
      'message': message,
      'senderType': 'customer',
      'senderId': senderId,
    });
    log('📤 Message sent: $message');
  }

  /// Mark messages as read
  void markAsRead({required int chatId}) {
    if (_socket == null || !_socket!.connected) {
      log('⚠️ Socket not connected. Cannot mark as read.');
      return;
    }

    _socket!.emit('messages:mark_read', {
      'chatId': chatId,
      'userType': 'customer',
    });
    log('✅ Marking messages as read for chat: $chatId');
  }

  /// Start typing indicator
  void startTyping({
    required int chatId,
    required String userName,
  }) {
    if (_socket == null || !_socket!.connected) return;

    _socket!.emit('user:typing', {
      'chatId': chatId,
      'userType': 'customer',
      'userName': userName,
    });
  }

  /// Stop typing indicator
  void stopTyping({required int chatId}) {
    if (_socket == null || !_socket!.connected) return;

    _socket!.emit('user:stop_typing', {
      'chatId': chatId,
      'userType': 'customer',
    });
  }

  /// Add event listener
  void addListener(String event, Function(dynamic) callback) {
    if (!_listeners.containsKey(event)) {
      _listeners[event] = [];
    }
    _listeners[event]!.add(callback);
  }

  /// Remove event listener
  void removeListener(String event, Function callback) {
    if (_listeners.containsKey(event)) {
      _listeners[event]!.remove(callback);
    }
  }

  /// Remove all listeners for an event
  void removeAllListeners(String event) {
    _listeners.remove(event);
  }

  /// Notify all listeners for an event
  void _notifyListeners(String event, dynamic data) {
    if (_listeners.containsKey(event)) {
      for (var callback in _listeners[event]!) {
        try {
          callback(data);
        } catch (e) {
          log('Error in listener callback: $e');
        }
      }
    }
  }

  /// Disconnect from socket
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _listeners.clear();
      log('🔌 Socket disconnected and disposed');
    }
  }

  /// Reconnect to socket
  Future<void> reconnect({required int customerId}) async {
    disconnect();
    await connect(customerId: customerId);
  }
}
