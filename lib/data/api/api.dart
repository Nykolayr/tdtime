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
    return '';
    final jsonData = jsonEncode(data);
    logger.Logger.i('data == $jsonData');
    logger.Logger.i('fileName == $fileName');
    final ftpConnect = FTPConnect(
      hostFtp,
      user: loginFtp,
      pass: passFtp,
      securityType: SecurityType.FTP,
      // showLog: true,
    );
    try {
      await ftpConnect.connect();

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

      await ftpConnect.disconnect();
      await tempFile.delete(); // Удаляем временный файл
      return ''; // Возвращаем пустую строку при успешном завершении
    } catch (e) {
      logger.Logger.e('ошибка ftpConnect $e');
      return e.toString(); // Возвращаем сообщение об ошибке
    }
  }

  Future<void> uploadJsonFile(
      String fileName, Map<String, dynamic> jsonData) async {
    try {
      final ftpConnect = FTPConnect(
        hostFtp,
        user: loginFtp,
        pass: passFtp,
        securityType: SecurityType.FTP,
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
        securityType: SecurityType.FTP,
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
