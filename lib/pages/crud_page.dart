import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../widgets/transaction_form_sheet.dart';

/// Halaman Dompetku — menampilkan ringkasan saldo dan daftar transaksi CRUD.
class CrudPage extends StatefulWidget {
  const CrudPage({super.key});
  @override
  State<CrudPage> createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  List<Map<String, dynamic>> _transactions = [];
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearching = false;
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.queryAll();
    final pemasukan = await DatabaseHelper.getTotalByType('pemasukan');
    final pengeluaran = await DatabaseHelper.getTotalByType('pengeluaran');
    setState(() {
      _transactions = data;
      _totalPemasukan = pemasukan;
      _totalPengeluaran = pengeluaran;
    });
  }

  Future<void> _onSearch() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      await _loadData();
    } else {
      final data = await DatabaseHelper.search(q);
      setState(() => _transactions = data);
    }
  }

  Future<void> _deleteTransaction(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Transaksi'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.delete(id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dihapus'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openForm({Map<String, dynamic>? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TransactionFormSheet(
        existing: existing,
        onSaved: () async {
          Navigator.pop(context);
          await _loadData();
        },
      ),
    );
  }

  /// Format angka ke Rupiah
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

  /// Ikon kategori
  IconData _getCategoryIcon(String kategori) {
    switch (kategori) {
      case 'Gaji':
        return Icons.work_rounded;
      case 'Bonus':
        return Icons.card_giftcard_rounded;
      case 'Investasi':
        return Icons.trending_up_rounded;
      case 'Transfer Masuk':
        return Icons.call_received_rounded;
      case 'Makanan':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Belanja':
        return Icons.shopping_bag_rounded;
      case 'Tagihan':
        return Icons.receipt_long_rounded;
      case 'Hiburan':
        return Icons.movie_rounded;
      case 'Kesehatan':
        return Icons.medical_services_rounded;
      case 'Pendidikan':
        return Icons.school_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final saldo = _totalPemasukan - _totalPengeluaran;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          // ── Balance Summary Card ──
          _buildBalanceCard(saldo),

          // ── Search Bar ──
          _buildSearchBar(),

          // ── Count + Refresh ──
          _buildCountHeader(),

          // ── Transaction List ──
          Expanded(
            child: _transactions.isEmpty
                ? _buildEmptyState()
                : _buildList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Transaksi Baru',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // ── Balance Card ──
  Widget _buildBalanceCard(double saldo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Text('Saldo Anda',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            _formatRupiah(saldo),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniCard(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Pemasukan',
                  amount: _formatRupiah(_totalPemasukan),
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniCard(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Pengeluaran',
                  amount: _formatRupiah(_totalPengeluaran),
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniCard({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 10)),
                Text(amount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ──
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) =>
            setState(() => _isSearching = _searchCtrl.text.isNotEmpty),
        decoration: InputDecoration(
          hintText: 'Cari transaksi...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _isSearching = false);
                    _loadData();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  // ── Count Header ──
  Widget _buildCountHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${_transactions.length} Transaksi',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 13)),
          TextButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh'),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 80, color: Colors.grey.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('Belum ada transaksi',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Tekan tombol + untuk menambah transaksi',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // ── Transaction List ──
  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: _transactions.length,
      itemBuilder: (ctx, i) {
        final t = _transactions[i];
        final isPemasukan = t['tipe'] == 'pemasukan';
        final jumlah = (t['jumlah'] as num).toDouble();
        final icon = _getCategoryIcon(t['kategori'] ?? '');
        final color = isPemasukan ? Colors.green : Colors.red;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 1,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            title: Text(t['judul'] ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(t['kategori'] ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 11, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(t['tanggal'] ?? '',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPemasukan ? '+' : '-'} ${_formatRupiah(jumlah)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _openForm(existing: t),
                      child: const Icon(Icons.edit_rounded,
                          color: Colors.orange, size: 18),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => _deleteTransaction(t['id']),
                      child: const Icon(Icons.delete_rounded,
                          color: Colors.red, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
