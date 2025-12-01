import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pbl_jawara_test/services/keluarga_api_service.dart';
import 'package:pbl_jawara_test/services/warga_service.dart';
import 'package:pbl_jawara_test/services/rumah_api_service.dart';

class KeluargaFormPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? keluargaData;
  final bool isEdit;

  const KeluargaFormPage({
    super.key,
    required this.token,
    this.keluargaData,
    this.isEdit = false,
  });

  @override
  State<KeluargaFormPage> createState() => _KeluargaFormPageState();
}

class _KeluargaFormPageState extends State<KeluargaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final KeluargaApiService _keluargaService;
  late final WargaService _wargaService;
  late final RumahApiService _rumahService;

  // Controllers
  final _namaKeluargaController = TextEditingController();
  final _jumlahAnggotaController = TextEditingController();

  // Dropdowns
  String? _selectedKepalaKeluargaId;
  int? _selectedRumahId;

  // Lists
  List<Map<String, dynamic>> _wargaList = [];
  List<Map<String, dynamic>> _rumahList = [];

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _keluargaService = KeluargaApiService(token: widget.token);
    _wargaService = WargaService();
    _rumahService = RumahApiService(token: widget.token);
    _loadInitialData();
    if (widget.isEdit && widget.keluargaData != null) {
      _fillFormWithData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingData = true;
    });

    // Load warga list
    final wargaResult = await _wargaService.getAllWargaFromApi(widget.token);
    if (wargaResult['success'] == true && wargaResult['data'] != null) {
      final data = wargaResult['data'];
      if (data is Map && data['data'] is List) {
        _wargaList = List<Map<String, dynamic>>.from(data['data']);
      } else if (data is List) {
        _wargaList = List<Map<String, dynamic>>.from(data);
      }
    }

    // Load rumah list
    final rumahResult = await _rumahService.getAllRumah();
    if (rumahResult['success'] == true && rumahResult['data'] != null) {
      final data = rumahResult['data'];
      if (data is Map && data['data'] is List) {
        _rumahList = List<Map<String, dynamic>>.from(data['data']);
      } else if (data is List) {
        _rumahList = List<Map<String, dynamic>>.from(data);
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  void _fillFormWithData() {
    final data = widget.keluargaData!;
    _namaKeluargaController.text = data['namaKeluarga']?.toString() ?? '';
    // Backend uses 'jumlahanggota' (lowercase)
    _jumlahAnggotaController.text = (data['jumlahanggota'] ?? data['jumlahAnggota'])?.toString() ?? '';
    _selectedKepalaKeluargaId = data['kepala_Keluarga_Id']?.toString();
    _selectedRumahId = data['rumahId'] is int 
        ? data['rumahId'] 
        : int.tryParse(data['rumahId']?.toString() ?? '');
  }

  @override
  void dispose() {
    _namaKeluargaController.dispose();
    _jumlahAnggotaController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedKepalaKeluargaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kepala keluarga harus dipilih'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final keluargaData = {
        'namaKeluarga': _namaKeluargaController.text.trim(),
        'jumlahAnggota': int.parse(_jumlahAnggotaController.text.trim()),
        if (_selectedRumahId != null) 'rumahId': _selectedRumahId!,
        'kepala_Keluarga_Id': _selectedKepalaKeluargaId!,
      };

      print('Submitting keluarga data: $keluargaData');

      final result = widget.isEdit
          ? await _keluargaService.updateKeluarga(
              widget.keluargaData!['id'].toString(),
              keluargaData,
            )
          : await _keluargaService.createKeluarga(keluargaData);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 
              (widget.isEdit ? 'Keluarga berhasil diupdate' : 'Keluarga berhasil ditambahkan')
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 
              (widget.isEdit ? 'Gagal update keluarga' : 'Gagal menambahkan keluarga')
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit Keluarga' : 'Tambah Keluarga',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00BFA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nama Keluarga Field
                    TextFormField(
                      controller: _namaKeluargaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Keluarga',
                        hintText: 'Contoh: Keluarga Budi',
                        prefixIcon: Icon(Icons.family_restroom),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama keluarga tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Jumlah Anggota Field
                    TextFormField(
                      controller: _jumlahAnggotaController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Anggota',
                        hintText: 'Contoh: 4',
                        prefixIcon: Icon(Icons.people),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah anggota tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Harus berupa angka';
                        }
                        if (int.parse(value) < 1) {
                          return 'Minimal 1 anggota';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Kepala Keluarga Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedKepalaKeluargaId,
                      decoration: const InputDecoration(
                        labelText: 'Kepala Keluarga',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Pilih Kepala Keluarga'),
                      items: _wargaList.map((warga) {
                        final nik = warga['nik']?.toString() ?? '';
                        final nama = warga['namaWarga']?.toString() ?? 'N/A';
                        return DropdownMenuItem<String>(
                          value: nik,
                          child: Text('$nama (NIK: $nik)'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedKepalaKeluargaId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kepala keluarga harus dipilih';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Rumah Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedRumahId,
                      decoration: const InputDecoration(
                        labelText: 'Rumah',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Pilih Rumah'),
                      items: _rumahList.map((rumah) {
                        final id = rumah['id'] is int 
                            ? rumah['id'] 
                            : int.tryParse(rumah['id']?.toString() ?? '');
                        final blok = rumah['blok']?.toString() ?? 'N/A';
                        final nomorRumah = rumah['nomorRumah']?.toString() ?? 'N/A';
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text('Blok $blok No. $nomorRumah'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRumahId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.isEdit ? 'Update Keluarga' : 'Tambah Keluarga',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
