import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade800,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Dashboard",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            Icon(Icons.menu, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabButton("Progress", 0),
        SizedBox(width: 16),
        _buildTabButton("Quiz", 1),
      ],
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = selectedIndex == index;
    return ElevatedButton(
      onPressed: () => _onTabTapped(index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blueGrey : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(title),
    );
  }

  Widget _buildDropdownSection(
    String title,
    List<String> items,
    VoidCallback onMoreTap,
  ) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: ExpansionTile(
            initiallyExpanded: true,
            collapsedIconColor: Colors.grey,
            iconColor: Colors.white,
            title: Text(title, style: TextStyle(color: Colors.white)),
            children: [
              ...items.take(3).map((item) {
                return Card(
                  color: Colors.white.withOpacity(0.05),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(item, style: TextStyle(color: Colors.white)),
                  ),
                );
              }),
              if (items.length > 3)
                GestureDetector(
                  onTap: onMoreTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Card(
                      color: Colors.white.withOpacity(0.05),
                      child: ListTile(
                        title: Text(
                          "Lihat Semua",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildDropdownSection(
          "Quiz 1",
          ["Soal 1", "Soal 2", "Soal 3", "Soal 4", "Soal 5"],
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPage(title: "Quiz 1")),
          ),
        ),
        _buildDropdownSection(
          "Quiz 2",
          ["Soal A", "Soal B", "Soal C", "Soal D"],
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPage(title: "Quiz 2")),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildDropdownSection(
          "Module 1",
          ["Step 1", "Step 2", "Step 3", "Step 4"],
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPage(title: "Module 1")),
          ),
        ),
        _buildDropdownSection(
          "Module 2",
          ["Langkah A", "Langkah B", "Langkah C"],
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPage(title: "Module 2")),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Column(
        children: [
          _buildCustomAppBar(),
          SizedBox(height: 8),
          _buildTabButtons(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => selectedIndex = index),
              children: [_buildProgressList(), _buildQuizList()],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  const DetailPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail: $title")),
      body: Center(child: Text("Menampilkan seluruh data $title")),
    );
  }
}
