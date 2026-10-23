enum AppRole { student, admin }

class AppProfile {
  const AppProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.identityNumber,
    required this.role,
    this.transactionsEnabled = true,
  });

  final String id;
  final String email;
  final String name;
  final String identityNumber;
  final AppRole role;
  final bool transactionsEnabled;
  bool get isAdmin => role == AppRole.admin;
  String get initials => name.trim().isEmpty
      ? '?'
      : name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((s) => s[0])
            .join()
            .toUpperCase();

  factory AppProfile.fromJson(Map<String, dynamic> json, String email) {
    final role = switch (json['role']) {
      'admin' => AppRole.admin,
      'student' => AppRole.student,
      _ => throw const FormatException('Role akun tidak dikenal.'),
    };
    if (json['is_active'] != true) {
      throw const FormatException('Akun tidak aktif. Hubungi laboran.');
    }
    return AppProfile(
      id: json['id'] as String,
      email: email,
      name: json['nama'] as String,
      identityNumber: json['npm'] as String? ?? '',
      role: role,
      transactionsEnabled: json['transactions_enabled'] as bool? ?? true,
    );
  }
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.condition,
    required this.stock,
    required this.location,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String code;
  final String category;
  final String condition;
  final int stock;
  final String location;
  final bool isActive;
  bool get canBorrow =>
      isActive &&
      stock > 0 &&
      (condition == 'Baik' || condition == 'Sangat Baik');

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'] as String,
    name: json['nama_barang'] as String,
    code: json['kode_barang'] as String,
    category: json['kategori'] as String,
    condition: json['kondisi'] as String,
    stock: (json['stok'] as num).toInt(),
    location: json['lokasi'] as String,
    isActive: json['is_active'] as bool? ?? true,
  );
}

class Borrowing {
  const Borrowing({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.namaPeminjam,
    required this.namaBarang,
    required this.jumlah,
    required this.tglPinjam,
    this.tglKembali,
    required this.keperluan,
    required this.status,
    this.catatanKondisi,
    this.updatedBy,
    this.createdAt,
    this.approvedAt,
    this.returnedAt,
    this.returnedGood,
    this.updatedAt,
    this.relatedStudentName,
    this.studentIdentityNumber,
    this.relatedItemName,
    this.relatedItemCode,
    this.relatedItemCategory,
  });

  final String id;
  final String userId;
  final String itemId;
  final String namaPeminjam;
  final String namaBarang;
  final int jumlah;
  final DateTime tglPinjam;
  final DateTime? tglKembali;
  final String keperluan;
  final String status;
  final String? catatanKondisi;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final DateTime? returnedAt;
  final bool? returnedGood;
  final DateTime? updatedAt;
  final String? relatedStudentName;
  final String? studentIdentityNumber;
  final String? relatedItemName;
  final String? relatedItemCode;
  final String? relatedItemCategory;
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isReturned => status == 'returned';

  factory Borrowing.fromJson(Map<String, dynamic> json) {
    final student = json['student'];
    final item = json['related_item'];
    return Borrowing(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      itemId: json['item_id'] as String,
      namaPeminjam: json['nama_peminjam'] as String,
      namaBarang: json['nama_barang'] as String,
      jumlah: (json['jumlah'] as num).toInt(),
      tglPinjam: DateTime.parse(json['tgl_pinjam'] as String),
      tglKembali: json['tgl_kembali'] == null
          ? null
          : DateTime.parse(json['tgl_kembali'] as String),
      keperluan: json['keperluan'] as String,
      status: json['status'] as String,
      catatanKondisi: json['catatan_kondisi'] as String?,
      updatedBy: json['updated_by'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      returnedAt: json['returned_at'] == null
          ? null
          : DateTime.parse(json['returned_at'] as String),
      returnedGood: json['returned_good'] as bool?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      relatedStudentName: student is Map<String, dynamic>
          ? student['nama'] as String?
          : null,
      studentIdentityNumber: student is Map<String, dynamic>
          ? student['npm'] as String?
          : null,
      relatedItemName: item is Map<String, dynamic>
          ? item['nama_barang'] as String?
          : null,
      relatedItemCode: item is Map<String, dynamic>
          ? item['kode_barang'] as String?
          : null,
      relatedItemCategory: item is Map<String, dynamic>
          ? item['kategori'] as String?
          : null,
    );
  }
}

String businessDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String? validateBorrowing({
  required InventoryItem item,
  required int amount,
  required DateTime? borrowDate,
  required DateTime? returnDate,
  required String purpose,
  DateTime? now,
}) {
  if (!item.canBorrow) return 'Barang ini belum dapat dipinjam.';
  if (amount <= 0 || amount > item.stock) {
    return 'Jumlah harus antara 1 dan stok yang tersedia.';
  }
  if (borrowDate == null || returnDate == null) {
    return 'Pilih tanggal pinjam dan tanggal kembali.';
  }
  final today = businessDate(
    now ?? DateTime.now().toUtc().add(const Duration(hours: 7)),
  );
  if (businessDate(borrowDate).compareTo(today) < 0) {
    return 'Tanggal pinjam tidak boleh sebelum hari ini.';
  }
  if (businessDate(returnDate).compareTo(businessDate(borrowDate)) < 0) {
    return 'Tanggal kembali tidak boleh sebelum tanggal pinjam.';
  }
  if (purpose.trim().isEmpty || purpose.trim().length > 2000) {
    return 'Isi keperluan peminjaman (maksimal 2.000 karakter).';
  }
  return null;
}
