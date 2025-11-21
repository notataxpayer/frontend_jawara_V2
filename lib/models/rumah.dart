class Rumah {
  final String id;
  final String alamat;
  final String statusKepemilikan; // kontrak, milik_sendiri
  final String? keluargaId; // Foreign key ke Keluarga
  final int jumlahPenghuni;

  const Rumah({
    required this.id,
    required this.alamat,
    required this.statusKepemilikan,
    this.keluargaId,
    required this.jumlahPenghuni,
  });

  factory Rumah.fromJson(Map<String, dynamic> json) {
    return Rumah(
      id: json['id'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      statusKepemilikan:
          json['statusKepemilikan'] as String? ?? 'milik_sendiri',
      keluargaId: json['keluargaId'] as String?,
      jumlahPenghuni: json['jumlahPenghuni'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alamat': alamat,
      'statusKepemilikan': statusKepemilikan,
      'keluargaId': keluargaId,
      'jumlahPenghuni': jumlahPenghuni,
    };
  }

  Rumah copyWith({
    String? id,
    String? alamat,
    String? statusKepemilikan,
    String? keluargaId,
    int? jumlahPenghuni,
  }) {
    return Rumah(
      id: id ?? this.id,
      alamat: alamat ?? this.alamat,
      statusKepemilikan: statusKepemilikan ?? this.statusKepemilikan,
      keluargaId: keluargaId ?? this.keluargaId,
      jumlahPenghuni: jumlahPenghuni ?? this.jumlahPenghuni,
    );
  }

  String get displayStatus {
    return statusKepemilikan == 'kontrak' ? 'Kontrak' : 'Milik Sendiri';
  }
}
