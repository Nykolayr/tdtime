import 'dart:convert';
import 'dart:io';

import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tdtime/common/constants.dart';
import 'package:tdtime/data/api/dio_client.dart';
import 'package:get/get.dart';

class Api {
  final DioClient dio = Get.find<DioClient>();
  Future<String> uploadHystorySessionsToFtp(
      Map<String, dynamic> data, String fileName) async {
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
      print('ошибка ftpConnect $e');
      return e.toString(); // Возвращаем сообщение об ошибке
    }
  }
}
