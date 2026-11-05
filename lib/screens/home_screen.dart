import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/auth_service.dart';
import '../main.dart';

import 'profile_screen.dart';
import 'tips_screen.dart';
import 'module_screen.dart';
import 'quiz_screen.dart';
import 'schedule_screen.dart';
import 'target_screen.dart';
import 'study_stats_screen..dart';
import 'flashcard_subject_screen.dart';
import '../services/account_api.dart';
import 'favorite_screen.dart';
import 'scholarship_screen.dart';
import 'study_abroad_screen.dart';
import 'work_abroad_screen.dart';
import 'toefl_screen.dart';
import 'best_choice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Halo 👋";
  String? profileImageUrl;
  final TextEditingController _searchController = TextEditingController();

  final List<_MenuItem> topMenuItems = [
    _MenuItem('Modul', Icons.menu_book, Colors.blue),
    _MenuItem('Kuis', Icons.quiz, Colors.orange),
    _MenuItem('Jadwal', Icons.schedule, Colors.green),
  ];

  final List<_MenuItem> bottomMenuItems = [
    _MenuItem('Target', Icons.flag, Colors.purple),
    _MenuItem('Statistik', Icons.bar_chart, Colors.teal),
    _MenuItem('Flashcard', Icons.style, Colors.red),
  ];

  final List<String> bannerImages = [
    'assets/banner1.jpg',
    'assets/banner2.jpg',
    'assets/banner3.jpg',
  ];

  final List<_FeatureItem> featureItems = [
    _FeatureItem(
      'Beasiswa',
      'assets/beasiswa.png',
      destination: ScholarshipScreen(),
    ),
    _FeatureItem(
      'Siap Kuliah di Luar Negeri',
      'assets/kuliah_luar.png',
      destination: StudyAbroadScreen(),
    ),
    _FeatureItem(
      'Siap Kerja di Luar Negeri',
      'assets/kerja_luar.png',
      destination: WorkAbroadScreen(),
    ),
    _FeatureItem('Tes\nTOEFL', 'assets/toefl.png', destination: TOEFLScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final email = await AuthService.getCurrentUserEmail();
    if (email != null) {
      try {
        final profile = await AuthService.getUserProfile(email);
        if (!mounted) return;
        setState(() {
          userName = "Halo, ${profile['name'] ?? 'User'} 👋";
          profileImageUrl = profile['profile_picture'];
        });
      } on AccountApiException catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Color(0xFF0B0E33), Color(0xFF102040), Color(0xFF1A237E)]
                : [Color(0xFF2196F3), Color(0xFFBBDEFB), Color(0xFFFFF176)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 16),
                _buildSearchBar(isDark),
                const SizedBox(height: 16),
                _buildHorizontalMenuBar(isDark),
                const SizedBox(height: 20),
                _buildGridMenu(topMenuItems, isDark),
                const SizedBox(height: 20),
                _buildBannerSlider(),
                const SizedBox(height: 20),
                _buildGridMenu(bottomMenuItems, isDark),
                const SizedBox(height: 24),
                _buildSubjectFavorites(isDark),
                const SizedBox(height: 24),
                _buildFeatureSection(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          userName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => themeNotifier.toggleTheme(),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen()),
                ).then((_) {
                  _loadUserName(); // refresh data saat kembali dari ProfileScreen
                });
              },
              child: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari materi, pelajaran...',
              filled: true,
              fillColor: isDark ? Colors.grey[800] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            final query = _searchController.text.trim();
            if (query.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ModuleScreen(searchQuery: query),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? Colors.white24 : Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Icon(Icons.search, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildHorizontalMenuBar(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildHorizontalMenu("Peringkat", Icons.leaderboard, isDark, () {
            Navigator.pushNamed(context, '/leaderboard-all');
          }),
          _buildHorizontalMenu(
            "Tips Belajar",
            Icons.tips_and_updates,
            isDark,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipsScreen()),
              );
            },
          ),
          _buildHorizontalMenu("Favorit", Icons.favorite, isDark, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FavoriteScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBannerSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 160,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: bannerImages.map((path) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(path, fit: BoxFit.cover, width: double.infinity),
        );
      }).toList(),
    );
  }

  Widget _buildGridMenu(List<_MenuItem> items, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) => _buildMenuItem(items[index], isDark),
    );
  }

  Widget _buildMenuItem(_MenuItem item, bool isDark) {
    return InkWell(
      onTap: () {
        switch (item.title) {
          case 'Modul':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ModuleScreen()),
            );
            break;
          case 'Kuis':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuizScreen()),
            );
            break;
          case 'Jadwal':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ScheduleScreen()),
            );
            break;
          case 'Target':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TargetScreen()),
            );
            break;
          case 'Statistik':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StudyStatsScreen()),
            );
            break;
          case 'Flashcard':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FlashcardSubjectScreen()),
            );
            break;
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 30),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: TextStyle(
                color: isDark ? Colors.white70 : item.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalMenu(
    String label,
    IconData icon,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectFavorites(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Favorit Berdasarkan Pelajaran",
          style: _sectionTitleStyle(isDark),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSubjectButton("Matematika", isDark),
            _buildSubjectButton("Bahasa Inggris", isDark),
            _buildSubjectButton("Fisika", isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectButton(String subject, bool isDark) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.favorite, size: 18),
      label: Text(subject),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.white12 : Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FavoriteScreen(subject: subject)),
        );
      },
    );
  }

  Widget _buildFeatureSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Pilihan Belajar Terbaik", style: _sectionTitleStyle(isDark)),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BestChoiceScreen()),
                );
              },
              child: const Text("Lihat Semua"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: featureItems
                .map((item) => _buildFeatureOption(item))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureOption(_FeatureItem item) {
    return GestureDetector(
      onTap: () {
        if (item.destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.destination!),
          );
        }
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                item.imagePath,
                height: 80,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _sectionTitleStyle(bool isDark) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black87,
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Color color;

  _MenuItem(this.title, this.icon, this.color);
}

class _FeatureItem {
  final String title;
  final String imagePath;
  final Widget? destination;

  _FeatureItem(this.title, this.imagePath, {this.destination});
}
