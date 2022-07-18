class HttpExcepiton implements Exception {
  final String msg;
  final int statusCode;

  HttpExcepiton({
    required this.msg,
    required this.statusCode,
  });

  @override
  String toString() {
    // TODO: implement toString
    return msg;
  }
}
