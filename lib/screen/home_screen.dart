import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'list_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hai, $username!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Pilih Kategori',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Temukan berita, blog, dan laporan terbaru',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildMenuCard(
              context,
              title: 'News',
              description:
                  'Get an overview of the latest SpaceFlight news, from various sources. Easily link your users to the right websites',
              icon: Icons.newspaper,
              color: const Color(0xFF4CAF50),
              type: 'articles',
              listTitle: 'Berita Terkini',
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              title: 'Blog',
              description:
                  'Blogs often provide a more detailed overview of launches and missions. A must-have for the serious spaceflight enthusiast',
              icon: Icons.edit_note,
              color: const Color(0xFF2196F3),
              type: 'blogs',
              listTitle: 'Blog Terbaru',
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              title: 'Report',
              description:
                  'Space stations and other missions often publish their data. With SNAPI, you can include it in your application',
              icon: Icons.assessment,
              color: const Color(0xFFFF9800),
              type: 'reports',
              listTitle: 'Laporan Terbaru',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String type,
    required String listTitle,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListScreen(type: type, title: listTitle),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}