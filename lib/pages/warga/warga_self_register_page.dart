import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pbl_jawara_test/services/warga_service.dart';
import 'package:pbl_jawara_test/services/verification_warga_api_service.dart';

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
  late final VerificationWargaApiService _verificationService;
  
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
  bool _isLoadingProfile = true;
  
  // Verification status
  Map<String, dynamic>? _latestVerification;
  String _verificationStatus = ''; // 'pending', 'approved', 'rejected'
  String? _rejectionMessage;

  @override
  void initState() {
    super.initState();
    _verificationService = VerificationWargaApiService(token: widget.token);
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });

    // Load verification requests first
    await _loadVerificationStatus();
    
    final result = await _wargaService.getMyWargaProfile(widget.token);

    print('===== LOAD EXISTING PROFILE DEBUG =====');
    print('Result: $result');
    print('hasProfile: ${result['hasProfile']}');
    print('data: ${result['data']}');
    print('Verification Status: $_verificationStatus');
    print('Latest Verification: $_latestVerification');
    print('=======================================');

    if (mounted) {
      if (result['hasProfile'] == true && result['data'] != null) {
        // Ada profile warga yang sudah tersimpan (approved)
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          _hasExistingProfile = true;
          
          // Fill form dengan data yang sudah ada (convert semua ke String)
          // NIK bisa berupa int atau String dari backend, handle both
          final nikValue = data['nik'];
          _nikController.text = nikValue != null ? nikValue.toString() : '';
          _namaController.text = data['namaWarga']?.toString() ?? '';
          _jenisKelamin = data['jenisKelamin']?.toString() ?? 'Laki-laki';
          _statusDomisili = data['statusDomisili']?.toString() ?? 'tetap';
          _statusHidup = data['statusHidup']?.toString() ?? 'hidup';
          
          // keluargaId juga bisa int atau String
          final keluargaIdValue = data['keluargaId'];
          _keluargaIdController.text = keluargaIdValue != null ? keluargaIdValue.toString() : '';
          
          // Simpan URL foto KTP yang sudah diupload
          _existingKtpUrl = data['foto_ktp']?.toString();
        });
      } else if (_verificationStatus == 'pending' && _latestVerification != null) {
        // Tidak ada profile tersimpan tapi ada verifikasi pending
        // Tampilkan data dari extra_data
        final extraDataRaw = _latestVerification!['extra_data'];
        
        // extra_data bisa berupa String JSON atau Map
        Map<String, dynamic>? extraData;
        if (extraDataRaw is String) {
          try {
            extraData = jsonDecode(extraDataRaw) as Map<String, dynamic>;
          } catch (e) {
            print('Error decoding extra_data: $e');
            extraData = null;
          }
        } else if (extraDataRaw is Map) {
          extraData = extraDataRaw as Map<String, dynamic>;
        }
        
        if (extraData != null) {
          print('===== EXTRA DATA PARSED =====');
          print('Extra Data: $extraData');
          print('nik_baru: ${extraData['nik_baru']}');
          print('namaWarga_baru: ${extraData['namaWarga_baru']}');
          print('nik: ${extraData['nik']}');
          print('namaWarga: ${extraData['namaWarga']}');
          print('============================');
          
          setState(() {
            _hasExistingProfile = false;
            
            // Gunakan nik_baru dan namaWarga_baru dari verification request
            // Jika tidak ada, ambil dari level verification langsung
            final nikBaruValue = extraData!['nik_baru'] ?? 
                                extraData['nik'] ?? 
                                _latestVerification!['nik_baru'] ??
                                _latestVerification!['nik'];
            _nikController.text = nikBaruValue != null ? nikBaruValue.toString() : '';
            
            final namaBaruValue = extraData['namaWarga_baru'] ?? 
                                 extraData['namaWarga'] ?? 
                                 _latestVerification!['namaWarga_baru'] ??
                                 _latestVerification!['namaWarga'];
            _namaController.text = namaBaruValue?.toString() ?? '';
            
            _jenisKelamin = extraData['jenisKelamin']?.toString() ?? 'Laki-laki';
            _statusDomisili = extraData['statusDomisili']?.toString() ?? 'tetap';
            _statusHidup = extraData['statusHidup']?.toString() ?? 'hidup';
            
            // keluargaId juga bisa int atau String
            final keluargaIdValue = extraData['keluargaId'];
            _keluargaIdController.text = keluargaIdValue != null ? keluargaIdValue.toString() : '';
            
            // Ambil foto KTP dari verification request (bisa ada di extra_data atau di level verification)
            final fotoKtpUrl = extraData['foto_ktp_baru'] ?? 
                              extraData['foto_ktp'] ?? 
                              _latestVerification!['foto_ktp_baru'] ??
                              _latestVerification!['foto_ktp'];
            _existingKtpUrl = fotoKtpUrl?.toString();
          });
        }
      } else {
        // Tidak ada profile dan tidak ada pending, form tetap kosong
        setState(() {
          _hasExistingProfile = false;
          _existingKtpUrl = null;
        });
      }
      
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }
  
  Future<void> _loadVerificationStatus() async {
    try {
      final result = await _verificationService.getMyRequests();
      
      print('===== VERIFICATION REQUESTS DEBUG =====');
      print('Result: $result');
      print('========================================');
      
      if (result['success'] == true && result['data'] != null) {
        final requests = result['data'] is List ? result['data'] : [];
        
        if (requests.isNotEmpty) {
          // Sort by createdAt descending to get latest
          requests.sort((a, b) {
            final aDate = DateTime.tryParse(a['createdAt']?.toString() ?? '');
            final bDate = DateTime.tryParse(b['createdAt']?.toString() ?? '');
            if (aDate == null || bDate == null) return 0;
            return bDate.compareTo(aDate);
          });
          
          final latest = requests[0];
          final status = latest['status']?.toString().toLowerCase() ?? '';
          
          setState(() {
            _latestVerification = latest;
            _verificationStatus = status;
            
            if (status == 'rejected') {
              _rejectionMessage = latest['rejection_reason']?.toString() ?? 
                                 'Permintaan Anda ditolak oleh admin';
            }
          });
        }
      }
    } catch (e) {
      print('Error loading verification status: $e');
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
        _showResultDialog(
          success: false,
          message: 'Gagal memilih gambar: $e',
        );
      }
    }
  }

  void _showResultDialog({required bool success, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Auto close after 1.5 seconds
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: success ? Colors.green.shade50 : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    success ? Icons.check_circle : Icons.error,
                    color: success ? Colors.green : Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  success ? 'Berhasil!' : 'Gagal!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: success ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_ktpImage == null) {
        _showResultDialog(
          success: false,
          message: 'Foto KTP wajib diupload',
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
        _showResultDialog(
          success: true,
          message: result['message'] ?? 'Data warga berhasil diajukan',
        );
        // Auto close page after showing success dialog
        Future.delayed(const Duration(milliseconds: 1600), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      } else {
        _showResultDialog(
          success: false,
          message: result['message'] ?? 'Gagal mengajukan data warga',
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

    final bool isPending = _verificationStatus == 'pending';
    final bool isRejected = _verificationStatus == 'rejected';
    final bool isApproved = _hasExistingProfile || _verificationStatus == 'approved';
    
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
              if (isPending)
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.pending, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Data Anda sedang dalam proses review oleh admin. Silahkan tunggu tindakan dari admin.',
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (isRejected)
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Permintaan terakhir Anda ditolak oleh admin',
                                style: TextStyle(
                                  color: Colors.red[900],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_rejectionMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Alasan: $_rejectionMessage',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Anda dapat mengajukan kembali dengan memperbaiki data.',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (isApproved)
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Data Anda sudah disetujui dan tersimpan.',
                            style: TextStyle(
                              color: Colors.green[900],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Isi data sesuai dengan KTP Anda. Data akan diverifikasi oleh admin.',
                            style: TextStyle(
                              color: Colors.blue[900],
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
                isPending 
                    ? 'Foto KTP (Sedang Diverifikasi)' 
                    : isRejected
                        ? 'Foto KTP * (Upload Ulang)'
                        : isApproved
                            ? 'Foto KTP (Tersimpan)'
                            : 'Foto KTP *',
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
                    border: Border.all(
                      color: isPending 
                          ? Colors.orange.shade300 
                          : isRejected
                              ? Colors.red.shade300
                              : Colors.grey,
                      width: isPending || isRejected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isPending 
                        ? Colors.orange[50] 
                        : isRejected
                            ? Colors.red[50]
                            : Colors.grey[100],
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
                                    color: isPending ? Colors.orange.shade400 : Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  isPending 
                                      ? 'Foto KTP sedang diverifikasi' 
                                      : 'Tap untuk upload foto KTP',
                                  style: TextStyle(
                                    color: isPending ? Colors.orange.shade700 : Colors.black87,
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
                        isPending 
                            ? 'Silahkan Tunggu Tindakan dari Admin' 
                            : isRejected
                                ? 'Ajukan Ulang'
                                : isApproved
                                    ? 'Update Data'
                                    : 'Ajukan Data Warga',
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
