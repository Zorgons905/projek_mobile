import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test123/models/leaderboard_model.dart';
import 'package:test123/providers/leaderboard_provider.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(leaderboardDataProvider); // Refresh data
            },
          ),
        ],
      ),
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err\nSilakan coba lagi.'),
        ),
        data: (leaderboardEntries) {
          if (leaderboardEntries.isEmpty) {
            return const Center(child: Text('Tidak ada data leaderboard.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildLeaderboardHeader(context),
                  const Divider(height: 1, color: Colors.grey),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: leaderboardEntries.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = leaderboardEntries[index];
                      return _buildLeaderboardRow(index + 1, entry);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: const Row(
        children: [
          Expanded(flex: 1, child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 4, child: Text('Nama Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Skor Kuis', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Progress Materi', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Kuis Selesai', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(int rank, LeaderboardEntry entry) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      color: rank.isEven ? Colors.grey[50] : Colors.white,
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 4, child: Text(entry.studentName)),
          Expanded(flex: 2, child: Text(entry.quizScore.toString(), textAlign: TextAlign.center)),
          Expanded(
            flex: 2,
            child: Text(
              '${(entry.materialProgress * 100).toInt()}%',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(flex: 2, child: Text(entry.quizzesCompleted.toString(), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
