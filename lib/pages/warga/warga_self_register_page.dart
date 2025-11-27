import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pbl_jawara_test/services/warga_service.dart';

class WargaSelfRegisterPage extends StatefulWidget {
  final String token;
  
  const WargaSelfRegisterPage({
    super.key,
    required this.token,
  });

  @override
  State<WargaSelfRegisterPage> createState() => _WargaSelfRegisterPageState();
}

class _WargaSelfRegisterPageState extends State<WargaSelfRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _wargaService = WargaService();
  final _imagePicker = ImagePicker();
  
  // Controllers
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _keluargaIdController = TextEditingController();
  
  // Dropdown values
  String _jenisKelamin = 'Laki-laki';
  String _statusDomisili = 'tetap';
  String _statusHidup = 'hidup';
  
  // File
  XFile? _ktpImage;
  Uint8List? _imageBytes;
  String? _existingKtpUrl; // URL foto KTP yang sudah diupload
  bool _isLoading = false;
  
  // Status
  bool _hasExistingProfile = false;
  String _profileStatus = '';
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });

    final result = await _wargaService.getMyWargaProfile(widget.token);

    print('===== LOAD EXISTING PROFILE DEBUG =====');
    print('Result: $result');
    print('hasProfile: ${result['hasProfile']}');
    print('data: ${result['data']}');
    print('=======================================');

    if (mounted) {
      if (result['hasProfile'] == true && result['data'] != null) {
        final data = result['data'];
        setState(() {
          _hasExistingProfile = true;
          _profileStatus = result['status'] ?? 'pending';
          
          // Fill form dengan data yang sudah ada (convert semua ke String)
          _nikController.text = data['nik']?.toString() ?? '';
          _namaController.text = data['namaWarga']?.toString() ?? '';
          _jenisKelamin = data['jenisKelamin']?.toString() ?? 'Laki-laki';
          _statusDomisili = data['statusDomisili']?.toString() ?? 'tetap';
          _statusHidup = data['statusHidup']?.toString() ?? 'hidup';
          _keluargaIdController.text = data['keluargaId']?.toString() ?? '';
          
          // Simpan URL foto KTP yang sudah diupload
          _existingKtpUrl = data['foto_ktp']?.toString();
        });
      } else {
        // Tidak ada profile, form tetap kosong
        setState(() {
          _hasExistingProfile = false;
          _profileStatus = '';
          _existingKtpUrl = null;
        });
      }
      
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _keluargaIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _ktpImage = image;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_ktpImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto KTP wajib diupload'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final result = await _wargaService.selfRegister(
        token: widget.token,
        nik: _nikController.text.trim(),
        namaWarga: _namaController.text.trim(),
        jenisKelamin: _jenisKelamin,
        statusDomisili: _statusDomisili,
        statusHidup: _statusHidup,
        fotoKtp: _ktpImage!,
        fotoKtpBytes: _imageBytes,
        keluargaId: _keluargaIdController.text.isEmpty 
            ? null 
            : int.tryParse(_keluargaIdController.text),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Berhasil mendaftar'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mendaftar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Data Warga'),
          backgroundColor: const Color(0xFF00BFA5),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final bool isPending = _hasExistingProfile && _profileStatus == 'pending';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Data Warga'),
        backgroundColor: const Color(0xFF00BFA5),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Card(
                color: isPending ? Colors.orange[50] : Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        isPending ? Icons.pending : Icons.info_outline,
                        color: isPending ? Colors.orange : Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isPending
                              ? 'Data Anda sedang dalam proses review oleh admin. Mohon tunggu hingga disetujui.'
                              : 'Isi data sesuai dengan KTP Anda. Data akan diverifikasi oleh admin.',
                          style: TextStyle(
                            color: isPending ? Colors.orange[900] : Colors.blue[900],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // NIK Field
              TextFormField(
                controller: _nikController,
                enabled: !isPending,
                decoration: const InputDecoration(
                  labelText: 'NIK',
                  hintText: 'Masukkan NIK 16 digit',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIK tidak boleh kosong';
                  }
                  if (value.length != 16) {
                    return 'NIK harus 16 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nama Field
              TextFormField(
                controller: _namaController,
                enabled: !isPending,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Sesuai KTP',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (value.length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Jenis Kelamin Dropdown
              DropdownButtonFormField<String>(
                value: _jenisKelamin,
                decoration: const InputDecoration(
                  labelText: 'Jenis Kelamin',
                  prefixIcon: Icon(Icons.wc),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                ],
                onChanged: isPending ? null : (value) {
                  if (value != null) {
                    setState(() {
                      _jenisKelamin = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Status Domisili Dropdown
              DropdownButtonFormField<String>(
                value: _statusDomisili,
                decoration: const InputDecoration(
                  labelText: 'Status Domisili',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'tetap', child: Text('Tetap')),
                  DropdownMenuItem(value: 'kontrak', child: Text('Kontrak')),
                ],
                onChanged: isPending ? null : (value) {
                  if (value != null) {
                    setState(() {
                      _statusDomisili = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Status Hidup Dropdown
              DropdownButtonFormField<String>(
                value: _statusHidup,
                decoration: const InputDecoration(
                  labelText: 'Status Hidup',
                  prefixIcon: Icon(Icons.favorite),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'hidup', child: Text('Hidup')),
                  DropdownMenuItem(value: 'meninggal', child: Text('Meninggal')),
                ],
                onChanged: isPending ? null : (value) {
                  if (value != null) {
                    setState(() {
                      _statusHidup = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Keluarga ID Field (Optional)
              TextFormField(
                controller: _keluargaIdController,
                enabled: !isPending,
                decoration: const InputDecoration(
                  labelText: 'ID Keluarga (Opsional)',
                  hintText: 'Masukkan ID Keluarga jika ada',
                  prefixIcon: Icon(Icons.family_restroom),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Foto KTP Section
              Text(
                isPending ? 'Foto KTP (Sudah Diupload)' : 'Foto KTP *',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              GestureDetector(
                onTap: isPending ? null : _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: isPending ? Colors.grey.shade300 : Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: isPending ? Colors.grey[100] : Colors.grey[100],
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _existingKtpUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _existingKtpUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline, 
                                          size: 48, 
                                          color: Colors.red.shade300),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Gagal memuat foto KTP',
                                        style: TextStyle(color: Colors.red.shade600),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, 
                                    size: 48, 
                                    color: isPending ? Colors.grey.shade400 : Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  isPending ? 'Foto KTP sudah diupload' : 'Tap untuk upload foto KTP',
                                  style: TextStyle(
                                    color: isPending ? Colors.grey.shade600 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: (isPending || _isLoading) ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPending ? Colors.grey : const Color(0xFF00BFA5),
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
                        isPending ? 'Tunggu Review dari Admin' : 'Daftar',
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
