import 'dart:convert';

import 'package:passkeys/types.dart';

import 'fido2_repository.dart';
import 'sfs_client_platform_interface.dart';
import 'package:passkeys/authenticator.dart';

class SfsClient {
  final String _serverUrl;
  final String _clientId;
  final String _clientSecret;
  final Fido2Repository _fido2repository;

  SfsClient(this._serverUrl, this._clientId, this._clientSecret) : _fido2repository = Fido2Repository.withServerUrl(_serverUrl);

  Future<String> register(String username, String displayName, {String count = ""}) async {
    if (username.isEmpty) return 'Tên đăng nhập không được để trống.';
    if (displayName.isEmpty) return 'Tên hiển thị không được để trống.';

    final result = await _fido2repository.createUserAccount(username + count, displayName + count);
    final id = result["id"];
    if (id == null) {
      return 'Lỗi: Đăng ký thất bại!';
    }
    try {
      final passkeys = PasskeyAuthenticator();
      final options = await getAttestationOptions(username: username + count, displayName: username + count);
      if (options == null) return 'Lỗi: No response from server';
      RegisterRequestType registerRequestType = _createRegisterRequestType(options);
      RegisterResponseType registerResponseType = await passkeys.register(registerRequestType);
      final response = await sendAttestationResult(attestationResult: convertRegisterResponseTypeToMap(registerResponseType));
      return response?.isNotEmpty == true ? id : 'Lỗi: No response from server';
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

  Future<String> authenticate(String username) async {
    if (username.isEmpty) return 'Tên đăng nhập không được để trống.';
    try {
      final passkeys = PasskeyAuthenticator();
      final options = await getAssertionOptions(username: username);
      if (options == null) return 'Lỗi: No response from server';
      AuthenticateRequestType authenticateRequestType = _createAuthenticateRequestType(options);
      AuthenticateResponseType authenticateResponseType = await passkeys.authenticate(authenticateRequestType);
      final response = await sendAssertionResult(attestationResult: convertAuthenticateResponseToMap(authenticateResponseType));
      return response?.isNotEmpty == true ? '$response' : 'Lỗi: No response from server';
    } catch (e) {
      if (e.toString().contains("excluded credentials exists")) {
        return 'Lỗi: Một passkey đã tồn tại trên thiết bị. Vui lòng xóa passkey cũ trong cài đặt thiết bị.';
      } else if (e.toString().contains("RP ID cannot be validated")) {
        return 'Lỗi: Không thể xác thực RP ID. Vui lòng kiểm tra cấu hình Digital Asset Links trên server.';
      } else if (e.toString().contains("cancelled") || e is PasskeyAuthCancelledException) {
        return 'Xác thực bị hủy bởi người dùng.';
      } else if (e is NoCredentialsAvailableException) {
        return 'NoCredentialsAvailableException';
      } else if (e is DomainNotAssociatedException) {
        return 'Lỗi: Domain chưa được liên kết với ứng dụng. Vui lòng kiểm tra cấu hình.';
      }
      else {
        return 'Lỗi: $e';
      }
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

  Future<Map<String, dynamic>?> getAttestationOptions({
    required String username,
    required String displayName,
  }) async {
    try {
      final options = await _fido2repository.getAttestationOptions(username, displayName);
      return options;
    } catch (e) {
      return null;
    }
  }

  Future<String?> sendAttestationResult({
    required Map<String, dynamic> attestationResult,
  }) async {
    try {
      final options = await _fido2repository.sendAttestationResult(attestationResult);
      return options;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAssertionOptions({
    required String username,
  }) async {
    try {
      final options = await _fido2repository.getAssertionOptions(username);
      return options;
    } catch (e) {
      return null;
    }
  }

  Future<String?> sendAssertionResult({
    required Map<String, dynamic> attestationResult,
  }) async {
    try {
      final options = await _fido2repository.sendAssertionResult(attestationResult);
      return options;
    } catch (e) {
      return null;
    }
  }
}
