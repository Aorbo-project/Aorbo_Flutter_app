class MessageModel {
  final int? id;
  final int? chatId;
  final String? message;
  final String? senderType; // 'admin' or 'customer'
  final int? senderId;
  final String? messageType; // 'text', 'image', 'file'
  final String? attachmentUrl;
  final bool? isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MessageModel({
    this.id,
    this.chatId,
    this.message,
    this.senderType,
    this.senderId,
    this.messageType,
    this.attachmentUrl,
    this.isRead,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int?,
      chatId: json['chat_id'] as int? ?? json['chatId'] as int?,
      message: json['message'] as String?,
      senderType: json['sender_type'] as String? ?? json['senderType'] as String?,
      senderId: json['sender_id'] as int? ?? json['senderId'] as int?,
      messageType: json['message_type'] as String? ?? json['messageType'] as String? ?? 'text',
      attachmentUrl: json['attachment_url'] as String? ?? json['attachmentUrl'] as String?,
      isRead: json['is_read'] as bool? ?? json['isRead'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : json['readAt'] != null
              ? DateTime.parse(json['readAt'] as String)
              : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'message': message,
      'sender_type': senderType,
      'sender_id': senderId,
      'message_type': messageType,
      'attachment_url': attachmentUrl,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  MessageModel copyWith({
    int? id,
    int? chatId,
    String? message,
    String? senderType,
    int? senderId,
    String? messageType,
    String? attachmentUrl,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      message: message ?? this.message,
      senderType: senderType ?? this.senderType,
      senderId: senderId ?? this.senderId,
      messageType: messageType ?? this.messageType,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isFromAdmin => senderType == 'admin';
  bool get isFromCustomer => senderType == 'customer';

  @override
  String toString() {
    return 'MessageModel(id: $id, chatId: $chatId, message: $message, senderType: $senderType, isRead: $isRead)';
  }
}
