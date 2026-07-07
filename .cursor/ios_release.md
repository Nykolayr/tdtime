# Сборка iOS (App Store) — ТД Время (`tdtime`)

**Slug:** `tdtime`  
**Bundle ID:** `com.hpace.tdtime`  
**Team ID:** `T24GH9MPR8`  
**Display name:** ТД Время

## Релизный флоу (Xcode)

1. Закоммитить изменения по фичам/багфиксам (если ещё не в git).
2. **Поднять версию** в `pubspec.yaml`: `1.0.N+N` (например `1.0.33+33`).
3. Синхронизировать `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` в `ios/Runner.xcodeproj/project.pbxproj` (или полагаться на `FLUTTER_BUILD_*` из `pubspec`).
4. Подготовить зависимости и release-сборку Flutter (см. команды ниже).
5. **Archive** в Xcode → **Distribute App** → App Store Connect.
6. **Коммит** bump версии → `git push`.

## Подготовка (терминал)

```bash
cd /Users/nikolajryzov/Documents/tdtime/tdtime

# Если сборка падает на sqlite3 — прекомпиляция в tool/:
bash tool/prefetch_sqlite_ios.sh

flutter clean
flutter pub get
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
cd ios && pod install --repo-update && cd ..

# Release-сборка (без подписи — подпись в Xcode при Archive)
flutter build ios --release --no-codesign
```

## Archive в Xcode

1. Открыть workspace (не `.xcodeproj`):
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Схема **Runner**, устройство **Any iOS Device (arm64)**.
3. **Product → Archive**.
4. В Organizer: **Distribute App** → **App Store Connect** → **Upload**.
5. При вопросе про шифрование: **No** (в `Info.plist` уже `ITSAppUsesNonExemptEncryption = false`).

## CLI-альтернатива (без GUI)

После Archive через Xcode или `xcodebuild archive`:

```bash
xcodebuild -exportArchive \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath build/ios/ipa
```

## Перед загрузкой в App Store Connect

- [ ] `version` в `pubspec.yaml` выше предыдущей в App Store Connect
- [ ] `build number` (после `+`) уникален и выше предыдущего
- [ ] Bundle ID = `com.hpace.tdtime`
- [ ] Team = `T24GH9MPR8`, подпись Automatic
- [ ] Описания разрешений в `Info.plist` на русском
- [ ] `ITSAppUsesNonExemptEncryption` = `false`
- [ ] Скриншоты и метаданные обновлены в App Store Connect

## Git после сборки

```bash
git add pubspec.yaml ios/
git commit -m "chore: версия 1.0.33+33, release iOS"
git pull --rebase origin dev
git push origin dev
```

## Текущая версия

`pubspec.yaml`: **1.0.34+34**
