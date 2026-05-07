import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

/// Daftar kategori transaksi yang tersedia
const List<String> kategoriPemasukan = [
  'Gaji',
  'Bonus',
  'Investasi',
  'Transfer Masuk',
  'Lainnya',
];

const List<String> kategoriPengeluaran = [
  'Makanan',
  'Transport',
  'Belanja',
  'Tagihan',
  'Hiburan',
  'Kesehatan',
  'Pendidikan',
  'Lainnya',
];

/// Bottom sheet form untuk menambah atau mengedit transaksi.
class TransactionFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final VoidCallback onSaved;

  const TransactionFormSheet({
    super.key,
    this.existing,
    required this.onSaved,
  });

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulCtrl;
  late TextEditingController _jumlahCtrl;
  bool _isSaving = false;

  late String _tipe;
  late String _kategori;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _judulCtrl =
        TextEditingController(text: widget.existing?['judul'] ?? '');
    _jumlahCtrl = TextEditingController(
      text: widget.existing != null
          ? (widget.existing!['jumlah'] as num).toStringAsFixed(0)
          : '',
    );
    _tipe = widget.existing?['tipe'] ?? 'pengeluaran';
    _kategori = widget.existing?['kategori'] ?? _currentKategoriList.first;
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _jumlahCtrl.dispose();
    super.dispose();
  }

  List<String> get _currentKategoriList =>
      _tipe == 'pemasukan' ? kategoriPemasukan : kategoriPengeluaran;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final tanggal =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final row = {
      'judul': _judulCtrl.text.trim(),
      'jumlah': double.tryParse(_jumlahCtrl.text.trim()) ?? 0,
      'tipe': _tipe,
      'kategori': _kategori,
      'tanggal': tanggal,
    };

    if (_isEditing) {
      await DatabaseHelper.update({...row, 'id': widget.existing!['id']});
    } else {
      await DatabaseHelper.insert(row);
    }

    setState(() => _isSaving = false);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isPemasukan = _tipe == 'pemasukan';

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 16),
              Text(
                _isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // ── Tipe Toggle ──
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _tipe = 'pemasukan';
                        _kategori = kategoriPemasukan.first;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isPemasukan
                              ? Colors.green
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_downward_rounded,
                                size: 18,
                                color: isPemasukan
                                    ? Colors.white
                                    : Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isPemasukan
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _tipe = 'pengeluaran';
                        _kategori = kategoriPengeluaran.first;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isPemasukan
                              ? Colors.red
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_upward_rounded,
                                size: 18,
                                color: !isPemasukan
                                    ? Colors.white
                                    : Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'Pengeluaran',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !isPemasukan
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Judul ──
              TextFormField(
                controller: _judulCtrl,
                decoration: InputDecoration(
                  labelText: 'Judul Transaksi',
                  hintText: 'cth: Makan siang, Gaji bulan Mei',
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Data tidak boleh kosong!'
                    : null,
              ),
              const SizedBox(height: 14),

              // ── Jumlah ──
              TextFormField(
                controller: _jumlahCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  hintText: 'cth: 50000',
                  prefixIcon: const Icon(Icons.payments_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Data tidak boleh kosong!';
                  }
                  if (double.tryParse(v.trim()) == null) {
                    return 'Masukkan angka yang valid!';
                  }
                  if (double.parse(v.trim()) <= 0) {
                    return 'Jumlah harus lebih dari 0!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Kategori Dropdown ──
              DropdownButtonFormField<String>(
                value: _currentKategoriList.contains(_kategori)
                    ? _kategori
                    : _currentKategoriList.first,
                items: _currentKategoriList
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _kategori = v!),
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: const Icon(Icons.category_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                ),
              ),
              const SizedBox(height: 20),

              // ── Submit Button ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isPemasukan ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Icon(_isEditing
                          ? Icons.save_rounded
                          : Icons.add_rounded),
                  label:
                      Text(_isEditing ? 'Simpan Perubahan' : 'Tambah'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
