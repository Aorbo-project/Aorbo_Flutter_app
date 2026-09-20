import 'dart:developer';
import 'package:arobo_app/repository/network_url.dart';
import 'package:arobo_app/repository/repository.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Customer real-time event stream (refund / booking / TBR / payment / FAQ).
///
/// Live-agent chat was removed 2026-09-20 (its controller was this class's only
/// caller, and the backend chat handlers are gone), so the chat send/typing/
/// read methods and listeners are gone with it.
///
/// The backend's /customer namespace now REQUIRES a valid customer JWT at
/// connect and derives the room from the token — an anonymous or id-claiming
/// client used to be able to subscribe to any customer's events. The token is
/// therefore sent in the handshake `auth`. Access tokens are short-lived
/// (30 min), so callers should (re)connect after a token refresh.
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
        '${NetworkUrl.socketUrl}/customer',
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setAuth({'token': Repository.token})
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionAttempts(5)
            .build(),
      );

      _socket!.onConnect((_) {
        log('✅ Socket connected');
        // Legacy handshake — the server ignores the claimed id and acks with
        // the identity from the token.
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

      // FAQ lifecycle updates — refresh FAQ content when admin changes FAQs.
      _socket!.on('faq:updated', (data) {
        log('📢 FAQ updated: $data');
        _notifyListeners('faq:updated', data);
      });

      // Refund lifecycle events — emitted from backend after Razorpay webhook fires.
      // All three events carry bookingId so the UI can match to the right booking.
      _socket!.on('refund:initiated', (data) {
        log('💸 Refund initiated: $data');
        _notifyListeners('refund:initiated', data);
      });

      _socket!.on('refund:processed', (data) {
        log('✅ Refund processed and credited: $data');
        _notifyListeners('refund:processed', data);
      });

      _socket!.on('refund:failed', (data) {
        log('❌ Refund failed — support needed: $data');
        _notifyListeners('refund:failed', data);
      });

      // booking:confirmed — admin confirmed a new booking payment
      _socket!.on('booking:confirmed', (data) {
        log('✅ Booking confirmed: $data');
        _notifyListeners('booking:confirmed', data);
      });

      // tbr:cancelled — a batch (TBR) has been cancelled by vendor or admin
      _socket!.on('tbr:cancelled', (data) {
        log('❌ TBR cancelled: $data');
        _notifyListeners('tbr:cancelled', data);
      });

      // payment:failed — payment for a booking attempt failed at Razorpay
      _socket!.on('payment:failed', (data) {
        log('❌ Payment failed: $data');
        _notifyListeners('payment:failed', data);
      });

      _socket!.connect();
    } catch (e) {
      log('Error connecting to socket: $e');
      rethrow;
    }
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
