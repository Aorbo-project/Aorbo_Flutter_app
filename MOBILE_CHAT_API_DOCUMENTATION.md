# Mobile App Chat Integration - API Documentation

> Complete guide for integrating real-time chat between mobile app customers and admin panel

## Table of Contents
- [Overview](#overview)
- [Base URLs](#base-urls)
- [Authentication](#authentication)
- [REST API Endpoints](#rest-api-endpoints)
- [Socket.IO Integration](#socketio-integration)
- [Mobile Implementation](#mobile-implementation)
- [Testing](#testing)
- [Production Deployment](#production-deployment)

---

## Overview

This chat system enables real-time bidirectional communication between:
- **Mobile App Customers** - Users of the trekking booking app
- **Admin Panel** - Customer support administrators

### Features
- ✅ Real-time messaging with Socket.IO
- ✅ Message read receipts
- ✅ Unread message counters
- ✅ Typing indicators
- ✅ Chat history persistence
- ✅ Firebase authentication for customers
- ✅ Automatic reconnection handling

---

## Base URLs

| Environment | URL |
|------------|-----|
| Development | `http://localhost:3001` |
| Production | `https://your-domain.com` |

---

## Authentication

### Customer Authentication
All mobile API endpoints require Firebase authentication token in the header:

```http
Authorization: Bearer <FIREBASE_ID_TOKEN>
```

The backend validates the Firebase token using the `authenticateCustomer` middleware.

---

## REST API Endpoints

### 1. Create or Get Chat

Creates a new chat or returns existing chat for the authenticated customer.

**Endpoint:** `POST /api/v1/customer/chats`

**Headers:**
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer <FIREBASE_ID_TOKEN>"
}
```

**Request Body:** (Optional)
```json
{
  "subject": "Help with booking",
  "initialMessage": "Hi, I need help with my booking"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "chat": {
      "id": 1,
      "customerId": 123,
      "adminId": null,
      "status": "active",
      "unreadCustomerCount": 0,
      "lastMessageAt": "2025-11-08T14:30:00.000Z"
    }
  }
}
```

**Error Response:** `500 Internal Server Error`
```json
{
  "success": false,
  "message": "Failed to create/get chat",
  "error": "Error details"
}
```

---

### 2. Get Chat Messages

Retrieves all messages for a specific chat with pagination.

**Endpoint:** `GET /api/v1/customer/chats/{chatId}/messages`

**Headers:**
```json
{
  "Authorization": "Bearer <FIREBASE_ID_TOKEN>"
}
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | integer | 1 | Page number |
| limit | integer | 50 | Messages per page |

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "chat": {
      "id": 1,
      "status": "active",
      "unreadCustomerCount": 2
    },
    "messages": [
      {
        "id": 1,
        "chatId": 1,
        "message": "Hi, I need help with my booking",
        "senderType": "customer",
        "senderId": 123,
        "messageType": "text",
        "attachmentUrl": null,
        "isRead": true,
        "readAt": "2025-11-08T14:31:00.000Z",
        "createdAt": "2025-11-08T14:30:00.000Z"
      },
      {
        "id": 2,
        "chatId": 1,
        "message": "Hello! How can I help you today?",
        "senderType": "admin",
        "senderId": 5,
        "messageType": "text",
        "attachmentUrl": null,
        "isRead": false,
        "readAt": null,
        "createdAt": "2025-11-08T14:31:00.000Z"
      }
    ],
    "pagination": {
      "total": 2,
      "page": 1,
      "limit": 50,
      "totalPages": 1
    }
  }
}
```

**Error Responses:**

`404 Not Found` - Chat doesn't exist or doesn't belong to customer
```json
{
  "success": false,
  "message": "Chat not found"
}
```

`500 Internal Server Error`
```json
{
  "success": false,
  "message": "Failed to fetch messages",
  "error": "Error details"
}
```

---

### 3. Mark Messages as Read

Marks all admin messages in the chat as read for the customer.

**Endpoint:** `PATCH /api/v1/customer/chats/{chatId}/read`

**Headers:**
```json
{
  "Authorization": "Bearer <FIREBASE_ID_TOKEN>"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Messages marked as read"
}
```

**Error Responses:**

`404 Not Found`
```json
{
  "success": false,
  "message": "Chat not found"
}
```

`500 Internal Server Error`
```json
{
  "success": false,
  "message": "Failed to mark messages as read",
  "error": "Error details"
}
```

---

## Socket.IO Integration

### Connection Setup

```javascript
import io from 'socket.io-client';

const SOCKET_URL = 'http://localhost:3001'; // Replace with your server URL

const socket = io(SOCKET_URL, {
  transports: ['websocket', 'polling'],
  reconnection: true,
  reconnectionDelay: 1000,
  reconnectionAttempts: 5
});

// Connection event
socket.on('connect', () => {
  console.log('Connected to chat server');

  // Join as customer
  socket.emit('user:join', {
    userType: 'customer',
    userId: customerId
  });
});

// Disconnection event
socket.on('disconnect', () => {
  console.log('Disconnected from chat server');
});
```

---

### Socket.IO Events

#### 1. User Join
**Emit:** `user:join`

```javascript
socket.emit('user:join', {
  userType: 'customer',
  userId: 123
});
```

**Response:** `user:joined`
```javascript
socket.on('user:joined', (data) => {
  console.log(data);
  // { success: true, message: "Connected to chat server" }
});
```

---

#### 2. Join Chat Room
**Emit:** `chat:join`

```javascript
socket.emit('chat:join', {
  chatId: 1
});
```

**Response:** `chat:joined`
```javascript
socket.on('chat:joined', (data) => {
  console.log(data);
  // { success: true, chatId: 1 }
});
```

---

#### 3. Send Message
**Emit:** `message:send`

```javascript
socket.emit('message:send', {
  chatId: 1,
  message: 'Hello, I need assistance',
  senderType: 'customer',
  senderId: 123
});
```

**Note:** No direct response. Message will be broadcasted to all participants via `message:received` event.

---

#### 4. Receive Messages
**Listen:** `message:received`

```javascript
socket.on('message:received', (message) => {
  console.log('New message:', message);
  /*
  {
    id: 3,
    chatId: 1,
    message: "Sure, I can help you with that",
    senderType: "admin",
    senderId: 5,
    createdAt: "2025-11-08T14:35:00.000Z",
    isRead: false
  }
  */

  // Update your chat UI with the new message
  updateChatUI(message);
});
```

---

#### 5. Mark Messages as Read
**Emit:** `messages:mark_read`

```javascript
socket.emit('messages:mark_read', {
  chatId: 1,
  userType: 'customer'
});
```

**Response:** `messages:marked_read`
```javascript
socket.on('messages:marked_read', (data) => {
  console.log('Messages marked as read:', data);
  // { chatId: 1, userType: 'customer' }
});
```

---

#### 6. Typing Indicators (Optional)

**Start typing:**
```javascript
socket.emit('user:typing', {
  chatId: 1,
  userType: 'customer',
  userName: 'John Doe'
});
```

**Stop typing:**
```javascript
socket.emit('user:stop_typing', {
  chatId: 1,
  userType: 'customer'
});
```

**Listen for admin typing:**
```javascript
socket.on('user:typing', (data) => {
  if (data.userType === 'admin') {
    showTypingIndicator(data.userName);
  }
});

socket.on('user:stop_typing', (data) => {
  if (data.userType === 'admin') {
    hideTypingIndicator();
  }
});
```

---

## Mobile Implementation

### Complete ChatService Class

```javascript
// services/ChatService.js
import io from 'socket.io-client';
import AsyncStorage from '@react-native-async-storage/async-storage';

class ChatService {
  constructor() {
    this.socket = null;
    this.listeners = {};
  }

  async connect() {
    const customer = await AsyncStorage.getItem('customer');
    const customerId = JSON.parse(customer).id;

    this.socket = io('http://your-server.com:3001', {
      transports: ['websocket', 'polling'],
      reconnection: true,
      reconnectionDelay: 1000,
      reconnectionAttempts: 5
    });

    this.socket.on('connect', () => {
      console.log('Socket connected');
      this.socket.emit('user:join', {
        userType: 'customer',
        userId: customerId
      });
    });

    this.socket.on('disconnect', () => {
      console.log('Socket disconnected');
    });

    this.socket.on('message:received', (message) => {
      this.notifyListeners('message', message);
    });

    this.socket.on('messages:marked_read', (data) => {
      this.notifyListeners('messagesRead', data);
    });

    this.socket.on('user:typing', (data) => {
      this.notifyListeners('typing', data);
    });

    this.socket.on('user:stop_typing', (data) => {
      this.notifyListeners('stopTyping', data);
    });
  }

  joinChat(chatId) {
    if (this.socket) {
      this.socket.emit('chat:join', { chatId });
    }
  }

  sendMessage(chatId, message, senderId) {
    if (this.socket) {
      this.socket.emit('message:send', {
        chatId,
        message,
        senderType: 'customer',
        senderId
      });
    }
  }

  markAsRead(chatId) {
    if (this.socket) {
      this.socket.emit('messages:mark_read', {
        chatId,
        userType: 'customer'
      });
    }
  }

  startTyping(chatId, userName) {
    if (this.socket) {
      this.socket.emit('user:typing', {
        chatId,
        userType: 'customer',
        userName
      });
    }
  }

  stopTyping(chatId) {
    if (this.socket) {
      this.socket.emit('user:stop_typing', {
        chatId,
        userType: 'customer'
      });
    }
  }

  // Event listener management
  addListener(event, callback) {
    if (!this.listeners[event]) {
      this.listeners[event] = [];
    }
    this.listeners[event].push(callback);
  }

  removeListener(event, callback) {
    if (this.listeners[event]) {
      this.listeners[event] = this.listeners[event].filter(
        cb => cb !== callback
      );
    }
  }

  notifyListeners(event, data) {
    if (this.listeners[event]) {
      this.listeners[event].forEach(callback => callback(data));
    }
  }

  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
    }
  }
}

export default new ChatService();
```

---

### React Native Chat Screen Example

```javascript
// screens/ChatScreen.js
import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  FlatList,
  TextInput,
  TouchableOpacity,
  Text,
  StyleSheet,
  KeyboardAvoidingView,
  Platform
} from 'react-native';
import ChatService from '../services/ChatService';
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const ChatScreen = ({ route }) => {
  const { chatId, customerId } = route.params;
  const [messages, setMessages] = useState([]);
  const [inputText, setInputText] = useState('');
  const [loading, setLoading] = useState(true);
  const flatListRef = useRef(null);

  useEffect(() => {
    initializeChat();

    return () => {
      ChatService.removeListener('message', handleNewMessage);
      ChatService.disconnect();
    };
  }, []);

  const initializeChat = async () => {
    // Connect to Socket.IO
    await ChatService.connect();

    // Fetch existing messages
    await fetchMessages();

    // Join chat room
    ChatService.joinChat(chatId);

    // Listen for new messages
    ChatService.addListener('message', handleNewMessage);
  };

  const fetchMessages = async () => {
    try {
      setLoading(true);
      const token = await AsyncStorage.getItem('customerToken');
      const response = await axios.get(
        `http://your-server.com:3001/api/v1/customer/chats/${chatId}/messages`,
        {
          headers: { Authorization: `Bearer ${token}` }
        }
      );

      if (response.data.success) {
        setMessages(response.data.data.messages);
        ChatService.markAsRead(chatId);
        scrollToBottom();
      }
    } catch (error) {
      console.error('Error fetching messages:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleNewMessage = (message) => {
    setMessages(prev => [...prev, message]);
    scrollToBottom();

    // Mark as read if message is from admin
    if (message.senderType === 'admin') {
      ChatService.markAsRead(chatId);
    }
  };

  const sendMessage = () => {
    if (inputText.trim()) {
      ChatService.sendMessage(chatId, inputText.trim(), customerId);
      setInputText('');
    }
  };

  const scrollToBottom = () => {
    setTimeout(() => {
      flatListRef.current?.scrollToEnd({ animated: true });
    }, 100);
  };

  const renderMessage = ({ item }) => {
    const isCustomer = item.senderType === 'customer';

    return (
      <View style={[
        styles.messageBubble,
        isCustomer ? styles.customerBubble : styles.adminBubble
      ]}>
        <Text style={[
          styles.messageText,
          isCustomer ? styles.customerText : styles.adminText
        ]}>
          {item.message}
        </Text>
        <Text style={styles.timeText}>
          {new Date(item.createdAt).toLocaleTimeString([], {
            hour: '2-digit',
            minute: '2-digit'
          })}
        </Text>
      </View>
    );
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      keyboardVerticalOffset={90}
    >
      <FlatList
        ref={flatListRef}
        data={messages}
        renderItem={renderMessage}
        keyExtractor={item => item.id.toString()}
        contentContainerStyle={styles.messageList}
        onContentSizeChange={scrollToBottom}
      />

      <View style={styles.inputContainer}>
        <TextInput
          value={inputText}
          onChangeText={setInputText}
          placeholder="Type a message..."
          style={styles.input}
          multiline
        />
        <TouchableOpacity
          onPress={sendMessage}
          style={styles.sendButton}
          disabled={!inputText.trim()}
        >
          <Text style={styles.sendButtonText}>Send</Text>
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5'
  },
  messageList: {
    padding: 16
  },
  messageBubble: {
    maxWidth: '75%',
    padding: 12,
    borderRadius: 16,
    marginBottom: 8
  },
  customerBubble: {
    alignSelf: 'flex-end',
    backgroundColor: '#007AFF',
    borderBottomRightRadius: 4
  },
  adminBubble: {
    alignSelf: 'flex-start',
    backgroundColor: '#E5E5EA',
    borderBottomLeftRadius: 4
  },
  messageText: {
    fontSize: 16,
    lineHeight: 20
  },
  customerText: {
    color: 'white'
  },
  adminText: {
    color: 'black'
  },
  timeText: {
    fontSize: 11,
    marginTop: 4,
    opacity: 0.6
  },
  inputContainer: {
    flexDirection: 'row',
    padding: 12,
    backgroundColor: 'white',
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0'
  },
  input: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 8,
    marginRight: 8,
    maxHeight: 100
  },
  sendButton: {
    backgroundColor: '#007AFF',
    borderRadius: 20,
    paddingHorizontal: 20,
    justifyContent: 'center'
  },
  sendButtonText: {
    color: 'white',
    fontWeight: '600'
  }
});

export default ChatScreen;
```

---

### API Client Setup

```javascript
// api/chatApi.js
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const API_BASE_URL = 'http://your-server.com:3001';

const getAuthHeader = async () => {
  const token = await AsyncStorage.getItem('customerToken');
  return {
    Authorization: `Bearer ${token}`
  };
};

export const chatApi = {
  // Create or get chat
  createOrGetChat: async () => {
    const headers = await getAuthHeader();
    const response = await axios.post(
      `${API_BASE_URL}/api/v1/customer/chats`,
      {},
      { headers }
    );
    return response.data;
  },

  // Get messages
  getMessages: async (chatId, page = 1, limit = 50) => {
    const headers = await getAuthHeader();
    const response = await axios.get(
      `${API_BASE_URL}/api/v1/customer/chats/${chatId}/messages`,
      {
        params: { page, limit },
        headers
      }
    );
    return response.data;
  },

  // Mark as read
  markAsRead: async (chatId) => {
    const headers = await getAuthHeader();
    const response = await axios.patch(
      `${API_BASE_URL}/api/v1/customer/chats/${chatId}/read`,
      {},
      { headers }
    );
    return response.data;
  }
};
```

---

## Testing

### 1. Test REST APIs with cURL

```bash
# Get customer Firebase token first
CUSTOMER_TOKEN="your_firebase_id_token"

# Create or get chat
curl -X POST http://localhost:3001/api/v1/customer/chats \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CUSTOMER_TOKEN"

# Get messages
curl -X GET "http://localhost:3001/api/v1/customer/chats/1/messages?page=1&limit=50" \
  -H "Authorization: Bearer $CUSTOMER_TOKEN"

# Mark messages as read
curl -X PATCH http://localhost:3001/api/v1/customer/chats/1/read \
  -H "Authorization: Bearer $CUSTOMER_TOKEN"
```

### 2. Test Socket.IO Connection

```javascript
// test-socket.js
const io = require('socket.io-client');

const socket = io('http://localhost:3001');

socket.on('connect', () => {
  console.log('✅ Connected');

  socket.emit('user:join', {
    userType: 'customer',
    userId: 123
  });
});

socket.on('user:joined', (data) => {
  console.log('✅ Joined:', data);

  socket.emit('chat:join', { chatId: 1 });
});

socket.on('chat:joined', (data) => {
  console.log('✅ Chat joined:', data);

  socket.emit('message:send', {
    chatId: 1,
    message: 'Test message',
    senderType: 'customer',
    senderId: 123
  });
});

socket.on('message:received', (message) => {
  console.log('✅ Message received:', message);
});

socket.on('disconnect', () => {
  console.log('❌ Disconnected');
});
```

---

## Production Deployment

### 1. Environment Variables

```env
# .env
SOCKET_URL=https://api.yourdomain.com
```

### 2. SSL/TLS Configuration (Plesk)

For production deployment on Plesk, ensure:

**Nginx Configuration:**
```nginx
location /socket.io/ {
    proxy_pass http://localhost:3001;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_cache_bypass $http_upgrade;
}
```

**SSL Certificate:**
- Use Let's Encrypt or your SSL certificate
- Socket.IO will automatically use WSS (WebSocket Secure) over HTTPS

**Update Mobile App URL:**
```javascript
// Use HTTPS in production
const SOCKET_URL = 'https://api.yourdomain.com';
```

### 3. CORS Configuration

Update `socket/socketManager.js`:
```javascript
const io = new Server(server, {
    cors: {
        origin: ["https://yourdomain.com", "https://admin.yourdomain.com"],
        methods: ["GET", "POST"],
        credentials: true
    }
});
```

---

## Database Schema

### Chats Table
```sql
CREATE TABLE chats (
  id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT NOT NULL,
  admin_id INT NULL,
  status ENUM('active', 'closed', 'archived') DEFAULT 'active',
  last_message_at DATETIME NULL,
  unread_customer_count INT DEFAULT 0,
  unread_admin_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (admin_id) REFERENCES users(id)
);
```

### Messages Table
```sql
CREATE TABLE messages (
  id INT PRIMARY KEY AUTO_INCREMENT,
  chat_id INT NOT NULL,
  sender_type ENUM('admin', 'customer') NOT NULL,
  sender_id INT NOT NULL,
  message TEXT NOT NULL,
  message_type ENUM('text', 'image', 'file') DEFAULT 'text',
  attachment_url VARCHAR(255) NULL,
  is_read BOOLEAN DEFAULT FALSE,
  read_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE
);
```

---

## Troubleshooting

### Common Issues

**1. Socket.IO Connection Fails**
- Check CORS configuration
- Verify Socket.IO URL is correct
- Ensure WebSocket is not blocked by firewall

**2. Messages Not Appearing**
- Verify `chat:join` was called
- Check Socket.IO connection status
- Ensure `message:received` listener is registered

**3. Authentication Errors**
- Verify Firebase token is valid
- Check token expiration
- Ensure Authorization header is included

**4. Plesk WebSocket Issues**
- Verify nginx configuration for WebSocket upgrade
- Check firewall rules for port 3001
- Ensure SSL certificate is installed

---

## Support

For issues or questions:
1. Check server logs: `arbo-trck-back/logs/`
2. Monitor Socket.IO connections in admin panel
3. Test with cURL commands first
4. Verify database tables exist: `chats`, `messages`

---

## Changelog

### v1.0.0 (2025-11-08)
- Initial release
- REST API endpoints for mobile
- Socket.IO real-time messaging
- Admin panel integration
- Read receipts and typing indicators

---

**Last Updated:** November 8, 2025
**API Version:** 1.0.0
**Socket.IO Version:** Latest
