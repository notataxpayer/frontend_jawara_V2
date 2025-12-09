import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pbl_jawara_test/services/marketplace_service.dart';

class MarketplaceFormPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? itemData;
  final bool isEdit;

  const MarketplaceFormPage({
    super.key,
    required this.token,
    this.itemData,
    this.isEdit = false,
  });

  @override
  State<MarketplaceFormPage> createState() => _MarketplaceFormPageState();
}

class _MarketplaceFormPageState extends State<MarketplaceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final MarketplaceService _marketplaceService;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final _namaProdukController = TextEditingController();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _stokController = TextEditingController();

  // Image
  File? _selectedImage;
  Uint8List? _imageBytes; // For web
  String? _imageFileName; // Store original filename with extension
  String? _existingImageUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _marketplaceService = MarketplaceService(token: widget.token);
    if (widget.isEdit && widget.itemData != null) {
      _fillFormWithData();
    }
  }

  void _fillFormWithData() {
    final data = widget.itemData!;
    _namaProdukController.text = data['namaProduk']?.toString() ?? '';
    _hargaController.text = data['harga']?.toString() ?? '';
    _deskripsiController.text = data['deskripsi']?.toString() ?? '';
    _stokController.text = data['stok']?.toString() ?? '0';
    _existingImageUrl = data['gambar']?.toString();
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll('.', ''));
    if (number == null) return value;
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number).replaceAll(',', '.');
  }

  String _cleanNumber(String value) {
    return value.replaceAll('.', '');
  }

  Future<void> _showImageSourceDialog() async {
    if (kIsWeb) {
      // Di web, langsung buka galeri karena kamera tidak didukung
      _pickImage(ImageSource.gallery);
      return;
    }
    
    // Di mobile, tampilkan pilihan
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Pilih Sumber Gambar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF6A1B9A)),
                  title: const Text('Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF6A1B9A)),
                  title: const Text('Kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      XFile? image;
      
      if (kIsWeb) {
        // Untuk web, gunakan image picker dengan parameter yang sesuai
        image = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
      } else {
        // Untuk mobile, tambahkan preferensi kamera belakang
        image = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.rear,
        );
      }

      if (image == null) {
        // User membatalkan atau kamera gagal
        if (mounted && source == ImageSource.camera) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengambilan foto dibatalkan atau kamera tidak tersedia'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final bytes = await image.readAsBytes();
      
      // Determine filename with proper extension
      String filename;
      if (source == ImageSource.camera) {
        // Foto dari kamera selalu gunakan .jpg
        filename = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
      } else {
        // Foto dari galeri, coba ambil dari nama asli
        filename = image.name;
        // Validasi extension
        if (!filename.toLowerCase().endsWith('.jpg') && 
            !filename.toLowerCase().endsWith('.jpeg') && 
            !filename.toLowerCase().endsWith('.png') && 
            !filename.toLowerCase().endsWith('.webp')) {
          // Detect dari magic bytes (file signature)
          if (bytes.length >= 4) {
            // PNG signature: 89 50 4E 47
            if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
              filename = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
            }
            // JPEG signature: FF D8 FF
            else if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
              filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
            }
            // WebP signature: RIFF ... WEBP
            else if (bytes.length >= 12 && 
                     bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
                     bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
              filename = 'image_${DateTime.now().millisecondsSinceEpoch}.webp';
            }
            else {
              // Default ke jpg jika tidak terdeteksi
              filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
            }
          } else {
            filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          }
        }
      }
      
      setState(() {
        _imageFileName = filename;
        if (kIsWeb) {
          _imageBytes = bytes;
          _selectedImage = null;
        } else {
          _selectedImage = File(image!.path);
          _imageBytes = null;
        }
      });
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Gagal memilih gambar: $e';
        
        // Error handling khusus untuk kamera
        if (source == ImageSource.camera) {
          errorMessage = 'Kamera tidak dapat diakses.\n'
              'Pastikan:\n'
              '- Browser mendukung kamera (Chrome/Edge)\n'
              '- Izin kamera sudah diberikan\n'
              '- Aplikasi dijalankan di HTTPS atau localhost\n\n'
              'Error: $e';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      // Check image for create mode
      if (!widget.isEdit && _selectedImage == null && _imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gambar produk harus dipilih'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final cleanHarga = _cleanNumber(_hargaController.text.trim());
      final harga = int.parse(cleanHarga);
      final stok = int.parse(_stokController.text.trim());

      final result = widget.isEdit
          ? await _marketplaceService.updateItem(
              id: widget.itemData!['id'].toString(),
              gambar: _selectedImage,
              gambarBytes: _imageBytes,
              gambarFilename: _imageFileName ?? 'marketplace_${DateTime.now().millisecondsSinceEpoch}.jpg',
              namaProduk: _namaProdukController.text.trim(),
              harga: harga,
              deskripsi: _deskripsiController.text.trim(),
              stok: stok, // Sekarang bisa kirim stok via JSON
            )
          : await _marketplaceService.createItem(
              gambar: _selectedImage,
              gambarBytes: _imageBytes,
              gambarFilename: _imageFileName ?? 'marketplace_${DateTime.now().millisecondsSinceEpoch}.jpg',
              namaProduk: _namaProdukController.text.trim(),
              harga: harga,
              deskripsi: _deskripsiController.text.trim(),
              stok: stok,
            );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 
              (widget.isEdit ? 'Item berhasil diupdate' : 'Item berhasil ditambahkan')
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Terjadi kesalahan'),
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
          widget.isEdit ? 'Edit Item Marketplace' : 'Tambah Item Marketplace',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00B894),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Picker
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _selectedImage != null || _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb && _imageBytes != null
                            ? Image.memory(
                                _imageBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : !kIsWeb && _selectedImage != null
                                ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Container(),
                      )
                    : _existingImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _existingImageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk pilih gambar',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),

            // Nama Produk
            TextFormField(
              controller: _namaProdukController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                prefixIcon: Icon(Icons.shopping_bag),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama produk tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Harga
            TextFormField(
              controller: _hargaController,
              decoration: const InputDecoration(
                labelText: 'Harga',
                hintText: 'Contoh: 50.000',
                prefixText: 'Rp ',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: (value) {
                final cleanValue = _cleanNumber(value);
                final formatted = _formatNumber(cleanValue);
                if (formatted != value) {
                  _hargaController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga tidak boleh kosong';
                }
                final cleanValue = _cleanNumber(value);
                if (int.tryParse(cleanValue) == null) {
                  return 'Harus berupa angka';
                }
                if (int.parse(cleanValue) < 1) {
                  return 'Harga minimal 1';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Stok
            TextFormField(
              controller: _stokController,
              decoration: const InputDecoration(
                labelText: 'Stok',
                hintText: 'Jumlah stok barang',
                prefixIcon: Icon(Icons.inventory_2),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Stok tidak boleh kosong';
                }
                final stok = int.tryParse(value);
                if (stok == null) {
                  return 'Harus berupa angka';
                }
                if (stok < 0) {
                  return 'Stok tidak boleh negatif';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Deskripsi
            TextFormField(
              controller: _deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Deskripsi produk',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B894),
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
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.isEdit ? 'Update Item' : 'Tambah Item',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sedang memproses...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isEdit 
                            ? 'Mengupdate item marketplace' 
                            : 'Mengupload dan memvalidasi gambar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
