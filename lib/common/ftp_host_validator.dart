/// Проверка IPv4 или hostname для поля адреса FTP.
abstract final class FtpHostValidator {
  static String? errorMessage(String input) {
    final s = input.trim();
    if (s.isEmpty) {
      return 'Укажите адрес сервера';
    }
    if (_isIpv4(s) || _isHostname(s)) {
      return null;
    }
    return 'Некорректный IP или имя хоста';
  }

  static bool isValid(String input) => errorMessage(input) == null;

  static bool _isIpv4(String s) {
    final parts = s.split('.');
    if (parts.length != 4) {
      return false;
    }
    for (final p in parts) {
      if (p.isEmpty || p.length > 3) {
        return false;
      }
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) {
        return false;
      }
      if (p.length > 1 && p.startsWith('0')) {
        return false;
      }
    }
    return true;
  }

  static bool _isHostname(String s) {
    if (s.length > 253) {
      return false;
    }
    if (s.startsWith('.') || s.endsWith('.')) {
      return false;
    }
    if (s.contains('..')) {
      return false;
    }
    final labels = s.split('.');
    for (final label in labels) {
      if (label.isEmpty || label.length > 63) {
        return false;
      }
      if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(label)) {
        return false;
      }
      if (label.startsWith('-') || label.endsWith('-')) {
        return false;
      }
    }
    return labels.isNotEmpty;
  }
}
