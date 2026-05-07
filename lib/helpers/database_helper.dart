import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// Helper class untuk operasi CRUD SQLite pada tabel transaksi keuangan.
class DatabaseHelper {
  static Database? _db;
  static const _dbName = 'dompetku.db';
  static const _tableName = 'transaksi';

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    // ignore: avoid_print
    print('📂 Database path: $path');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            jumlah REAL NOT NULL,
            tipe TEXT NOT NULL,
            kategori TEXT NOT NULL,
            tanggal TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Menambah transaksi baru
  static Future<int> insert(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert(_tableName, row);
  }

  /// Mengambil semua transaksi (terbaru di atas)
  static Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await database;
    return db.query(_tableName, orderBy: 'id DESC');
  }

  /// Mencari transaksi berdasarkan judul
  static Future<List<Map<String, dynamic>>> search(String keyword) async {
    final db = await database;
    return db.query(
      _tableName,
      where: 'judul LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'id DESC',
    );
  }

  /// Mengupdate transaksi
  static Future<int> update(Map<String, dynamic> row) async {
    final db = await database;
    return db.update(
      _tableName,
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  /// Menghapus transaksi berdasarkan id
  static Future<int> delete(int id) async {
    final db = await database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Menghitung total berdasarkan tipe ('pemasukan' atau 'pengeluaran')
  static Future<double> getTotalByType(String tipe) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(jumlah), 0) as total FROM $_tableName WHERE tipe = ?',
      [tipe],
    );
    return (result.first['total'] as num).toDouble();
  }

  /// Menghitung total per kategori, difilter berdasarkan tipe
  static Future<List<Map<String, dynamic>>> getTotalByCategory(
      String tipe) async {
    final db = await database;
    return db.rawQuery(
      'SELECT kategori, SUM(jumlah) as total FROM $_tableName WHERE tipe = ? GROUP BY kategori ORDER BY total DESC',
      [tipe],
    );
  }
}
