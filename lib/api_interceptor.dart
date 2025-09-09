import 'package:http/http.dart' as http;

class ApiInterceptor {
  Future<http.Response> interceptRequest(http.Request request) async {
    // Thêm header tùy chỉnh nếu cần
    request.headers['Authorization'] = 'Bearer your_token_here'; // Thay thế bằng token thực tế
    return request.send().then(http.Response.fromStream);
  }

  void interceptResponse(http.Response response) {
    // Xử lý phản hồi tại đây, ví dụ: ghi log
    if (response.statusCode == 401) {
      // Xử lý trường hợp không được ủy quyền
      print('Unauthorized request: ${response.request?.url}');
    }
  }
}