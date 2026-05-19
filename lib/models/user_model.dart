import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String? email;
  final String? photoUrl;
  final String deviceId;
  final double xp;
  final double level;
  final double coin;
  final DateTime createdAt;
  final bool isGuest;
  final String? referredBy;

  const UserModel({
    required this.userId,
    required this.name,
    required this.deviceId,
    required this.xp,
    required this.level,
    required this.coin,
    required this.createdAt,
    required this.isGuest,
    this.email,
    this.photoUrl,
    this.referredBy,
  });

  /// Firestore map — uses Timestamp for dates.
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'device_id': deviceId,
      'xp': xp,
      'level': level,
      'coin': coin,
      'created_at': Timestamp.fromDate(createdAt),
      'is_guest': isGuest,
      'referred_by': referredBy,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      photoUrl: map['photo_url'] as String?,
      deviceId: map['device_id'] as String,
      xp: (map['xp'] as num).toDouble(),
      level: (map['level'] as num).toDouble(),
      coin: (map['coin'] as num).toDouble(),
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.parse(map['created_at'] as String),
      isGuest: map['is_guest'] as bool? ?? false,
      referredBy: map['referred_by'] as String?,
    );
  }

  /// Hive-safe map — uses ISO-8601 strings instead of Firestore Timestamps.
  Map<String, dynamic> toLocalMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'device_id': deviceId,
      'xp': xp,
      'level': level,
      'coin': coin,
      'created_at': createdAt.toIso8601String(),
      'is_guest': isGuest,
      'referred_by': referredBy,
    };
  }

  factory UserModel.fromLocalMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      photoUrl: map['photo_url'] as String?,
      deviceId: map['device_id'] as String,
      xp: (map['xp'] as num).toDouble(),
      level: (map['level'] as num).toDouble(),
      coin: (map['coin'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      isGuest: map['is_guest'] as bool? ?? false,
      referredBy: map['referred_by'] as String?,
    );
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? photoUrl,
    String? deviceId,
    double? xp,
    double? level,
    double? coin,
    DateTime? createdAt,
    bool? isGuest,
    String? referredBy,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      deviceId: deviceId ?? this.deviceId,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      coin: coin ?? this.coin,
      createdAt: createdAt ?? this.createdAt,
      isGuest: isGuest ?? this.isGuest,
      referredBy: referredBy ?? this.referredBy,
    );
  }
}
