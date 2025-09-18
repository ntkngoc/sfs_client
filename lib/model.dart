
// ✅ MODELS (ĐƠN GIẢN HÓA)

import 'package:intl/intl.dart';

class AccessToken {
  final String token;
  final String tokenType;
  final int expiresIn;
  final DateTime expiresAt;

  AccessToken({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.expiresAt,
  });

  String get authorization => '$tokenType $token';

  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(
      token: json['access_token'] ?? json['token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 3600,
      expiresAt: DateTime.now().add(Duration(seconds: json['expires_in'] ?? 3600)),
    );
  }
}

class AccessTokenRequest {
  final String clientId;
  final String clientSecret;
  final int timeoutInSeconds;

  AccessTokenRequest({
    required this.clientId,
    required this.clientSecret,
    this.timeoutInSeconds = 600,
  });

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'clientSecret': clientSecret,
    'timeoutInSeconds': timeoutInSeconds,
  };
}

class EndpointStatus {
  final String status;
  final String? message;

  EndpointStatus({
    required this.status,
    this.message,
  });

  factory EndpointStatus.fromJson(Map<String, dynamic> json) {
    return EndpointStatus(
      status: json['status'] ?? 'unknown',
      message: json['message'],
    );
  }
}

class ServiceInfo {
  final String name;
  final String version;

  ServiceInfo({
    required this.name,
    required this.version,
  });

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      name: json['name'] ?? '',
      version: json['version'] ?? '',
    );
  }
}

class ServiceLicense {
  final String type;
  final bool isValid;

  ServiceLicense({
    required this.type,
    required this.isValid,
  });

  factory ServiceLicense.fromJson(Map<String, dynamic> json) {
    return ServiceLicense(
      type: json['type'] ?? '',
      isValid: json['is_valid'] ?? false,
    );
  }
}

class User {
  final String id;
  final String username;
  final String? displayName;

  User({
    required this.id,
    required this.username,
    this.displayName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['display_name'],
    );
  }
}

class CreateUserRequest {
  final String username;
  final String displayName;

  CreateUserRequest({
    required this.username,
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'displayName': displayName,
  };
}

class Authenticator {
  final String id;
  final String name;
  final String credentialId;
  final String aaguid;
  final String coseKey;
  final String format;
  final List<String> transports;
  final String? createdDate;
  final String? lastAccess;
  final int counter;

  Authenticator({
    required this.id,
    required this.name,
    required this.credentialId,
    required this.aaguid,
    required this.coseKey,
    required this.format,
    required this.transports,
    required this.createdDate,
    required this.lastAccess,
    required this.counter,
  });

  factory Authenticator.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Authenticator(
      id: json['id'] as String? ?? '',
      // Sử dụng String? để cho phép null
      credentialId: json['credentialId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      aaguid: json['aaguid'] as String? ?? '',
      coseKey: json['coseKey'] as String? ?? '',
      format: json['format'] as String? ?? '',
      transports: List<String>.from(json['transports'] ?? []),
      // Kiểm tra null
      createdDate: json['createdDate'] != null
          ? dateFormat.format(DateTime.parse(json['createdDate']))
          : null,
      lastAccess: json['lastAccess'] != null
          ? dateFormat.format(DateTime.parse(json['lastAccess']))
          : null,
      counter: json['counter'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'credentialId': credentialId,
      'aaguid': aaguid,
      'coseKey': coseKey,
      'format': format,
      'transports': transports,
      'createdDate': createdDate,
      'lastAccess': lastAccess,
      'counter': counter,
    };
  }
}

class AttestationOptionsRequest {
  final String username;
  final String displayName;

  AttestationOptionsRequest({
    required this.username,
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'displayName': displayName,
  };
}

class AssertionOptionsRequest {
  final String username;

  AssertionOptionsRequest({
    required this.username,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
  };
}

class AttestationOptions {
  final Map<String, dynamic> publicKeyCredentialCreationOptions;
  final String challenge;

  AttestationOptions({
    required this.publicKeyCredentialCreationOptions,
    required this.challenge,
  });

  factory AttestationOptions.fromJson(Map<String, dynamic> json) {
    return AttestationOptions(
      publicKeyCredentialCreationOptions: json['publicKeyCredentialCreationOptions'] ?? {},
      challenge: json['challenge'] ?? '',
    );
  }
}

class AssertionOptions {
  final Map<String, dynamic> publicKeyCredentialRequestOptions;
  final String challenge;

  AssertionOptions({
    required this.publicKeyCredentialRequestOptions,
    required this.challenge,
  });

  factory AssertionOptions.fromJson(Map<String, dynamic> json) {
    return AssertionOptions(
      publicKeyCredentialRequestOptions: json['publicKeyCredentialRequestOptions'] ?? {},
      challenge: json['challenge'] ?? '',
    );
  }
}

/// 🔑 AttestationResult - Kết quả của quá trình đăng ký (attestation)
class AttestationResult extends EndpointStatus {
  final String id;
  final String name;
  final String format;
  final String credentialId;
  final String aaguid;
  final DateTime? createdDate;
  final DateTime? lastAccess;
  final int counter;
  final String userId;
  final String username;
  final Set<String> transports;

  AttestationResult({
    required String status,
    required this.id,
    required this.name,
    required this.format,
    required this.credentialId,
    required this.aaguid,
    this.createdDate,
    this.lastAccess,
    required this.counter,
    required this.userId,
    required this.username,
    required this.transports,
  }) : super(status: status);

  // ✅ FACTORY FROM JSON
  factory AttestationResult.fromJson(Map<String, dynamic> json) {
    return AttestationResult(
      status: json['status'] as String? ?? 'unknown',
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      format: json['format'] as String? ?? '',
      credentialId: json['credentialId'] as String? ?? '',
      aaguid: json['aaguid'] as String? ?? '',
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'] as String)
          : null,
      lastAccess: json['lastAccess'] != null
          ? DateTime.tryParse(json['lastAccess'] as String)
          : null,
      counter: json['counter'] as int? ?? 0,
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      transports: (json['transports'] as List<dynamic>?)?.cast<String>().toSet() ?? {},
    );
  }

  // ✅ CONVERT TO JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'id': id,
      'name': name,
      'format': format,
      'credentialId': credentialId,
      'aaguid': aaguid,
      'createdDate': createdDate?.toIso8601String(),
      'lastAccess': lastAccess?.toIso8601String(),
      'counter': counter,
      'userId': userId,
      'username': username,
      'transports': transports.toList(),
    };
  }
}

class AssertionResult {
  final bool verified;
  final String? authenticatorId;

  AssertionResult({
    required this.verified,
    this.authenticatorId,
  });

  factory AssertionResult.fromJson(Map<String, dynamic> json) {
    return AssertionResult(
      verified: json['verified'] ?? false,
      authenticatorId: json['authenticator_id'],
    );
  }
}