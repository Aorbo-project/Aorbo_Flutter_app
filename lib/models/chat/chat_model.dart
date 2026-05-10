class ChatModel {
  final int? id;
  final int? customerId;
  final int? adminId;
  final String? status;
  final int? unreadCustomerCount;
  final int? unreadAdminCount;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatModel({
    this.id,
    this.customerId,
    this.adminId,
    this.status,
    this.unreadCustomerCount,
    this.unreadAdminCount,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as int?,
      customerId: json['customer_id'] as int? ?? json['customerId'] as int?,
      adminId: json['admin_id'] as int? ?? json['adminId'] as int?,
      status: json['status'] as String?,
      unreadCustomerCount: json['unread_customer_count'] as int? ??
          json['unreadCustomerCount'] as int?,
      unreadAdminCount: json['unread_admin_count'] as int? ??
          json['unreadAdminCount'] as int?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : json['lastMessageAt'] != null
              ? DateTime.parse(json['lastMessageAt'] as String)
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
      'customer_id': customerId,
      'admin_id': adminId,
      'status': status,
      'unread_customer_count': unreadCustomerCount,
      'unread_admin_count': unreadAdminCount,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ChatModel copyWith({
    int? id,
    int? customerId,
    int? adminId,
    String? status,
    int? unreadCustomerCount,
    int? unreadAdminCount,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      adminId: adminId ?? this.adminId,
      status: status ?? this.status,
      unreadCustomerCount: unreadCustomerCount ?? this.unreadCustomerCount,
      unreadAdminCount: unreadAdminCount ?? this.unreadAdminCount,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ChatModel(id: $id, customerId: $customerId, adminId: $adminId, status: $status, unreadCustomerCount: $unreadCustomerCount)';
  }
}
