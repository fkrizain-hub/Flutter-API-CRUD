import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'report_page.dart';

/// Halaman Home — dashboard dengan greeting, saldo, transaksi terakhir, dan grid fitur.
class HomePage extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;
  const HomePage({super.key, this.onTabChanged});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final pemasukan = await DatabaseHelper.getTotalByType('pemasukan');
    final pengeluaran = await DatabaseHelper.getTotalByType('pengeluaran');
    final all = await DatabaseHelper.queryAll();
    setState(() {
      _totalPemasukan = pemasukan;
      _totalPengeluaran = pengeluaran;
      _recentTransactions = all.take(3).toList(); // 3 transaksi terakhir
    });
  }

  String _formatRupiah(double amount) {
    final str = amount.toStringAsFixed(0);
    final chars = str.split('').reversed.toList();
    final result = <String>[];
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) result.add('.');
      result.add(chars[i]);
    }
    return 'Rp ${result.reversed.join()}';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month]} ${now.year}';
  }

  IconData _getCategoryIcon(String kategori) {
    switch (kategori) {
      case 'Gaji': return Icons.work_rounded;
      case 'Bonus': return Icons.card_giftcard_rounded;
      case 'Investasi': return Icons.trending_up_rounded;
      case 'Transfer Masuk': return Icons.call_received_rounded;
      case 'Makanan': return Icons.restaurant_rounded;
      case 'Transport': return Icons.directions_car_rounded;
      case 'Belanja': return Icons.shopping_bag_rounded;
      case 'Tagihan': return Icons.receipt_long_rounded;
      case 'Hiburan': return Icons.movie_rounded;
      case 'Kesehatan': return Icons.medical_services_rounded;
      case 'Pendidikan': return Icons.school_rounded;
      default: return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final saldo = _totalPemasukan - _totalPengeluaran;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero: Greeting + Saldo ──
              _buildHeroSection(saldo),
              const SizedBox(height: 20),

              // ── Transaksi Terakhir ──
              _buildRecentSection(),
              const SizedBox(height: 20),

              // ── Grid Fitur ──
              _buildFeatureGrid(),
              const SizedBox(height: 20),

              // ── Info Card ──
              _buildInfoCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(double saldo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Row(
            children: [
              const Text('👋 ', style: TextStyle(fontSize: 24)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, Fikri!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getFormattedDate(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_rounded,
                    color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Saldo Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saldo Anda',
                    style: TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  _formatRupiah(saldo),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _miniStat(Icons.arrow_downward_rounded, 'Masuk',
                        _formatRupiah(_totalPemasukan), Colors.greenAccent),
                    const SizedBox(width: 16),
                    _miniStat(Icons.arrow_upward_rounded, 'Keluar',
                        _formatRupiah(_totalPengeluaran), Colors.redAccent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.white70)),
            Text(value,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transaksi Terakhir',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0))),
          const SizedBox(height: 10),
          if (_recentTransactions.isEmpty)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('Belum ada transaksi',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              ),
            )
          else
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: _recentTransactions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final t = entry.value;
                  final isPemasukan = t['tipe'] == 'pemasukan';
                  final jumlah = (t['jumlah'] as num).toDouble();
                  final color = isPemasukan ? Colors.green : Colors.red;
                  final icon = _getCategoryIcon(t['kategori'] ?? '');

                  return Column(
                    children: [
                      ListTile(
                        dense: true,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: color, size: 18),
                        ),
                        title: Text(t['judul'] ?? '',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text(t['kategori'] ?? '',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                        trailing: Text(
                          '${isPemasukan ? '+' : '-'} ${_formatRupiah(jumlah)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      if (i < _recentTransactions.length - 1)
                        const Divider(height: 1, indent: 60),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fitur Utama',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0))),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _featureCard(Icons.account_balance_rounded, 'Data Bank',
                  'Daftar bank Indonesia', Colors.blue,
                  onTap: () => widget.onTabChanged?.call(1)),
              _featureCard(Icons.account_balance_wallet_rounded, 'Dompetku',
                  'Catat keuangan', Colors.green,
                  onTap: () => widget.onTabChanged?.call(2)),
              _featureCard(Icons.bar_chart_rounded, 'Laporan',
                  'Grafik pengeluaran', Colors.orange,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ReportPage()))),
              _featureCard(Icons.currency_exchange_rounded, 'Kurs',
                  'Konversi mata uang', Colors.purple,
                  onTap: () => widget.onTabChanged?.call(3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureCard(
      IconData icon, String title, String subtitle, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(title,
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 1,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: Color(0xFF1565C0), size: 26),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mini Project Flutter',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(height: 2),
                    Text(
                      'Mata Kuliah Mobile Computing — Politeknik Manufaktur Bandung',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
