import 'package:passkeys/types.dart';
import 'model.dart';
import 'fido2_server_endpoint.dart';

/// 🔐 FIDO2 Repository - Lớp trung gian quản lý FIDO2/WebAuthn operations
///
/// Cung cấp interface đơn giản để tương tác với FIDO2 Server
/// Hỗ trợ các tính năng cơ bản: User Management, Registration, Authentication
class Fido2Repository {
  final Fido2ServerEndpoint _endpoint;

  // ✅ CONSTRUCTORS
  /// Tạo repository với server URL và credentials
  Fido2Repository({
    required String serverUrl,
    required String clientId,
    required String clientSecret,
  }) : _endpoint = Fido2ServerEndpoint(serverUrl, clientId, clientSecret);

  // ✅ CONNECTION MANAGEMENT
  /// Kết nối tới FIDO2 Server
  Future<void> connect() async {
    await _endpoint.connect();
  }

  /// Ngắt kết nối khỏi FIDO2 Server
  Future<void> disconnect() async {
    await _endpoint.disconnect();
  }

  /// Kiểm tra trạng thái kết nối
  bool get isConnected => _endpoint.isConnected;

  // ✅ SERVER STATUS & INFO
  /// Lấy trạng thái server
  // Future<EndpointStatus> getStatus() async {
  //   return await _endpoint.getStatus();
  // }

  /// Lấy thông tin server
  // Future<ServiceInfo> getInfo() async {
  //   return await _endpoint.getInfo();
  // }

  /// Lấy thông tin license
  // Future<ServiceLicense> getLicense() async {
  //   return await _endpoint.getLicense();
  // }

  // ✅ USER MANAGEMENT
  /// Lấy danh sách users
  Future<List<User>> getUsers() async {
    await connect();
    return await _endpoint.getUsers();
  }

  /// Tạo user mới
  Future<User?> createUser(String username, String displayName) async {
    await connect();
    final request = CreateUserRequest(username: username, displayName: displayName);
    return await _endpoint.createUser(request);
  }

  /// Lấy thông tin user theo ID
  Future<User> getUserById(String userId) async {
    await connect();
    return await _endpoint.getUserById(userId);
  }

  /// Xóa user theo ID
  // Future<User> deleteUserById(String userId) async {
  //   return await _endpoint.deleteUserById(userId);
  // }

  // ✅ AUTHENTICATOR MANAGEMENT
  /// Lấy danh sách authenticators của user
  Future<List<Authenticator>> getAuthenticators(String userId) async {
    await connect();
    return await _endpoint.getAuthenticators(userId);
  }
  Future<Authenticator> updateAuthenticator(String userId, String authenticatorId, Map<String, dynamic> body) async {
    await connect();
    return await _endpoint.updateAuthenticator(userId, authenticatorId, body);
  }
  Future<Authenticator> deleteAuthenticator(String userId, String authenticatorId) async {
    await connect();
    return await _endpoint.deleteAuthenticator(userId, authenticatorId);
  }

  // ✅ WEBAUTHN REGISTRATION (ATTESTATION)
  /// Bắt đầu quá trình registration
  Future<Map<String, dynamic>> attestationOptions(String username, String displayName) async {
    await connect();
    final request = AttestationOptionsRequest(username: username, displayName: displayName);
    return await _endpoint.attestationOptions(request);
  }

  /// Hoàn tất quá trình registration
  Future<AttestationResult> attestationResult(Map<String, dynamic> credential) async {
    await connect();
    return await _endpoint.attestationResult(credential);
  }

  // ✅ WEBAUTHN AUTHENTICATION (ASSERTION)
  /// Bắt đầu quá trình authentication
  Future<Map<String, dynamic>> assertionOptions(String username) async {
    await connect();
    final request = AssertionOptionsRequest(username: username);
    return await _endpoint.assertionOptions(request);
  }

  /// Hoàn tất quá trình authentication
  Future<Map<String, dynamic>> assertionResult(Map<String, dynamic> credential) async {
    await connect();
    return await _endpoint.assertionResult(credential);
  }
}