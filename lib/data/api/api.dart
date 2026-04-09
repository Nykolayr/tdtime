import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ftpconnect/ftpconnect.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tdtime/domain/repository/ftp_config_repository.dart';

import 'package:flutter_easylogger/flutter_logger.dart' as logger;

class Api {
  Future<FtpCredentials> _credentials() async {
    return Get.find<FtpConfigRepository>().getCredentials();
  }

  /// Проверка подключения к FTP (порт 21, без шифрования), без смены каталога.
  Future<bool> testFtpConnection(String host, String login, String password) async {
    final ftpConnect = FTPConnect(
      host.trim(),
      user: login.trim(),
      pass: password,
      securityType: SecurityType.ftp,
      port: 21,
      showLog: false,
    );
    try {
      await ftpConnect.connect().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'FTP подключение превысило таймаут 10 секунд',
            const Duration(seconds: 10),
          );
        },
      );
      await ftpConnect.disconnect();
      return true;
    } catch (e) {
      logger.Logger.e('testFtpConnection: $e');
      try {
        await ftpConnect.disconnect();
      } catch (_) {}
      return false;
    }
  }

  /// выгрузка сессии
  Future<String> uploadHystorySessionsToFtp(
      Map<String, dynamic> data, String fileName) async {
    final jsonData = jsonEncode(data);
    final c = await _credentials();
    logger.Logger.i('data == $jsonData');
    logger.Logger.i('fileName == $fileName');
    logger.Logger.i('Подключение к FTP: ${c.host} с пользователем ${c.login}');

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

    final ftpConnect = FTPConnect(
      c.host,
      user: c.login,
      pass: c.password,
      securityType: SecurityType.ftp,
      port: 21,
      showLog: true,
    );

    try {
      logger.Logger.i('Подключение к FTP серверу...');

      await ftpConnect.connect().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('FTP подключение превысило таймаут 10 секунд',
              const Duration(seconds: 10));
        },
      );
      logger.Logger.i('Успешное подключение к FTP!');

      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/$fileName');
      await tempFile.writeAsString(jsonEncode(data));

      ftpConnect.supportIPV6 = true;
      await ftpConnect.changeDirectory('user_app');
      await ftpConnect.uploadFile(tempFile);
      logger.Logger.i('Файл успешно загружен на FTP!');

      await ftpConnect.disconnect();
      await tempFile.delete();
      return '';
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
    final c = await _credentials();
    try {
      final ftpConnect = FTPConnect(
        c.host,
        user: c.login,
        pass: c.password,
        securityType: SecurityType.ftp,
      );

      await ftpConnect.connect();

      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/$fileName');
      await tempFile.writeAsString(jsonEncode(jsonData));

      ftpConnect.supportIPV6 = true;
      await ftpConnect.changeDirectory('user_app');

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

  Future<Map<String, dynamic>> downloadJsonFile(String fileName) async {
    final c = await _credentials();
    try {
      final ftpConnect = FTPConnect(
        c.host,
        user: c.login,
        pass: c.password,
        securityType: SecurityType.ftp,
      );

      await ftpConnect.connect();
      ftpConnect.supportIPV6 = true;
      await ftpConnect.changeDirectory('user_app');
      await ftpConnect.changeDirectory('routes');
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/$fileName');
      await tempFile.create();

      await ftpConnect.downloadFile(fileName, tempFile);
      final jsonString = await tempFile.readAsString();
      await tempFile.delete();

      await ftpConnect.disconnect();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      logger.Logger.e('Ошибка при скачивании JSON файла: $e');
      return {'error': 'Ошибка при скачивании JSON файла $fileName: $e'};
    }
  }
}
