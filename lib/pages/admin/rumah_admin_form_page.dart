import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pbl_jawara_test/services/rumah_api_service.dart';
import 'package:pbl_jawara_test/services/keluarga_api_service.dart';

class RumahAdminFormPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? rumahData;
  final bool isEdit;

  const RumahAdminFormPage({
    super.key,
    required this.token,
    this.rumahData,
    this.isEdit = false,
  });

  @override
  State<RumahAdminFormPage> createState() => _RumahAdminFormPageState();
}

class _RumahAdminFormPageState extends State<RumahAdminFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final RumahApiService _rumahService;
  late final KeluargaApiService _keluargaService;

  // Controllers
  final _alamatController = TextEditingController();
  final _jumlahPenghuniController = TextEditingController();

  // Dropdowns
  String? _selectedStatusKepemilikan;
  int? _selectedKeluargaId;

  // Lists
  List<Map<String, dynamic>> _keluargaList = [];

  bool _isLoading = false;
  bool _isLoadingData = true;

  // Status kepemilikan options
  final List<Map<String, String>> _statusOptions = [
    {'value': 'milik_sendiri', 'label': 'Milik Sendiri'},
    {'value': 'kontrak', 'label': 'Kontrak'},
  ];

  @override
  void initState() {
    super.initState();
    _rumahService = RumahApiService(token: widget.token);
    _keluargaService = KeluargaApiService(token: widget.token);
    _loadInitialData();
    if (widget.isEdit && widget.rumahData != null) {
      _fillFormWithData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingData = true;
    });

    // Load keluarga list
    final keluargaResult = await _keluargaService.getAllKeluarga();
    if (keluargaResult['success'] == true && keluargaResult['data'] != null) {
      final data = keluargaResult['data'];
      if (data is Map && data['data'] is List) {
        _keluargaList = List<Map<String, dynamic>>.from(data['data']);
      } else if (data is List) {
        _keluargaList = List<Map<String, dynamic>>.from(data);
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  void _fillFormWithData() {
    final data = widget.rumahData!;
    _alamatController.text = data['alamat']?.toString() ?? '';
    // Backend uses 'jumlahpenghuni' (lowercase)
    _jumlahPenghuniController.text = (data['jumlahpenghuni'] ?? data['jumlahPenghuni'])?.toString() ?? '0';
    _selectedStatusKepemilikan = data['statusKepemilikan']?.toString();
    _selectedKeluargaId = data['keluargaId'] is int
        ? data['keluargaId']
        : int.tryParse(data['keluargaId']?.toString() ?? '');
  }

  @override
  void dispose() {
    _alamatController.dispose();
    _jumlahPenghuniController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedStatusKepemilikan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status kepemilikan harus dipilih'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final rumahData = {
        'statusKepemilikan': _selectedStatusKepemilikan!,
        'alamat': _alamatController.text.trim(),
        // Backend bug: validation expects 'jumlahPenghuni' but schema has 'jumlahpenghuni'
        // Send both to workaround
        'jumlahPenghuni': int.parse(_jumlahPenghuniController.text.trim()),
        'jumlahpenghuni': int.parse(_jumlahPenghuniController.text.trim()),
        if (_selectedKeluargaId != null) 'keluargaId': _selectedKeluargaId!,
      };

      print('Submitting rumah data: $rumahData');

      final result = widget.isEdit
          ? await _rumahService.updateRumah(
              widget.rumahData!['id'].toString(),
              rumahData,
            )
          : await _rumahService.createRumah(rumahData);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  (widget.isEdit
                      ? 'Rumah berhasil diupdate'
                      : 'Rumah berhasil ditambahkan'),
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
                  (widget.isEdit
                      ? 'Gagal update rumah'
                      : 'Gagal menambahkan rumah'),
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
          widget.isEdit ? 'Edit Rumah' : 'Tambah Rumah',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00BFA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingData
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Memuat data warga...',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Alamat Field
                    TextFormField(
                      controller: _alamatController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        hintText: 'Contoh: Jl. Merdeka No. 12, RT 01/RW 02',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Status Kepemilikan Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedStatusKepemilikan,
                      decoration: const InputDecoration(
                        labelText: 'Status Kepemilikan',
                        prefixIcon: Icon(Icons.assignment),
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Pilih Status Kepemilikan'),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status['value'],
                          child: Text(status['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatusKepemilikan = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Status kepemilikan harus dipilih';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Jumlah Penghuni Field
                    TextFormField(
                      controller: _jumlahPenghuniController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Penghuni',
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
                          return 'Jumlah penghuni tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Harus berupa angka';
                        }
                        if (int.parse(value) < 0) {
                          return 'Minimal 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Keluarga Dropdown (Optional)
                    DropdownButtonFormField<int>(
                      value: _selectedKeluargaId,
                      decoration: const InputDecoration(
                        labelText: 'Keluarga (Opsional)',
                        prefixIcon: Icon(Icons.family_restroom),
                        border: OutlineInputBorder(),
                        helperText: 'Kosongkan jika belum ada keluarga',
                      ),
                      hint: const Text('Pilih Keluarga'),
                      items: _keluargaList.map((keluarga) {
                        final id = keluarga['id'] is int
                            ? keluarga['id']
                            : int.tryParse(keluarga['id']?.toString() ?? '');
                        final nama = keluarga['namaKeluarga']?.toString() ?? 'N/A';
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(nama),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedKeluargaId = value;
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.isEdit ? 'Update Rumah' : 'Tambah Rumah',
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
