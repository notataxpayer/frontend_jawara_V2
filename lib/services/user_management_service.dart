import 'package:pbl_jawara_test/models/user.dart';

class UserManagementService {
  // Dummy data pengguna
  static List<User> _users = [
    User(
      id: '1',
      name: 'Nur Aziz',
      email: 'nuraziz@gmail.com',
      password: 'password123',
      phone: '089612345678',
      role: 'Warga',
      createdAt: DateTime.now(),
    ),
    User(
      id: '2',
      name: 'Cak Moll',
      email: 'cakmoll@gmail.com',
      password: 'password123',
      phone: '089623456789',
      role: 'Bendahara',
      createdAt: DateTime.now(),
    ),
    User(
      id: '3',
      name: 'Renhwa',
      email: 'renhwa@gmail.com',
      password: 'password123',
      phone: '089634567890',
      role: 'Ketua RT',
      createdAt: DateTime.now(),
    ),
    User(
      id: '4',
      name: 'Dio Da',
      email: 'dioda@gmail.com',
      password: 'password123',
      phone: '089645678901',
      role: 'Warga',
      createdAt: DateTime.now(),
    ),
    User(
      id: '5',
      name: 'Dio Da',
      email: 'dioda2@gmail.com',
      password: 'password123',
      phone: '089656789012',
      role: 'Warga',
      createdAt: DateTime.now(),
    ),
    User(
      id: '6',
      name: 'Dio Da',
      email: 'dioda3@gmail.com',
      password: 'password123',
      phone: '089667890123',
      role: 'Warga',
      createdAt: DateTime.now(),
    ),
    User(
      id: '7',
      name: 'Dio Da',
      email: 'dioda4@gmail.com',
      password: 'password123',
      phone: '089678901234',
      role: 'Warga',
      createdAt: DateTime.now(),
    ),
    User(
      id: '8',
      name: 'Dio Da',
      email: 'dioda5@gmail.com',
      password: 'password123',
      phone: '089689012345',
      role: 'Warga',
      createdAt: DateTime.now(),
    ),
  ];

  // Get all users
  Future<List<User>> getAllUsers() async {
    // Simulasi delay API
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_users);
  }

  // Search users
  Future<List<User>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (query.isEmpty) {
      return List.from(_users);
    }

    return _users.where((user) {
      return user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase()) ||
          user.role.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Filter users by category
  Future<List<User>> filterUsersByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (category.isEmpty || category == 'Semua') {
      return List.from(_users);
    }

    return _users.where((user) => user.role == category).toList();
  }

  // Get user by ID
  Future<User?> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new user
  Future<Map<String, dynamic>> addUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Validasi email sudah ada
    final existingUser = _users.where((u) => u.email == user.email);
    if (existingUser.isNotEmpty) {
      return {
        'success': false,
        'message': 'Email sudah terdaftar',
      };
    }

    // Generate ID baru
    final newId = (_users.length + 1).toString();
    final newUser = user.copyWith(id: newId);

    _users.add(newUser);

    return {
      'success': true,
      'message': 'Pengguna berhasil ditambahkan',
      'data': newUser.toJson(),
    };
  }

  // Update user
  Future<Map<String, dynamic>> updateUser(String id, User user) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _users.indexWhere((u) => u.id == id);

    if (index == -1) {
      return {
        'success': false,
        'message': 'Pengguna tidak ditemukan',
      };
    }

    // Validasi email sudah ada (kecuali email user sendiri)
    final existingUser =
        _users.where((u) => u.email == user.email && u.id != id);
    if (existingUser.isNotEmpty) {
      return {
        'success': false,
        'message': 'Email sudah digunakan pengguna lain',
      };
    }

    _users[index] = user.copyWith(id: id);

    return {
      'success': true,
      'message': 'Pengguna berhasil diperbarui',
      'data': _users[index].toJson(),
    };
  }

  // Delete user
  Future<Map<String, dynamic>> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _users.indexWhere((u) => u.id == id);

    if (index == -1) {
      return {
        'success': false,
        'message': 'Pengguna tidak ditemukan',
      };
    }

    _users.removeAt(index);

    return {
      'success': true,
      'message': 'Pengguna berhasil dihapus',
    };
  }

  // Get available categories
  List<String> getCategories() {
    return ['Warga', 'Ketua RT', 'Bendahara', 'Sekretaris'];
  }
}
