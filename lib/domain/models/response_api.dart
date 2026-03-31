import 'package:flutter_easylogger/flutter_logger.dart';

/// общий класс для ответов из Api
class ResponseApi {
  void consoleRes(String path) {}

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

/// ошибка ответа из Api
class ResError extends ResponseApi {
  final String errorMessage;
  ResError({required this.errorMessage});
  @override
  void consoleRes(String path) {
    Logger.e('path: $path ResError: $errorMessage');
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = errorMessage;
    return data;
  }
}

/// успешный ответ из Api
class ResSuccess<T> extends ResponseApi {
  final T data;
  ResSuccess(this.data);
  @override
  void consoleRes(String path) {
    Logger.d('path: $path ResponseApi: $data');
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['base'] = this.data;
    return data;
  }
}
