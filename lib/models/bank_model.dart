/// Model data Bank dari API localhost.
/// API mengembalikan data sebagai List of Array, bukan List of Object.
class Bank {
  final String id;
  final String kategori;
  final String kode;
  final String nama;
  final String alamat;
  final String telepon;
  final String website;

  Bank({
    required this.id,
    required this.kategori,
    required this.kode,
    required this.nama,
    required this.alamat,
    required this.telepon,
    required this.website,
  });

  /// Factory constructor: parsing dari List<dynamic> (array per-row)
  factory Bank.fromJson(List<dynamic> json) {
    return Bank(
      id: json[0].toString(),
      kategori: json[1].toString(),
      kode: json[2].toString(),
      nama: json[3].toString(),
      alamat: json[4].toString(),
      telepon: json[5].toString(),
      website: json.length > 7 ? json[7].toString() : '',
    );
  }
}
