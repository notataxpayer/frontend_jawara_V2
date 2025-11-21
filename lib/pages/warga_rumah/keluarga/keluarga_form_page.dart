import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/models/keluarga.dart';
import 'package:pbl_jawara_test/services/keluarga_service.dart';

class KeluargaFormPage extends StatefulWidget {
  final String? keluargaId; // null = add mode, provided = edit mode

  const KeluargaFormPage({
    Key? key,
    this.keluargaId,
  }) : super(key: key);

  @override
  State<KeluargaFormPage> createState() => _KeluargaFormPageState();
}

class _KeluargaFormPageState extends State<KeluargaFormPage> {
  final KeluargaService _keluargaService = KeluargaService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaKeluargaController;
  late TextEditingController _kepalKeluargaWargaIdController;
  late TextEditingController _rumahIdController;
  late TextEditingController _jumlahAnggotaController;

  bool _isLoading = false;
  Keluarga? _existingKeluarga;

  bool get _isEditMode => widget.keluargaId != null;

  @override
  void initState() {
    super.initState();
    _namaKeluargaController = TextEditingController();
    _kepalKeluargaWargaIdController = TextEditingController();
    _rumahIdController = TextEditingController();
    _jumlahAnggotaController = TextEditingController();

    if (_isEditMode) {
      _loadExistingKeluarga();
    }
  }

  Future<void> _loadExistingKeluarga() async {
    try {
      final keluarga =
          await _keluargaService.getKeluargaById(widget.keluargaId!);
      if (keluarga != null) {
        setState(() {
          _existingKeluarga = keluarga;
          _namaKeluargaController.text = keluarga.namaKeluarga;
          _kepalKeluargaWargaIdController.text = keluarga.kepaluargaWargaId;
          _rumahIdController.text = keluarga.rumahId ?? '';
          _jumlahAnggotaController.text = keluarga.jumlahAnggota.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newKeluarga = Keluarga(
        id: _existingKeluarga?.id ??
            'K${DateTime.now().millisecondsSinceEpoch}',
        namaKeluarga: _namaKeluargaController.text.trim(),
        kepaluargaWargaId: _kepalKeluargaWargaIdController.text.trim(),
        rumahId: _rumahIdController.text.trim().isEmpty
            ? null
            : _rumahIdController.text.trim(),
        jumlahAnggota: int.parse(_jumlahAnggotaController.text),
      );

      Map<String, dynamic> result;
      if (_isEditMode) {
        result = await _keluargaService.updateKeluarga(
          widget.keluargaId!,
          newKeluarga,
        );
      } else {
        result = await _keluargaService.addKeluarga(newKeluarga);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );

        if (result['success']) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _namaKeluargaController.dispose();
    _kepalKeluargaWargaIdController.dispose();
    _rumahIdController.dispose();
    _jumlahAnggotaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditMode ? 'Edit Keluarga' : 'Tambah Keluarga Baru',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data Keluarga',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF171d1b),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _namaKeluargaController,
                          label: 'Nama Keluarga',
                          hint: 'Contoh: Keluarga Santoso',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama keluarga wajib diisi';
                            }
                            return null;
                          },
                        ),
                        _buildTextFormField(
                          controller: _kepalKeluargaWargaIdController,
                          label: 'Kepala Keluarga (Warga ID)',
                          hint: 'W001',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Warga ID kepala keluarga wajib diisi';
                            }
                            return null;
                          },
                        ),
                        _buildTextFormField(
                          controller: _rumahIdController,
                          label: 'Rumah ID (Opsional)',
                          hint: 'R001',
                          validator: null,
                        ),
                        _buildTextFormField(
                          controller: _jumlahAnggotaController,
                          label: 'Jumlah Anggota',
                          hint: '4',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jumlah anggota wajib diisi';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Hanya boleh angka';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: Colors.grey,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Color(0xFF171d1b)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isEditMode ? 'Perbarui' : 'Simpan',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF171d1b),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF00BFA5),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
