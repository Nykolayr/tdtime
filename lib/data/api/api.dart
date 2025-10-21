import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tdtime/common/constants.dart';

import 'package:flutter_easylogger/flutter_logger.dart' as logger;

class Api {
  // final DioClient dio = Get.find<DioClient>();

  /// выгрузка сессии
  Future<String> uploadHystorySessionsToFtp(
      Map<String, dynamic> data, String fileName) async {
    final jsonData = jsonEncode(data);
    logger.Logger.i('data == $jsonData');
    logger.Logger.i('fileName == $fileName');
    logger.Logger.i('Подключение к FTP: $hostFtp с пользователем $loginFtp');

    // Проверяем интернет-соединение
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        return 'Нет подключения к интернету';
      }
      logger.Logger.i('Интернет-соединение доступно');
    } catch (e) {
      logger.Logger.e('Нет интернет-соединения: $e');
      return 'Нет подключения к интернету: $e';
    }

    // Одна попытка подключения к FTP
    final ftpConnect = FTPConnect(
      hostFtp,
      user: loginFtp,
      pass: passFtp,
      securityType: SecurityType.ftp,
      port: 21,
      showLog: true,
    );

    try {
      logger.Logger.i('Подключение к FTP серверу...');

      // Добавляем таймаут для подключения
      await ftpConnect.connect().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('FTP подключение превысило таймаут 10 секунд',
              const Duration(seconds: 10));
        },
      );
      logger.Logger.i('Успешное подключение к FTP!');

      // Преобразование данных в JSON
      final jsonData = jsonEncode(data);
      // Создание временного файла
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/$fileName');
      await tempFile.writeAsString(jsonData);

      ftpConnect.supportIPV6 = true;
      await ftpConnect.changeDirectory('user_app'); // Переход в папку user_app
      // Загрузка файла на FTP
      await ftpConnect.uploadFile(tempFile);
      logger.Logger.i('Файл успешно загружен на FTP!');

      await ftpConnect.disconnect();
      await tempFile.delete(); // Удаляем временный файл
      return ''; // Возвращаем пустую строку при успешном завершении
    } catch (e) {
      logger.Logger.e('Ошибка FTP подключения: $e');
      try {
        await ftpConnect.disconnect();
      } catch (_) {}
      return 'Ошибка подключения к серверу: $e';
    }
  }

  Future<void> uploadJsonFile(
      String fileName, Map<String, dynamic> jsonData) async {
    try {
      final ftpConnect = FTPConnect(
        hostFtp,
        user: loginFtp,
        pass: passFtp,
        securityType: SecurityType.ftp,
      );

      await ftpConnect.connect();

      // Создание временного файла
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/$fileName');
      await tempFile.writeAsString(jsonEncode(jsonData));

      ftpConnect.supportIPV6 = true;
      await ftpConnect.changeDirectory('user_app');

      // Создаем директорию routes, если её нет
      try {
        await ftpConnect.makeDirectory('routes');
      } catch (e) {
        logger.Logger.e('Ошибка при создании директории routes: $e');
      }

      await ftpConnect.changeDirectory('routes');
      await ftpConnect.uploadFile(tempFile);

      await ftpConnect.disconnect();
      await tempFile.delete();
    } catch (e) {
      logger.Logger.e('Ошибка при загрузке JSON файла: $e');
      rethrow;
    }
  }

  // Скачивание JSON файла с FTP
  Future<Map<String, dynamic>> downloadJsonFile(String fileName) async {
    try {
      final ftpConnect = FTPConnect(
        hostFtp,
        user: loginFtp,
        pass: passFtp,
        securityType: SecurityType.ftp,
      );

      await ftpConnect.connect();
      ftpConnect.supportIPV6 = true;
      await ftpConnect.changeDirectory('user_app');
      await ftpConnect.changeDirectory('routes');
      // Создаем временный файл
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/$fileName');
      await tempFile.create();

      // Скачиваем файл
      await ftpConnect.downloadFile(fileName, tempFile);
      final jsonString = await tempFile.readAsString();
      await tempFile.delete();

      await ftpConnect.disconnect();
      return jsonDecode(jsonString);
    } catch (e) {
      logger.Logger.e('Ошибка при скачивании JSON файла: $e');
      return {'error': 'Ошибка при скачивании JSON файла $fileName: $e'};
    }
  }
}
