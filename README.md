# ТД Время (`tdtime`)

Мобильное приложение для полевых сотрудников **ТД Время**: сканирование торговых точек (QR), кодов DataMatrix / PDF417, работа с маршрутами, offline-сохранение и выгрузка сессий на FTP.

| | |
|---|---|
| **Package** | `com.hpace.tdtime` |
| **Платформы** | Android, iOS |
| **Стек** | Flutter, flutter_bloc, GetIt/Get, go_router, Drift/SQLite, Dio, mobile_scanner |
| **Версия** | см. `pubspec.yaml` (`version: x.y.z+build`) |
| **Репозиторий** | https://github.com/HPACE-IT-development/tdtime-app |

---

## Возможности

- Авторизация / старт смены
- Режим **маршрутов** (список ТТ с FTP) и **свободный режим**
- Скан **QR торговой точки** на главной
- На экране ТТ: **DataMatrix**, **PDF417**, **Port Matrix** (Bluetooth)
- Локальное хранение истории посещений (Drift)
- Выгрузка сессий на **FTP** (offline-first: без сети работа не блокируется)
- Настройки FTP, лог последнего сканирования (диагностика камеры)
- История и повторная отправка неотправленных визитов

---

## Структура проекта

```
lib/
  common/           # утилиты, парсер ID ТТ, лог скана, константы
  data/
    api/            # FTP / HTTP клиент
    drift/          # локальная БД истории
    local_data.dart
  domain/
    models/         # Session, User, маршруты
    repository/     # User, Routers, FTP config, Port Matrix
    routers/        # go_router
    injects.dart    # DI при старте
  presentation/
    screens/        # splash, auth, main, session, scan, history
    widgets/
    theme/
android/            # Gradle, манифест, подпись release
ios/                # Xcode, Info.plist, AppIcon
.cursor/            # чеклисты релиза, правила агента
```

---

## Требования

- Flutter **≥ 3.41.6** (см. `pubspec.yaml` → `environment.flutter`)
- Dart **≥ 3.11.4**
- Android Studio / Xcode (для нативных сборок)
- Для iOS: Mac + CocoaPods

```bash
flutter --version
flutter doctor
```

---

## Быстрый старт

```bash
git clone https://github.com/HPACE-IT-development/tdtime-app.git
cd tdtime-app
git checkout nykolay   # или своя ветка разработчика
flutter pub get
```

### Android

```bash
flutter run
# или release:
flutter build apk --release
```

Release-подпись: `android/key.properties` + `upload-keystore.jks` (не в git).  
Подробности: `.cursor/android_release.md`.

### iOS (Mac)

```bash
cd ios && pod install && cd ..
flutter build ipa
# или Archive в Xcode: ios/Runner.xcworkspace
```

Подробности: `.cursor/ios_release.md`.

---

## Ветки и командная работа

| Ветка | Назначение |
|--------|------------|
| `main` | Основная стабильная копия проекта (полная база) |
| `nykolay` | Ветка разработчика Николая |
| *(другие)* | Ветки других разработчиков |

### Правило перед любой задачей (обязательно)

1. **Сначала** посмотреть чужие ветки на remote (`git fetch --all`).
2. Если у коллег есть новые коммиты — **влить (merge)** их в свою рабочую ветку (или подтянуть изменения с `main`, если туда уже смержили).
3. **Только после этого** приступать к своей задаче.
4. Не пушить force в `main`. Свою ветку держать отдельно, в `main` — через PR / согласованный merge.

Краткий ритуал в начале дня / сессии:

```bash
git fetch --all
git branch -r
# пример: влить изменения коллеги
git merge origin/<ветка_коллеги>
# или обновиться от main:
git merge origin/main
```

То же правило зафиксировано для Cursor-агента: `.cursor/rules/git-workflow.mdc`.

---

## Версионирование и релизы

Формат в `pubspec.yaml`: `1.0.N+N` (name + build number).

Перед релизом:

1. Закоммитить фичи/фиксы
2. Поднять версию
3. Собрать APK/AAB или IPA
4. Запушить ветку

Артефакты Android для тестов: `D:\Temp\tdtime_1_{build}.apk` (см. `.cursor/android_release.md`).

---

## Offline и FTP

- Закрытие ТТ **сначала локально**, FTP — best-effort (таймаут).
- Нет сети / FTP не должен блокировать выход с экрана ТТ и закрытие рабочего дня.
- На FTP **не уходят** файлы с пустым `DataMatrix`.
- Уже лежащие на сервере «пустые» JSON (`"DataMatrix": []`) — артефакты старых сборок; на сервере можно почистить разово.

Типичный payload сессии:

```json
{
  "FIO": "...",
  "ID": "...",
  "TT_INFO": {
    "ID_TT": "...",
    "GPRS": "lat,lng",
    "DATE_TIME": "дд.мм.гггг чч:мм",
    "DataMatrix": ["..."]
  }
}
```

Имя файла: `{ID_TT}_{timestamp}.json` → каталог FTP `user_app/`.

---

## Безопасность

**Не коммитить:**

- `.env`, секреты, пароли FTP в коде
- `android/key.properties`, `*.jks`, сертификаты
- персональные данные пользователей из локальной БД

FTP-учётки хранятся в secure storage / настройках приложения.

---

## Полезные команды

```bash
flutter pub get
dart analyze
flutter test
flutter build apk --release
flutter build appbundle --release
flutter build ipa
```

---

## Контакты / организация

Репозиторий команды: **HPACE IT development**  
Приложение: **ТД Время** / `tdtime`
