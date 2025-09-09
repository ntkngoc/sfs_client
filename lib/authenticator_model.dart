import 'package:intl/intl.dart';

class AuthenticatorModel {
  String id;
  String name;
  String credentialId;
  String aaguid;
  String coseKey;
  String format;
  List<String> transports;
  String? createdDate;
  String? lastAccess;
  int counter;

  AuthenticatorModel({
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

  factory AuthenticatorModel.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return AuthenticatorModel(
      id: json['id'] as String? ?? '', // Sử dụng String? để cho phép null
      credentialId: json['credentialId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      aaguid: json['aaguid'] as String? ?? '',
      coseKey: json['coseKey'] as String? ?? '',
      format: json['format'] as String? ?? '',
      transports: List<String>.from(json['transports'] ?? []), // Kiểm tra null
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