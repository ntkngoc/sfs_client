import 'package:passkeys/types.dart';
import 'package:passkeys/authenticator.dart';

import 'model.dart';
import 'fido2_repository.dart';

/// 🚀 SFS Client - High-level FIDO2/WebAuthn Client
///
/// Provides a complete, easy-to-use interface for FIDO2/WebAuthn operations
/// Built on top of Fido2Repository with platform-specific WebAuthn integration
class SfsClient {
  final String _serverUrl;
  final String _clientId;
  final String _clientSecret;
  final Fido2Repository _fido2Repository;
  final bool _enableLogging;

  // ✅ CONSTRUCTORS
  /// Create SFS Client with server credentials
  SfsClient(
      this._serverUrl,
      this._clientId,
      this._clientSecret, {
        bool enableLogging = false,
      })  : _enableLogging = enableLogging,
        _fido2Repository = Fido2Repository(
          serverUrl: _serverUrl,
          clientId: _clientId,
          clientSecret: _clientSecret,
        );

  // ✅ GETTERS
  String get serverUrl => _serverUrl;
  String get clientId => _clientId;
  bool get enableLogging => _enableLogging;
  Fido2Repository get repository => _fido2Repository;

  // ✅ CONNECTION METHODS
  /// Connect to FIDO2 server
  Future<void> connect() async {
    if (_enableLogging) {
      print('🔌 SfsClient: Connecting to $_serverUrl...');
    }

    await _fido2Repository.connect();

    if (_enableLogging) {
      print('✅ SfsClient: Connected successfully');
    }
  }

  /// Disconnect from server
  Future<void> disconnect() async {
    if (_enableLogging) {
      print('🔌 SfsClient: Disconnecting...');
    }

    await _fido2Repository.disconnect();

    if (_enableLogging) {
      print('✅ SfsClient: Disconnected');
    }
  }

  /// Check connection status
  bool get isConnected => _fido2Repository.isConnected;

  /// Get server status
  // Future<EndpointStatus> getServerStatus() async {
  //   return await _fido2Repository.getStatus();
  // }
  //
  // /// Get license information
  // Future<ServiceLicense> getLicense() async {
  //   return await _fido2Repository.getLicense();
  // }

  // ✅ USER MANAGEMENT METHODS

  /// Get all users
  Future<List<User>> getUsers() async {
    return await _fido2Repository.getUsers();
  }

  /// Create a new user
  // Future<User> createUser(String username, String displayName) async {
  //   if (_enableLogging) {
  //     print('👤 SfsClient: Creating user "$username"...');
  //   }
  //
  //   final user = await _fido2Repository.createUser(username, displayName);
  //
  //   if (_enableLogging) {
  //     print('✅ SfsClient: User created with ID: ${user.id}');
  //   }
  //
  //   return user;
  // }

  // ✅ AUTHENTICATOR MANAGEMENT
  /// Get user's authenticators
  Future<List<Authenticator>> getUserAuthenticators(String userId) async {
    return await _fido2Repository.getAuthenticators(userId);
  }

  /// Delete authenticator
  Future<Authenticator> updateAuthenticator(String userId, String authenticatorId, Map<String, dynamic> body) async {
    if (_enableLogging) {
      print('🗑️ SfsClient: Update authenticator $authenticatorId...');
    }

    return await _fido2Repository.updateAuthenticator(userId, authenticatorId, body);

    if (_enableLogging) {
      print('✅ SfsClient: Authenticator updated');
    }
  }

  /// Delete authenticator
  Future<void> deleteAuthenticator(String userId, String authenticatorId) async {
    if (_enableLogging) {
      print('🗑️ SfsClient: Deleting authenticator $authenticatorId...');
    }

    await _fido2Repository.deleteAuthenticator(userId, authenticatorId);

    if (_enableLogging) {
      print('✅ SfsClient: Authenticator deleted');
    }
  }

  Future<String> register(String username, String displayName) async {
    if (username.isEmpty) return 'Tên đăng nhập không được để trống.';
    if (displayName.isEmpty) return 'Tên hiển thị không được để trống.';

    // 2. Create user
    User? user = await _fido2Repository.createUser(username, displayName);

    try {
      // 2. Create user
      // User user;
      // try {
      //   user = await _fido2Repository.createUser(username, displayName);
      //   print('✅ Đã tạo user: ${user.id}');
      // } catch (e) {
      //   return 'Lỗi: $e';
      // }

      // 3. Get attestation options
      Map<String, dynamic> attestationOptions = await _fido2Repository.attestationOptions(username, displayName);
      print('✅ Đã nhận attestation options');

      // 4. Convert to RegisterRequestType
      RegisterRequestType registerRequestType = _createRegisterRequestType(attestationOptions);
      print('✅ Đã chuyển đổi attestation options');

      // 5. Create passkey using passkeys plugin
      final passkeys = PasskeyAuthenticator();
      RegisterResponseType registerResponseType = await passkeys.register(registerRequestType);
      print('✅ Đã tạo passkey');

      Map<String, dynamic> registerResponseTypeMap = convertRegisterResponseTypeToMap(registerResponseType);
      final attestationResult = await _fido2Repository.attestationResult(registerResponseTypeMap);

      // return user != null ? user.id : 'Lỗi: Đăng ký thất bại!';
      return user != null ? user.id : '';
    } catch (e) {
      if (e.toString().contains("excluded credentials exists")) {
        return 'Lỗi: Một passkey đã tồn tại trên thiết bị. Vui lòng xóa passkey cũ trong cài đặt thiết bị.';
      } else if (e.toString().contains("RP ID cannot be validated")) {
        return 'Lỗi: Không thể xác thực RP ID. Vui lòng kiểm tra cấu hình Digital Asset Links trên server.';
      } else {
        return 'Lỗi: $e';
      }
    }
  }

