import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_interceptor.dart'; // Import interceptor

class ApiService {
  final ApiInterceptor _interceptor = ApiInterceptor();

  // Phương thức chung để gửi yêu cầu
  Future<http.Response> _sendRequest(String method, String endpoint, {Map<String, dynamic>? data}) async {
    final url = Uri.parse(endpoint);
    final request = http.Request(method, url);

    // Thiết lập headers
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept-Charset'] = 'utf-8';

    if (data != null) {
      request.body = jsonEncode(data);
    }

    // Gọi interceptor trước khi gửi yêu cầu
    final response = await _interceptor.interceptRequest(request);

    // Xử lý phản hồi
    _interceptor.interceptResponse(response);
    return response;
  }

  // Hàm chung để xử lý phản hồi API
  T _parseResponse<T>(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception('Error: No response from server');
    }

    try {
      var utf8Body = utf8.decode(response.bodyBytes);
      var jsonData = jsonDecode(utf8Body);

      if (T == List<dynamic>) {
        return jsonData as T; // Trả về danh sách
      } else if (T == Map<String, dynamic>) {
        return jsonData as T; // Trả về Map
      } else {
        throw Exception("Unsupported response type");
      }
    } catch (e) {
      throw Exception("Error parsing response: $e");
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await _sendRequest('GET', endpoint);
    return _parseResponse<Map<String, dynamic>>(response);
  }

  Future<List<dynamic>> getList(String endpoint) async {
    final response = await _sendRequest('GET', endpoint);
    return _parseResponse<List<dynamic>>(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic>? data) async {
    final response = await _sendRequest('POST', endpoint, data: data);
    return _parseResponse<Map<String, dynamic>>(response);
  }

  Future<Map<String, dynamic>> postDataResponse(String endpoint, Map<String, dynamic>? data) async {
    final response = await _sendRequest('POST', endpoint, data: data);
    return _parseResponse<Map<String, dynamic>>(response);
  }

  Future<String> put(String endpoint, Map<String, dynamic> data) async {
    final response = await _sendRequest('PUT', endpoint, data: data);
    return response.body;
  }

  Future<String> delete(String endpoint) async {
    final response = await _sendRequest('DELETE', endpoint);
    return response.body;
  }
}