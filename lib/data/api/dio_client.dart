import 'package:tdtime/common/constants.dart';
import 'package:tdtime/data/api/dio_exception.dart';
import 'package:tdtime/domain/models/response_api.dart';
import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;
  final options = Options(
    headers: {
      'Content-type': 'application/json',
      // if (Get.isRegistered<UserRepository>() &&
      //     Get.find<UserRepository>().token.isNotEmpty)
      //   'Authorization': 'Bearer ${Get.find<UserRepository>().token}',
    },
  );
  DioClient(this.dio) {
    dio
      ..options.baseUrl = serverPath
      ..options.connectTimeout = const Duration(seconds: 35)
      ..options.receiveTimeout = const Duration(seconds: 35);
  }

  Future<ResponseApi> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool isExtended = false,
  }) async {
    try {
      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return processResponse(response.data, url, isExtended: isExtended);
    } catch (e) {
      return errorHandling(e);
    }
  }

  Future<ResponseApi> post(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.post(
        url,
        data: data,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return processResponse(response.data, url);
    } catch (e) {
      return errorHandling(e);
    }
  }

  Future<ResponseApi> put(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return processResponse(response.data, url);
    } catch (e) {
      return errorHandling(e);
    }
  }

  Future<ResponseApi> delete(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return processResponse(response.data, url);
    } catch (e) {
      return errorHandling(e);
    }
  }
}

ResponseApi errorHandling(Object e) {
  if (e is DioException) {
    DioExceptions dioException = DioExceptions.fromDioError(e);
    return ResError(errorMessage: dioException.errorText);
  } else {
    return ResError(errorMessage: 'Unexpected error occurred: ${e.toString()}');
  }
}

ResponseApi processResponse(
  Map<String, dynamic> res,
  String path, {
  bool isExtended = false,
}) {
  if (isExtended || res['success'] == true) {
    late ResSuccess resSuccess;
    if (isExtended) {
      resSuccess = ResSuccess(res);
    } else {
      resSuccess = ResSuccess(res['base']);
    }
    resSuccess.consoleRes(path);
    return resSuccess;
  } else {
    ResError resError = ResError(errorMessage: res['message']);
    resError.consoleRes(path);
    return resError;
  }
}
