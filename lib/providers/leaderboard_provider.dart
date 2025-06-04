import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test123/services/leaderboard_service.dart';
import 'package:test123/models/leaderboard_model.dart';

// Provider untuk instance LeaderboardService
final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  return LeaderboardService();
});

// FutureProvider untuk data leaderboard
final leaderboardDataProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return await service.getLeaderboardData();
});
