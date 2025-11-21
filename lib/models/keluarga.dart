class Keluarga {
  final String id;
  final String namaKeluarga;
  final String kepaluargaWargaId; // Foreign key ke Warga (kepala keluarga)
  final String? rumahId; // Foreign key ke Rumah
  final int jumlahAnggota;

  const Keluarga({
    required this.id,
    required this.namaKeluarga,
    required this.kepaluargaWargaId,
    this.rumahId,
    required this.jumlahAnggota,
  });

  factory Keluarga.fromJson(Map<String, dynamic> json) {
    return Keluarga(
      id: json['id'] as String? ?? '',
      namaKeluarga: json['namaKeluarga'] as String? ?? '',
      kepaluargaWargaId: json['kepaluargaWargaId'] as String? ?? '',
      rumahId: json['rumahId'] as String?,
      jumlahAnggota: json['jumlahAnggota'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaKeluarga': namaKeluarga,
      'kepaluargaWargaId': kepaluargaWargaId,
      'rumahId': rumahId,
      'jumlahAnggota': jumlahAnggota,
    };
  }

  Keluarga copyWith({
    String? id,
    String? namaKeluarga,
    String? kepaluargaWargaId,
    String? rumahId,
    int? jumlahAnggota,
  }) {
    return Keluarga(
      id: id ?? this.id,
      namaKeluarga: namaKeluarga ?? this.namaKeluarga,
      kepaluargaWargaId: kepaluargaWargaId ?? this.kepaluargaWargaId,
      rumahId: rumahId ?? this.rumahId,
      jumlahAnggota: jumlahAnggota ?? this.jumlahAnggota,
    );
  }
}
