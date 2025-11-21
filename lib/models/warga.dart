class Warga {
  final String id;
  final String namaWarga;
  final String nik;
  final String namaKeluarga;
  final String jenisKelamin; // Laki-laki, Perempuan
  final String statusDomisili; // tetap, kontrak, pindah
  final String statusHidup; // hidup, meninggal
  final String? keluargaId; // Foreign key ke Keluarga

  const Warga({
    required this.id,
    required this.namaWarga,
    required this.nik,
    required this.namaKeluarga,
    required this.jenisKelamin,
    required this.statusDomisili,
    required this.statusHidup,
    this.keluargaId,
  });

  factory Warga.fromJson(Map<String, dynamic> json) {
    return Warga(
      id: json['id'] as String? ?? '',
      namaWarga: json['namaWarga'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      namaKeluarga: json['namaKeluarga'] as String? ?? '',
      jenisKelamin: json['jenisKelamin'] as String? ?? 'Laki-laki',
      statusDomisili: json['statusDomisili'] as String? ?? 'tetap',
      statusHidup: json['statusHidup'] as String? ?? 'hidup',
      keluargaId: json['keluargaId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaWarga': namaWarga,
      'nik': nik,
      'namaKeluarga': namaKeluarga,
      'jenisKelamin': jenisKelamin,
      'statusDomisili': statusDomisili,
      'statusHidup': statusHidup,
      'keluargaId': keluargaId,
    };
  }

  Warga copyWith({
    String? id,
    String? namaWarga,
    String? nik,
    String? namaKeluarga,
    String? jenisKelamin,
    String? statusDomisili,
    String? statusHidup,
    String? keluargaId,
  }) {
    return Warga(
      id: id ?? this.id,
      namaWarga: namaWarga ?? this.namaWarga,
      nik: nik ?? this.nik,
      namaKeluarga: namaKeluarga ?? this.namaKeluarga,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      statusDomisili: statusDomisili ?? this.statusDomisili,
      statusHidup: statusHidup ?? this.statusHidup,
      keluargaId: keluargaId ?? this.keluargaId,
    );
  }

  String get avatarInitial {
    return namaWarga.isNotEmpty ? namaWarga[0].toUpperCase() : '?';
  }
}
