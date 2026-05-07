import 'package:flutter/material.dart';

/// Halaman Profil dengan CircleAvatar, Card, ListTile, dan AlertDialog sapaan.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showGreeting(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.waving_hand_rounded, color: Color(0xFF1565C0)),
            SizedBox(width: 8),
            Text('Halo!'),
          ],
        ),
        content: const Text(
          'Halo, saya Fikri Zaini!',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Card (Avatar + Nama)
            GestureDetector(
              onTap: () => _showGreeting(context),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage:
                              const AssetImage('assets/pas foto 3x4 biru.jpg'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Fikri Zaini',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Teknik Informatika',
                          style:
                              TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '✋ Ketuk untuk sapaan',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Detail Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildInfoTile(
                    Icons.badge_rounded,
                    'NIM',
                    '224443031',
                    const Color(0xFF1565C0),
                  ),
                  const Divider(height: 1, indent: 72),
                  _buildInfoTile(
                    Icons.school_rounded,
                    'Kampus',
                    'Politeknik Manufaktur Bandung',
                    Colors.orange,
                  ),
                  const Divider(height: 1, indent: 72),
                  _buildInfoTile(
                    Icons.computer_rounded,
                    'Jurusan',
                    'Teknik Mekatronika dan Otomasi Manufaktur',
                    Colors.green,
                  ),
                  const Divider(height: 1, indent: 72),
                  _buildInfoTile(
                    Icons.email_rounded,
                    'Email',
                    'fkrizain@gmail.com',
                    Colors.red,
                  ),
                  const Divider(height: 1, indent: 72),
                  _buildInfoTile(
                    Icons.code_rounded,
                    'GitHub',
                    'github.com/fkrizain-hub',
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String label, String value, Color iconColor) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(
            fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
            fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600),
      ),
    );
  }
}
