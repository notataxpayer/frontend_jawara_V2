class ApiConfig {
  static const String baseUrl = 'http://virtualtech.icu:3030';
  static const String apiPath = '/api';
  
  // Full API URL
  static const String apiUrl = '$baseUrl$apiPath';
  
  // Auth endpoints
  static const String authLogin = '$apiUrl/auth/login';
  static const String authRegister = '$apiUrl/auth/register';
  static const String authProfile = '$apiUrl/auth/profile';
  
  // Warga endpoints
  static const String warga = '$apiUrl/warga';
  static const String wargaSelfRegister = '$apiUrl/warga/self-register';
  
  // Keluarga endpoints
  static const String keluarga = '$apiUrl/keluarga';
  
  // Rumah endpoints
  static const String rumah = '$apiUrl/rumah';
  
  // MarketPlace endpoints
  static const String marketplace = '$apiUrl/marketplace';
  
  // Upload/Image base URL
  static const String imageBaseUrl = '$baseUrl/uploads';
  
  // Verification Warga endpoints
  static const String verificationWarga = '$apiUrl/verification-warga';
  static const String verificationSubmit = '$apiUrl/verification-warga/submit';
  static const String verificationMyRequests = '$apiUrl/verification-warga/my-requests';
  static const String verificationAll = '$apiUrl/verification-warga/all';
  static const String verificationPending = '$apiUrl/verification-warga/pending';
  static const String verificationWargaApprove = '$apiUrl/verification-warga/approve';
  static const String verificationWargaReject = '$apiUrl/verification-warga/reject';
  
  // Common headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };
  
  static Map<String, String> headersWithAuth(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
  
  // Helper method to get full image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Otherwise, prepend base URL
    return '$imageBaseUrl/$imagePath';
  }
}
