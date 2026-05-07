/// Model data Transaksi keuangan untuk SQLite.
class Transaksi {
  final int? id;
  final String judul;
  final double jumlah;
  final String tipe; // 'pemasukan' atau 'pengeluaran'
  final String kategori;
  final String tanggal;

  Transaksi({
    this.id,
    required this.judul,
    required this.jumlah,
    required this.tipe,
    required this.kategori,
    required this.tanggal,
  });

  /// Konversi dari Map (hasil query SQLite) ke object Transaksi
  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'] as int?,
      judul: map['judul'] as String,
      jumlah: (map['jumlah'] as num).toDouble(),
      tipe: map['tipe'] as String,
      kategori: map['kategori'] as String,
      tanggal: map['tanggal'] as String,
    );
  }

  /// Konversi dari object Transaksi ke Map (untuk insert/update SQLite)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'judul': judul,
      'jumlah': jumlah,
      'tipe': tipe,
      'kategori': kategori,
      'tanggal': tanggal,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
