# Сборка Android (AAB/APK) — ТД Время (`tdtime`)

**Slug:** `tdtime` (из `pubspec.yaml` → `name: tdtime`)  
**Package:** `com.hpace.tdtime`

## Релизный флоу (всегда в таком порядке)

1. Закоммитить все изменения по фичам/багфиксам (если ещё не в git).
2. **Поднять версию** в `pubspec.yaml`: `1.0.N+N` (и `versionName`, и `versionCode` после `+`).
3. Собрать **release APK** (или AAB для стора).
4. Скопировать артефакт в **`D:\Temp`** с именем `{slug}_1_{buildNumber}.apk`.
5. **Коммит** версии (и `.cursor`, если менялся чеклист).
6. **`git pull`** (если ветка отстаёт) → **`git push`**.

## Имя файла в D:\Temp

`tdtime_1_{buildNumber}.apk` или `tdtime_1_{buildNumber}.aab`

- `buildNumber` — число после `+` в `pubspec.yaml` (`1.0.31+31` → `31`)
- `1` — фиксированный префикс для единообразия в команде

Пример: `tdtime_1_31.apk`

## Подпись release

Сейчас в `android/app/build.gradle` release может быть на **debug**-ключе (см. `signingConfig = signingConfigs.debug`).  
Для стора настроить один раз:

1. `upload-keystore.jks` в `android/app/`
2. `android/key.properties` (не в git)
3. `signingConfigs.release` в Gradle

**Один keystore** для Google Play и RuStore.

## Сборка и копирование (PowerShell)

```powershell
cd D:\Projects\TDtime\tdtime
$slug = "tdtime"
# Подставить build из pubspec после +, например 31
$build = 31

# Если сборка падает на скачивании sqlite3 с GitHub — прекомпиляция в кэш hooks:
powershell -ExecutionPolicy Bypass -File tool\prefetch_sqlite_android.ps1

flutter pub get
flutter build apk --release --target-platform android-arm,android-arm64,android-x64
New-Item -ItemType Directory -Force -Path "D:\Temp" | Out-Null
Copy-Item -Force "build\app\outputs\flutter-apk\app-release.apk" "D:\Temp\${slug}_1_${build}.apk"
Get-Item "D:\Temp\${slug}_1_${build}.apk"
```

AAB (Google Play / RuStore):

```powershell
flutter build appbundle --release
Copy-Item -Force "build\app\outputs\bundle\release\app-release.aab" "D:\Temp\${slug}_1_${build}.aab"
Get-Item "D:\Temp\${slug}_1_${build}.aab"
```

## Перед загрузкой в стор

- [ ] `version` / `versionCode` выше предыдущей в консоли
- [ ] `applicationId` = `com.hpace.tdtime`
- [ ] Release подписан **release** keystore (когда настроен)
- [ ] APK лежит в `D:\Temp` с правильным именем

## Git после сборки

```powershell
git add pubspec.yaml
git commit -m "chore: версия 1.0.31+31, release APK"
git pull --rebase origin dev   # или merge, если принято в команде
git push origin dev
```

Коммит с кодом фич — **отдельно** от bump версии или одним коммитом по договорённости; версию в `pubspec.yaml` поднимать **перед** сборкой APK.
