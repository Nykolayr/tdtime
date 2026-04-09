import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tdtime/common/constants.dart';

/// Учётные данные FTP: из secure storage или значения по умолчанию из [constants.dart].
class FtpCredentials {
  final String host;
  final String login;
  final String password;

  const FtpCredentials({
    required this.host,
    required this.login,
    required this.password,
  });
}

class FtpConfigRepository {
  FtpConfigRepository({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const _keyHost = 'ftp_host';
  static const _keyLogin = 'ftp_login';
  static const _keyPass = 'ftp_password';

  Future<FtpCredentials> getCredentials() async {
    final h = await _storage.read(key: _keyHost);
    final l = await _storage.read(key: _keyLogin);
    final p = await _storage.read(key: _keyPass);
    return FtpCredentials(
      host: (h != null && h.isNotEmpty) ? h : hostFtp,
      login: (l != null && l.isNotEmpty) ? l : loginFtp,
      password: (p != null && p.isNotEmpty) ? p : passFtp,
    );
  }

  /// Только хост для отображения в профиле (текущий эффективный).
  Future<String> getDisplayHost() async {
    final c = await getCredentials();
    return c.host;
  }

  Future<void> saveCredentials({
    required String host,
    required String login,
    required String password,
  }) async {
    await _storage.write(key: _keyHost, value: host.trim());
    await _storage.write(key: _keyLogin, value: login.trim());
    await _storage.write(key: _keyPass, value: password);
  }
}
