import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  final String name;
  final int heightCm;
  final int weightKg;
  final String? avatarUrl;
  final DateTime lastActive;

  const UserProfile._({
    required this.name,
    required this.heightCm,
    required this.weightKg,
    this.avatarUrl,
    required this.lastActive,
  });

  factory UserProfile({
    required String name,
    required int heightCm,
    required int weightKg,
    String? avatarUrl,
    DateTime? lastActive,
  }) {
    return UserProfile._(
      name: name,
      heightCm: heightCm,
      weightKg: weightKg,
      avatarUrl: avatarUrl,
      lastActive: lastActive ?? DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? name,
    int? heightCm,
    int? weightKg,
    String? avatarUrl,
    DateTime? lastActive,
  }) {
    return UserProfile._(
      name: name ?? this.name,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.name == name &&
        other.heightCm == heightCm &&
        other.weightKg == weightKg &&
        other.avatarUrl == avatarUrl &&
        other.lastActive == lastActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      heightCm,
      weightKg,
      avatarUrl,
      lastActive,
    );
  }
}