  Future<bool> authenticate(String username) async {
    try {
      if (username.isEmpty) return false;
      final passkeys = PasskeyAuthenticator();
      final options = await _fido2Repository.assertionOptions(username);
      // if (options == null) return 'Lỗi: No response from server';
      AuthenticateRequestType authenticateRequestType = _createAuthenticateRequestType(options);
      AuthenticateResponseType authenticateResponseType = await passkeys.authenticate(authenticateRequestType);
      Map<String, dynamic> authenticateResponseTypeMap = convertAuthenticateResponseToMap(authenticateResponseType);
      final assertionResult = await _fido2Repository.assertionResult(authenticateResponseTypeMap);
      return true;
    } catch (e) {
      return false;
      // if (e.toString().contains("excluded credentials exists")) {
      //   return 'Lỗi: Một passkey đã tồn tại trên thiết bị. Vui lòng xóa passkey cũ trong cài đặt thiết bị.';
      // } else if (e.toString().contains("RP ID cannot be validated")) {
      //   return 'Lỗi: Không thể xác thực RP ID. Vui lòng kiểm tra cấu hình Digital Asset Links trên server.';
      // } else if (e.toString().contains("cancelled") || e is PasskeyAuthCancelledException) {
      //   return 'Xác thực bị hủy bởi người dùng.';
      // } else if (e is NoCredentialsAvailableException) {
      //   return 'NoCredentialsAvailableException';
      // } else if (e is DomainNotAssociatedException) {
      //   return 'Lỗi: Domain chưa được liên kết với ứng dụng. Vui lòng kiểm tra cấu hình.';
      // }
      // else {
      //   return 'Lỗi: $e';
      // }
    }
  }

  RegisterRequestType _createRegisterRequestType(Map<String, dynamic> options) {
    return RegisterRequestType(
      challenge: options["challenge"],
      relyingParty: RelyingPartyType(
        name: options["rp"]["name"],
        id: options["rp"]["id"],
      ),
      user: UserType(
        displayName: options["user"]["displayName"],
        name: options["user"]["name"],
        id: options["user"]["id"],
      ),
      authSelectionType: AuthenticatorSelectionType(
        requireResidentKey: true,
        residentKey: 'required',
        userVerification: 'required',
        authenticatorAttachment: 'platform',
      ),
      timeout: options["timeout"],
      excludeCredentials: options.containsKey("excludeCredentials") && options["excludeCredentials"] is List<dynamic>
          ? (options["excludeCredentials"] as List<dynamic>)
          .map((cred) => CredentialType(
        id: cred["id"],
        type: cred["type"],
        transports: (cred["transports"] as List<dynamic>?)?.cast<String>() ?? [],
      ))
          .toList()
          : [],
      pubKeyCredParams: options.containsKey("pubKeyCredParams") && options["pubKeyCredParams"] is List<dynamic>
          ? (options["pubKeyCredParams"] as List<dynamic>)
          .map((param) => PubKeyCredParamType(
        type: param["type"] ?? "public-key",
        alg: param["alg"] ?? -7,
      ))
          .toList()
          : [],
    );
  }

  AuthenticateRequestType _createAuthenticateRequestType(Map<String, dynamic> options) {
    return AuthenticateRequestType(
      relyingPartyId: options["rpId"],
      challenge: options["challenge"],
      mediation: MediationType.Required,
      preferImmediatelyAvailableCredentials: true,
      userVerification: "preferred",
      timeout: options.containsKey("timeout") ? options["timeout"] as int : 60000,
      allowCredentials: options.containsKey("allowCredentials") && options["allowCredentials"] is List<dynamic>
          ? (options["allowCredentials"] as List<dynamic>)
          .map((cred) => CredentialType(
        id: cred["id"] ?? "",
        type: cred["type"] ?? "public-key",
        transports: (cred["transports"] as List<dynamic>?)?.cast<String>() ?? [],
      ))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> convertRegisterResponseTypeToMap(RegisterResponseType registerResponseType) {
    return {
      'id': registerResponseType.id,
      'rawId': registerResponseType.rawId,
      'response': {
        'clientDataJSON': registerResponseType.clientDataJSON,
        'attestationObject': registerResponseType.attestationObject,
      },
      'transports': registerResponseType.transports,
      'type': 'public-key'
    };
  }

  Map<String, dynamic> convertAuthenticateResponseToMap(AuthenticateResponseType response) {
    return {
      'id': response.id,
      'rawId': response.rawId,
      'response': {
        'clientDataJSON': response.clientDataJSON,
        'authenticatorData': response.authenticatorData,
        'signature': response.signature,
        'userHandle': response.userHandle,
      },
      'type': 'public-key'
    };
  }
}
