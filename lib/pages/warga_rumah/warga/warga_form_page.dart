import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/models/warga.dart';
import 'package:pbl_jawara_test/services/warga_service.dart';

class WargaFormPage extends StatefulWidget {
  final String? wargaId; // null = add mode, provided = edit mode

  const WargaFormPage({
    Key? key,
    this.wargaId,
  }) : super(key: key);

  @override
  State<WargaFormPage> createState() => _WargaFormPageState();
}

class _WargaFormPageState extends State<WargaFormPage> {
  final WargaService _wargaService = WargaService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _nikController;
  late TextEditingController _namaKeluargaController;

  String _selectedJenisKelamin = 'Laki-laki';
  String _selectedStatusDomisili = 'tetap';
  String _selectedStatusHidup = 'hidup';
  String? _selectedKeluargaId;

  bool _isLoading = false;
  Warga? _existingWarga;

  bool get _isEditMode => widget.wargaId != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _nikController = TextEditingController();
    _namaKeluargaController = TextEditingController();

    if (_isEditMode) {
      _loadExistingWarga();
    }
  }

  Future<void> _loadExistingWarga() async {
    try {
      final warga = await _wargaService.getWargaById(widget.wargaId!);
      if (warga != null) {
        setState(() {
          _existingWarga = warga;
          _namaController.text = warga.namaWarga;
          _nikController.text = warga.nik;
          _namaKeluargaController.text = warga.namaKeluarga;
          _selectedJenisKelamin = warga.jenisKelamin;
          _selectedStatusDomisili = warga.statusDomisili;
          _selectedStatusHidup = warga.statusHidup;
          _selectedKeluargaId = warga.keluargaId;
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
      final newWarga = Warga(
        id: _existingWarga?.id ?? 'W${DateTime.now().millisecondsSinceEpoch}',
        namaWarga: _namaController.text.trim(),
        nik: _nikController.text.trim(),
        namaKeluarga: _namaKeluargaController.text.trim(),
        jenisKelamin: _selectedJenisKelamin,
        statusDomisili: _selectedStatusDomisili,
        statusHidup: _selectedStatusHidup,
        keluargaId: _selectedKeluargaId,
      );

      Map<String, dynamic> result;
      if (_isEditMode) {
        result = await _wargaService.updateWarga(widget.wargaId!, newWarga);
      } else {
        result = await _wargaService.addWarga(newWarga);
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
    _namaController.dispose();
    _nikController.dispose();
    _namaKeluargaController.dispose();
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
          _isEditMode ? 'Edit Warga' : 'Tambah Warga Baru',
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
                          'Data Pribadi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF171d1b),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _namaController,
                          label: 'Nama Warga',
                          hint: 'Contoh: Budi Santoso',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama warga wajib diisi';
                            }
                            return null;
                          },
                        ),
                        _buildTextFormField(
                          controller: _nikController,
                          label: 'NIK',
                          hint: '3201010101990001',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'NIK wajib diisi';
                            }
                            if (!RegExp(r'^\d+$').hasMatch(value)) {
                              return 'NIK hanya boleh berisi angka';
                            }
                            if (value.length != 16) {
                              return 'NIK harus 16 digit';
                            }
                            return null;
                          },
                        ),
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
                        _buildDropdownField(
                          label: 'Jenis Kelamin',
                          value: _selectedJenisKelamin,
                          items: ['Laki-laki', 'Perempuan'],
                          onChanged: (value) {
                            setState(() {
                              _selectedJenisKelamin = value!;
                            });
                          },
                        ),
                        _buildDropdownField(
                          label: 'Status Domisili',
                          value: _selectedStatusDomisili,
                          items: ['tetap', 'kontrak', 'pindah'],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatusDomisili = value!;
                            });
                          },
                        ),
                        _buildDropdownField(
                          label: 'Status Hidup',
                          value: _selectedStatusHidup,
                          items: ['hidup', 'meninggal'],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatusHidup = value!;
                            });
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

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
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
          DropdownButtonFormField<String>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: onChanged as void Function(String?)?,
            decoration: InputDecoration(
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
          ),
        ],
      ),
    );
  }
}
