abstract class Client {
  Future<R> $call<Q, R>(Method<Q, R> method, Q request, {Map<String, String> customParams});
}

class Method<Q, R> {
  final String path;
  final List<int> Function(Q value) toProto;
  final Object Function(Q value) toJson;
  final R Function(List<int> value) fromProto;
  final R Function(Object json) fromJson;

  Method(this.path, this.toProto, this.toJson, this.fromProto, this.fromJson);
}

class Response<T> {
  final T data;
  final String message;
  final int code; // 服务端业务code
  final int statusCode; // http status code

  bool get success {
    return code == 0;
  }

  const Response({this.data, this.message, this.code, this.statusCode});
}

class ApiException implements Exception {
  final int code;
  final String message;

  const ApiException([this.code, this.message = ""]);
}

Future<Response<T>> $handleResponse<T>(Future<dynamic> call) async {
  try {
    dynamic resp = await call;
    return Response<T>(code: resp.code, message: resp.msg, statusCode: 200, data: resp.data);
  } catch (e) {
    if (e is ApiException) {
      return Response<T>(statusCode: e.code, message: e.message);
    }
    return Response<T>(message: e.toString());
  }
}
