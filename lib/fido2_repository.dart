import 'api_service.dart';
import 'authenticator_model.dart';

class Fido2Repository {
  final String _serverUrl;
  final ApiService _apiService;

  Fido2Repository.withServerUrl(this._serverUrl) : _apiService = ApiService();

  Future<List<AuthenticatorModel>> getAuthenticator(String fidoId) async {
    List<dynamic> response = (await _apiService.get('$_serverUrl/api/getAuthenticator/$fidoId')) as List;

    // Kiểm tra xem response có phải là List hay không
    List<AuthenticatorModel> authenticators = response.map((item) {
      if (item is Map<String, dynamic>) {
        return AuthenticatorModel.fromJson(item);
      } else {
        throw Exception('Item is not a valid JSON object');
      }
    }).toList();

    return authenticators;
  }

  Future<String?> updateNameAuthenticator(String fidoId, String authId, Map<String, dynamic> data) async {
    return await _apiService.put('$_serverUrl/api/updateAuthenticator/$fidoId/$authId', data);
  }

  Future<String?> deleteAuthenticator(String fidoId, String authId) async {
    return await _apiService.delete('$_serverUrl/api/delAuthenticator/$fidoId/$authId');
  }

  Future<Map<String, dynamic>> getAttestationOptions(String username, String displayName) async {
    return await _apiService.post('$_serverUrl/api/webauthn/attestation/options', {
      "username": username, "displayName": displayName
    });
  }

  Future<String?> sendAttestationResult(Map<String, dynamic> attestationResult) async {
    try {
      final response = await _apiService.post('$_serverUrl/api/webauthn/attestation/result', attestationResult);
      return response.toString();
    } catch (e) {
      throw Exception('Failed to send attestation result: $e');
    }
  }

  Future<Map<String, dynamic>> getAssertionOptions(String username) async {
    return await _apiService.post('$_serverUrl/api/webauthn/assertion/options', {
      "username": username
    });
  }

  Future<String?> sendAssertionResult(Map<String, dynamic> attestationResult) async {
    try {
      final response = await _apiService.post('$_serverUrl/api/webauthn/assertion/result', attestationResult);
      return response.toString();
    } catch (e) {
      throw Exception('Failed to send attestation result: $e');
    }
  }
}