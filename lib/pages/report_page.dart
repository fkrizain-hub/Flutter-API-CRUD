import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

/// Halaman Laporan Keuangan — grafik bar chart + pie chart visual.
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  List<Map<String, dynamic>> _categoryData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    final pemasukan = await DatabaseHelper.getTotalByType('pemasukan');
    final pengeluaran = await DatabaseHelper.getTotalByType('pengeluaran');
    final categories = await DatabaseHelper.getTotalByCategory('pengeluaran');
    setState(() {
      _totalPemasukan = pemasukan;
      _totalPengeluaran = pengeluaran;
      _categoryData = categories;
      _isLoading = false;
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

  final List<Color> _chartColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  IconData _getCategoryIcon(String kategori) {
    switch (kategori) {
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
    final total = _totalPemasukan + _totalPengeluaran;
    final pemasukanPct = total > 0 ? _totalPemasukan / total : 0.0;
    final pengeluaranPct = total > 0 ? _totalPengeluaran / total : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('Laporan Keuangan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReport,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Pie Chart Visual ──
                    _buildPieSection(pemasukanPct, pengeluaranPct, saldo),
                    const SizedBox(height: 20),
                    // ── Bar Chart Per Kategori ──
                    _buildBarChartSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  /// Pie chart section — pemasukan vs pengeluaran
  Widget _buildPieSection(double pemasukanPct, double pengeluaranPct, double saldo) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Ringkasan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Custom Pie Chart
            SizedBox(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: _PieChartPainter(
                  pemasukanPct: pemasukanPct,
                  pengeluaranPct: pengeluaranPct,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Saldo', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        _formatRupiah(saldo),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: saldo >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _legendItem('Pemasukan', Colors.green, _formatRupiah(_totalPemasukan),
                    '${(pemasukanPct * 100).toStringAsFixed(1)}%'),
                _legendItem('Pengeluaran', Colors.red, _formatRupiah(_totalPengeluaran),
                    '${(pengeluaranPct * 100).toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color, String amount, String pct) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(amount, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        Text(pct, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  /// Bar chart section — pengeluaran per kategori
  Widget _buildBarChartSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pengeluaran per Kategori',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_categoryData.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Belum ada data pengeluaran',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ..._categoryData.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final kategori = item['kategori'] as String;
                final total = (item['total'] as num).toDouble();
                final maxVal = (_categoryData.first['total'] as num).toDouble();
                final pct = maxVal > 0 ? total / maxVal : 0.0;
                final color = _chartColors[i % _chartColors.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_getCategoryIcon(kategori), color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(kategori, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                Text(_formatRupiah(total), style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: Colors.grey.shade200,
                                color: color,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// Custom painter untuk pie chart donut
class _PieChartPainter extends CustomPainter {
  final double pemasukanPct;
  final double pengeluaranPct;

  _PieChartPainter({required this.pemasukanPct, required this.pengeluaranPct});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 20.0;
    const startAngle = -1.5708; // -π/2 (start from top)

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Background circle
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    if (pemasukanPct + pengeluaranPct == 0) return;

    // Pemasukan arc (green)
    final greenPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final greenSweep = pemasukanPct * 2 * 3.14159;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      greenSweep,
      false,
      greenPaint,
    );

    // Pengeluaran arc (red)
    final redPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final redSweep = pengeluaranPct * 2 * 3.14159;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle + greenSweep,
      redSweep,
      false,
      redPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
