import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'model.dart';


// ✅ MAIN ENDPOINT CLASS (ĐƠN GIẢN HÓA)
class Fido2ServerEndpoint {
  final String _baseUrl;
  final String _clientId;
  final String _clientSecret;
  final http.Client _httpClient;

  AccessToken? _accessToken;
  bool _isConnected = false;

  // ✅ CONSTRUCTOR
  Fido2ServerEndpoint(
      this._baseUrl,
      this._clientId,
      this._clientSecret, {
        http.Client? httpClient,
      }) : _httpClient = httpClient ?? http.Client();

  // ✅ GETTERS
  bool get isConnected => _isConnected && _accessToken != null && !_isTokenExpired();
  String? get accessToken => _accessToken?.token;

  // ✅ COMMON HEADERS
  Map<String, String> get _commonHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    if (_accessToken != null && !_isTokenExpired()) {
      headers['Authorization'] = _accessToken!.authorization;
    }

    return headers;
  }

  // ✅ TOKEN VALIDATION
  bool _isTokenExpired() {
    if (_accessToken == null) return true;
    return DateTime.now().isAfter(_accessToken!.expiresAt.subtract(Duration(minutes: 5)));
  }

  // ✅ HTTP METHODS (ĐƠN GIẢN HÓA)
  Future<http.Response> _get(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _httpClient.get(uri, headers: _commonHeaders);
    return response;
  }
  Future<List<dynamic>> _getList(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _httpClient.get(uri, headers: _commonHeaders);

    // Kiểm tra status code để đảm bảo request thành công
    if (response.statusCode == 200) {
      // Parse JSON từ body của response
      final data = jsonDecode(response.body);
      // Kiểm tra nếu data là List, nếu không thì trả về danh sách rỗng hoặc ném lỗi
      if (data is List<dynamic>) {
        return data;
      } else if (data is Map<String, dynamic> && data.containsKey('authenticators')) {
        // Trường hợp server trả về một Map với key 'authenticators' chứa List
        return data['authenticators'] as List<dynamic>? ?? [];
      } else {
        throw Exception('Response data is not a valid List or does not contain "authenticators" key');
      }
    } else {
      throw Exception('Failed to fetch data: Status code ${response.statusCode}');
    }
  }


  Future<http.Response> _post(String endpoint, {dynamic data}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    String? body;
    if (data != null) {
      body = jsonEncode(data);
    }
    final response = await _httpClient.post(uri, headers: _commonHeaders, body: body);
    return response;
  }

  Future<http.Response> _put(String endpoint, {dynamic data}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    String? body;
    if (data != null) {
      body = jsonEncode(data);
    }
    final response = await _httpClient.put(uri, headers: _commonHeaders, body: body);
    return response;
  }

  Future<http.Response> _delete(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _httpClient.delete(uri, headers: _commonHeaders);
    return response;
  }

  // ✅ HANDLE RESPONSE
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      throw HttpException('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // ✅ API METHODS (ĐƠN GIẢN HÓA THEO JAVA INTERFACE)

  // 🔐 AUTHENTICATION
  Future<AccessToken> getAccessToken(AccessTokenRequest request) async {
    final response = await _post('/api/auth/endpoint/access-token', data: request.toJson());
    final data = await _handleResponse(response);
    _accessToken = AccessToken.fromJson(data);
    _isConnected = true;
    return _accessToken!;
  }

  // 📊 STATUS & INFO
  Future<EndpointStatus> getStatus() async {
    final response = await _get('/api/endpoint/status');
    final data = await _handleResponse(response);
    return EndpointStatus.fromJson(data);
  }

  Future<ServiceLicense> getLicense() async {
    final response = await _get('/api/endpoint/license');
    final data = await _handleResponse(response);
    return ServiceLicense.fromJson(data);
  }

  Future<ServiceInfo> getInfo() async {
    final response = await _get('/api/endpoint/info');
    final data = await _handleResponse(response);
    return ServiceInfo.fromJson(data);
  }

  // 👥 USER MANAGEMENT
  Future<List<User>> getUsers() async {
    final response = await _get('/api/endpoint/users');
    final data = await _handleResponse(response);
    return (data as List? ?? []).map((json) => User.fromJson(json)).toList();
  }

  Future<User> createUser(CreateUserRequest request) async {
    final response = await _post('/api/endpoint/users', data: request.toJson());
    final data = await _handleResponse(response);
    return User.fromJson(data);
  }

  Future<User> getUserById(String userId) async {
    final response = await _get('/api/endpoint/users/$userId');
    final data = await _handleResponse(response);
    return User.fromJson(data);
  }

  Future<User> deleteUserById(String userId) async {
    final response = await _delete('/api/endpoint/users/$userId');
    final data = await _handleResponse(response);
    return User.fromJson(data);
  }

  // 🔑 AUTHENTICATOR MANAGEMENT
  Future<List<Authenticator>> getAuthenticators(String userId) async {
    try {
      // Gọi API service để lấy danh sách authenticators
      List<dynamic> response = await _getList('/api/endpoint/users/$userId/authenticators');

      // Chuyển đổi response thành List<Authenticator>
      List<Authenticator> authenticators = response.map((item) {
        if (item is Map<String, dynamic>) {
          return Authenticator.fromJson(item);
        } else {
          throw Exception('Item is not a valid JSON object');
        }
      }).toList();

      return authenticators;
    } catch (e) {
      print('Error fetching authenticators: $e');
      return [];
    }
  }

  Future<Authenticator> updateAuthenticator(String userId, String authenticatorId, Map<String, dynamic> body) async {
    final response = await _put('/api/endpoint/users/$userId/authenticators/$authenticatorId', data: body);
    final data = await _handleResponse(response);
    return Authenticator.fromJson(data);
  }

  Future<Authenticator> deleteAuthenticator(String userId, String authenticatorId) async {
    final response = await _delete('/api/endpoint/users/$userId/authenticators/$authenticatorId');
    final data = await _handleResponse(response);
    return Authenticator.fromJson(data);
  }

  // 🔐 WEBAUTHN OPERATIONS
  Future<Map<String, dynamic>> attestationOptions(AttestationOptionsRequest request) async {
    final response = await _post('/api/endpoint/attestation/options', data: request.toJson());
    final data = await _handleResponse(response);
    // return AttestationOptions.fromJson(data);
    return data;
  }

  Future<AttestationResult> attestationResult(Map<String, dynamic> credential) async {
    final response = await _post('/api/endpoint/attestation/result', data: credential);
    final data = await _handleResponse(response);
    return AttestationResult.fromJson(data);
  }

  Future<Map<String, dynamic>> assertionOptions(AssertionOptionsRequest request) async {
    final response = await _post('/api/endpoint/assertion/options', data: request.toJson());
    final data = await _handleResponse(response);
    // return AssertionOptions.fromJson(data);
    return data;
  }

  Future<Map<String, dynamic>> assertionResult(Map<String, dynamic> credential) async {
    final response = await _post('/api/endpoint/assertion/result', data: credential);
    final data = await _handleResponse(response);
    // return AssertionResult.fromJson(data);
    return data;
  }

  // ✅ CONNECTION MANAGEMENT
  Future<void> connect() async {
    final request = AccessTokenRequest(clientId: _clientId, clientSecret: _clientSecret);
    await getAccessToken(request);
  }

  Future<void> disconnect() async {
    _accessToken = null;
    _isConnected = false;
  }
}