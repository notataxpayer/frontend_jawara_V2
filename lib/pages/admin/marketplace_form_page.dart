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
    _existingImageUrl = data['gambar']?.toString();
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        // Get original filename or create one with proper extension
        String filename = image.name;
        if (!filename.toLowerCase().endsWith('.jpg') && 
            !filename.toLowerCase().endsWith('.jpeg') && 
            !filename.toLowerCase().endsWith('.png') && 
            !filename.toLowerCase().endsWith('.webp')) {
          // Default to .jpg if extension not recognized
          filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        }
        
        setState(() {
          _imageFileName = filename;
          if (kIsWeb) {
            _imageBytes = bytes;
          } else {
            _selectedImage = File(image.path);
          }
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

      final result = widget.isEdit
          ? await _marketplaceService.updateItem(
              id: widget.itemData!['id'].toString(),
              gambar: _selectedImage,
              gambarBytes: _imageBytes,
              gambarFilename: _imageFileName ?? 'marketplace_${DateTime.now().millisecondsSinceEpoch}.jpg',
              namaProduk: _namaProdukController.text.trim(),
              harga: harga,
              deskripsi: _deskripsiController.text.trim(),
            )
          : await _marketplaceService.createItem(
              gambar: _selectedImage,
              gambarBytes: _imageBytes,
              gambarFilename: _imageFileName ?? 'marketplace_${DateTime.now().millisecondsSinceEpoch}.jpg',
              namaProduk: _namaProdukController.text.trim(),
              harga: harga,
              deskripsi: _deskripsiController.text.trim(),
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
        backgroundColor: const Color(0xFF6A1B9A),
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
              onTap: _pickImage,
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
                backgroundColor: const Color(0xFF6A1B9A),
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
