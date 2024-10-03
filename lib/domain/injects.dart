import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tdtime/data/api/api.dart';
import 'package:tdtime/data/api/dio_client.dart';
import 'package:tdtime/domain/repository/user_repository.dart';
import 'package:tdtime/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// внедряем зависимости
Future initMain() async {
  await Get.putAsync(() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  });

  try {
    await Get.putAsync(() async {
      final userRepository = UserRepository();
      await userRepository.init();
      return userRepository;
    });
  } catch (e) {
    Logger.e('UserRepository = $e');
    return 'user $e';
  }
  try {
    Get.put<DioClient>(DioClient(Dio()));
    Get.put<Api>(Api());
  } catch (e) {
    Logger.e('DioClient = $e');
    return 'DioClient $e';
  }
  try {
    Get.put<AuthBloc>(AuthBloc());
  } catch (e) {
    Logger.e('AuthBloc = $e');
  }
  try {
    Get.put<MainBloc>(MainBloc());
  } catch (e) {
    Logger.e('mainbloc = $e');
    return 'bloc $e';
  }
  return '';
}
