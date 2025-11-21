import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_jawara_test/models/rumah.dart';
import 'package:pbl_jawara_test/services/rumah_service.dart';

class RumahFormPage extends StatefulWidget {
  final String? rumahId; // null = add mode, provided = edit mode

  const RumahFormPage({
    Key? key,
    this.rumahId,
  }) : super(key: key);

  @override
  State<RumahFormPage> createState() => _RumahFormPageState();
}

class _RumahFormPageState extends State<RumahFormPage> {
  final RumahService _rumahService = RumahService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _alamatController;
  late TextEditingController _jumlahPenghuniController;

  String _selectedStatusKepemilikan = 'milik_sendiri';
  late TextEditingController _keluargaIdController;

  bool _isLoading = false;
  Rumah? _existingRumah;

  bool get _isEditMode => rumahId != null;

  String? get rumahId => widget.rumahId;

  @override
  void initState() {
    super.initState();
    _alamatController = TextEditingController();
    _jumlahPenghuniController = TextEditingController();
    _keluargaIdController = TextEditingController();

    if (_isEditMode) {
      _loadExistingRumah();
    }
  }

  Future<void> _loadExistingRumah() async {
    try {
      final rumah = await _rumahService.getRumahById(widget.rumahId!);
      if (rumah != null) {
        setState(() {
          _existingRumah = rumah;
          _alamatController.text = rumah.alamat;
          _jumlahPenghuniController.text = rumah.jumlahPenghuni.toString();
          _selectedStatusKepemilikan = rumah.statusKepemilikan;
          _keluargaIdController.text = rumah.keluargaId ?? '';
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
      final newRumah = Rumah(
        id: _existingRumah?.id ?? 'R${DateTime.now().millisecondsSinceEpoch}',
        alamat: _alamatController.text.trim(),
        statusKepemilikan: _selectedStatusKepemilikan,
        keluargaId: _keluargaIdController.text.trim().isEmpty
            ? null
            : _keluargaIdController.text.trim(),
        jumlahPenghuni: int.parse(_jumlahPenghuniController.text),
      );

      Map<String, dynamic> result;
      if (_isEditMode) {
        result = await _rumahService.updateRumah(widget.rumahId!, newRumah);
      } else {
        result = await _rumahService.addRumah(newRumah);
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
    _alamatController.dispose();
    _jumlahPenghuniController.dispose();
    _keluargaIdController.dispose();
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
          _isEditMode ? 'Edit Rumah' : 'Tambah Rumah Baru',
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
                          'Data Rumah',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF171d1b),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _alamatController,
                          label: 'Alamat Lengkap',
                          hint: 'Contoh: Jl. Merdeka No. 12, RT 01/RW 02',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Alamat wajib diisi';
                            }
                            return null;
                          },
                        ),
                        _buildDropdownField(
                          label: 'Status Kepemilikan',
                          value: _selectedStatusKepemilikan,
                          items: ['milik_sendiri', 'kontrak'],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatusKepemilikan = value!;
                            });
                          },
                        ),
                        _buildTextFormField(
                          controller: _jumlahPenghuniController,
                          label: 'Jumlah Penghuni',
                          hint: '4',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jumlah penghuni wajib diisi';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Hanya boleh angka';
                            }
                            return null;
                          },
                        ),
                        _buildTextFormField(
                          controller: _keluargaIdController,
                          label: 'ID Keluarga (Opsional)',
                          hint: 'K001',
                          validator: null,
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
                      child: Text(item == 'milik_sendiri'
                          ? 'Milik Sendiri'
                          : 'Kontrak'),
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
