import 'package:flutter/material.dart';
import 'package:test123/models/leaderboard_model.dart';
import 'package:test123/services/leaderboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late Future<List<LeaderboardEntry>> _leaderboardData;

  @override
  void initState() {
    super.initState();
    _leaderboardData = LeaderboardService().getLeaderboardData();
  }

  // Fungsi untuk me-refresh data leaderboard
  Future<void> _refreshLeaderboard() async {
    setState(() {
      _leaderboardData = LeaderboardService().getLeaderboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLeaderboard,
          ),
        ],
      ),
      body: FutureBuilder<List<LeaderboardEntry>>(
        future: _leaderboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}\nSilakan coba lagi.'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data leaderboard.'));
          } else {
            // Data berhasil dimuat
            final leaderboardEntries = snapshot.data!;

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Header Tabel
                    _buildLeaderboardHeader(),
                    const Divider(height: 1, color: Colors.grey),
                    // List Entri Leaderboard
                    ListView.separated(
                      shrinkWrap: true, // Penting agar ListView tidak mengambil semua ruang
                      physics: const NeverScrollableScrollPhysics(), // Menonaktifkan scroll ListView
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
          }
        },
      ),
    );
  }

  Widget _buildLeaderboardHeader() {
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