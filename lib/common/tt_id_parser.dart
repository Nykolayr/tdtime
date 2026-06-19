import 'package:tdtime/domain/models/market_center.dart';

/// Разбор и сопоставление идентификаторов торговых точек (УТ-…).
class TtIdParser {
  static final RegExp _ttIdPattern = RegExp(
    r'(?:УТ|UT)-\s*(\d+)',
    caseSensitive: false,
  );

  /// Извлекает номер ТТ из сырой строки QR/ввода. Возвращает `УТ-` + цифры как в коде.
  static String? parse(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final match = _ttIdPattern.firstMatch(trimmed.toUpperCase());
    if (match == null) return null;

    final digits = match.group(1)!;
    return 'УТ-$digits';
  }

  /// Ищет ТТ в списке по id или по распознанному из строки коду.
  static MarketCenter? findInList(List<MarketCenter> list, String rawOrId) {
    final parsed = parse(rawOrId);
    if (parsed == null) return null;

    for (final mc in list) {
      if (idsMatch(mc.id, parsed)) return mc;
    }
    return null;
  }

  /// Сравнивает два идентификатора ТТ (с учётом ведущих нулей в номере).
  static bool idsMatch(String a, String b) {
    final pa = parse(a) ?? a.trim().toUpperCase();
    final pb = parse(b) ?? b.trim().toUpperCase();
    if (pa == pb) return true;

    final na = _numericPart(pa);
    final nb = _numericPart(pb);
    if (na != null && nb != null && na == nb) {
      return pa.startsWith('УТ') && pb.startsWith('УТ');
    }
    return false;
  }

  static String? _numericPart(String id) {
    final match = RegExp(r'(\d+)$').firstMatch(id);
    return match?.group(1);
  }
}
