import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

final userProfileProvider = Provider<UserProfile>((ref) {
  return UserProfile(
    name: 'John Doe',
    heightCm: 186,
    weightKg: 80,
    // You can use an avatar from services like:
    // - https://ui-avatars.com/
    // - https://avatars.dicebear.com/
    // - https://pravatar.cc/
    avatarUrl: 'https://media.istockphoto.com/id/1750373920/photo/surfer-riding-wave-at-sunrise.webp?a=1&b=1&s=612x612&w=0&k=20&c=3o19nVaKlKWYGcRR41ItH1lhrqCZyRgi2HDFDGF4JlA=',
  );
});