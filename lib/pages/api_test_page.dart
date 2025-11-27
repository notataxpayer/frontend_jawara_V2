import 'package:flutter/material.dart';
import 'package:pbl_jawara_test/services/auth_service.dart';
import 'package:pbl_jawara_test/services/warga_api_service.dart';
import 'package:pbl_jawara_test/services/keluarga_api_service.dart';
import 'package:pbl_jawara_test/services/rumah_api_service.dart';
import 'package:pbl_jawara_test/config/api_config.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final _authService = AuthService();
  String _testResult = 'Belum ada test yang dijalankan';
  bool _isLoading = false;
  String? _authToken;

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing login...';
    });

    try {
      final result = await _authService.login(
        'test@example.com',
        'password123',
      );

      setState(() {
        if (result['success']) {
          _authToken = result['data']['token'];
          _testResult = 'Login berhasil!\nToken: $_authToken';
        } else {
          _testResult = 'Login gagal: ${result['message']}';
        }
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetWarga() async {
    if (_authToken == null) {
      setState(() {
        _testResult = 'Harap login terlebih dahulu!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _testResult = 'Testing get all warga...';
    });

    try {
      final wargaService = WargaApiService(token: _authToken);
      final result = await wargaService.getAllWarga();

      setState(() {
        if (result['success']) {
          final data = result['data'];
          _testResult = 'Get Warga berhasil!\nJumlah data: ${data is List ? data.length : 'N/A'}\n\nData: ${data.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}...';
        } else {
          _testResult = 'Get Warga gagal: ${result['message']}';
        }
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetKeluarga() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing get all keluarga...';
    });

    try {
      final keluargaService = KeluargaApiService(token: _authToken);
      final result = await keluargaService.getAllKeluarga();

      setState(() {
        if (result['success']) {
          final data = result['data'];
          _testResult = 'Get Keluarga berhasil!\nJumlah data: ${data is List ? data.length : 'N/A'}\n\nData: ${data.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}...';
        } else {
          _testResult = 'Get Keluarga gagal: ${result['message']}';
        }
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetRumah() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing get all rumah...';
    });

    try {
      final rumahService = RumahApiService(token: _authToken);
      final result = await rumahService.getAllRumah();

      setState(() {
        if (result['success']) {
          final data = result['data'];
          _testResult = 'Get Rumah berhasil!\nJumlah data: ${data is List ? data.length : 'N/A'}\n\nData: ${data.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}...';
        } else {
          _testResult = 'Get Rumah gagal: ${result['message']}';
        }
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        backgroundColor: const Color(0xFF00BFA5),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Base URL: ${ApiConfig.baseUrl}'),
                    Text('API Path: ${ApiConfig.apiPath}'),
                    Text('Full API URL: ${ApiConfig.apiUrl}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test Endpoints:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testLogin,
              icon: const Icon(Icons.login),
              label: const Text('Test Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGetWarga,
              icon: const Icon(Icons.people),
              label: const Text('Test Get All Warga'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGetKeluarga,
              icon: const Icon(Icons.family_restroom),
              label: const Text('Test Get All Keluarga'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGetRumah,
              icon: const Icon(Icons.home),
              label: const Text('Test Get All Rumah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Result:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _testResult,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
