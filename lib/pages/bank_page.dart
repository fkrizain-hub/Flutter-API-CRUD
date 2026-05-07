import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/bank_model.dart';

/// Halaman daftar Bank dari API localhost.
/// Menampilkan data bank dengan search filter dan detail bottom sheet.
class BankPage extends StatefulWidget {
  const BankPage({super.key});
  @override
  State<BankPage> createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  List<Bank> _allBanks = [];
  List<Bank> _filteredBanks = [];
  bool _isLoading = true;
  String _errorMsg = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBanks();
    _searchCtrl.addListener(_filterBanks);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Fetch data bank dari API localhost
  Future<void> _fetchBanks() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    try {
      final res = await http.get(
        Uri.parse('http://172.16.67.160/bank/api/get/'),
        //Uri.parse('http://IP_WIFI_LAPTOP/bank/api/get/') ganti menjadi ip wifi laptop via ipconfig
        //Android emulator → ganti ke 10.0.2.2
        //'http://127.0.0.1/bank/api/get/' di laptop
      );
      if (res.statusCode == 200) {
        final jsonBody = json.decode(res.body);
        final List bankList = jsonBody['data'] ?? [];
        final banks = bankList.map((b) => Bank.fromJson(b)).toList();
        setState(() {
          _allBanks = banks;
          _filteredBanks = banks;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = 'Gagal memuat data (${res.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Koneksi gagal. Pastikan server localhost aktif.\n$e';
        _isLoading = false;
      });
    }
  }

  /// Filter bank berdasarkan nama
  void _filterBanks() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredBanks = _allBanks.where((bank) {
        return bank.nama.toLowerCase().contains(q) ||
            bank.kode.toLowerCase().contains(q);
      }).toList();
    });
  }

  /// Warna ikon kategori berdasarkan kategori bank
  Color _getCategoryColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'bank umum swasta nasional devisa':
        return Colors.blue;
      case 'bank umum swasta nasional non devisa':
        return Colors.orange;
      case 'bank persero':
        return Colors.green;
      case 'bank pembangunan daerah':
        return Colors.purple;
      case 'bank campuran':
        return Colors.teal;
      case 'bank asing':
        return Colors.red;
      default:
        return const Color(0xFF1565C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: const Color(0xFF1565C0),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari bank (nama / kode)...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon:
                    Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchCtrl.clear();
                          _filterBanks();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Jumlah data
          if (!_isLoading && _errorMsg.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_filteredBanks.length} bank ditemukan',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _fetchBanks,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1565C0)),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMsg.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi_off,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(_errorMsg,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _fetchBanks,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredBanks.isEmpty
                        ? const Center(
                            child: Text('Bank tidak ditemukan.',
                                style: TextStyle(color: Colors.grey)))
                        : RefreshIndicator(
                            onRefresh: _fetchBanks,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              itemCount: _filteredBanks.length,
                              itemBuilder: (ctx, i) {
                                final bank = _filteredBanks[i];
                                final catColor =
                                    _getCategoryColor(bank.kategori);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  elevation: 2,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () =>
                                        _showBankDetail(context, bank),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          // Leading icon
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  catColor.withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              Icons.account_balance_rounded,
                                              color: catColor,
                                              size: 26,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          // Content
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  bank.nama,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    height: 1.3,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8,
                                                              vertical: 2),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: catColor
                                                            .withOpacity(
                                                                0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: Text(
                                                        'Kode: ${bank.kode}',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                          color: catColor,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        bank.kategori,
                                                        style:
                                                            const TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.grey,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  /// Detail bottom sheet untuk satu bank
  void _showBankDetail(BuildContext context, Bank bank) {
    final catColor = _getCategoryColor(bank.kategori);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Bank icon + nama
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.account_balance_rounded,
                          color: catColor, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        bank.nama,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Info tiles
                _detailTile(Icons.tag_rounded, 'ID', bank.id, Colors.grey),
                _detailTile(Icons.category_rounded, 'Kategori',
                    bank.kategori, Colors.blue),
                _detailTile(
                    Icons.pin_rounded, 'Kode Bank', bank.kode, Colors.orange),
                _detailTile(Icons.location_on_rounded, 'Alamat',
                    bank.alamat, Colors.green),
                _detailTile(Icons.phone_rounded, 'Telepon', bank.telepon,
                    Colors.purple),
                _detailTile(Icons.language_rounded, 'Website', bank.website,
                    Colors.teal),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailTile(
      IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
