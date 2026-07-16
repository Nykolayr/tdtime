import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:tdtime/common/ftp_host_validator.dart';
import 'package:tdtime/data/api/api.dart';
import 'package:tdtime/domain/repository/ftp_config_repository.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';
import 'package:restart_app/restart_app.dart';

/// Шторка: FTP недоступен — можно продолжить offline.
Future<void> showFtpUnavailableSheet({
  required BuildContext context,
  required VoidCallback onGoToSettings,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColor.blueFon2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Нет связи с FTP',
              style: AppText.medium18.copyWith(color: AppColor.white),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Text(
              'Сейчас нет связи с сервером. Можно работать дальше: '
              'сканы сохраняются на устройстве и отправятся при связи. '
              'Маршруты — из локального кэша или свободный режим. '
              'Параметры FTP можно проверить в «Настройках».',
              style: AppText.text14.copyWith(
                color: AppColor.white.withValues(alpha: 0.9),
                height: 1.35,
              ),
            ),
            const Gap(24),
            ButtonWide(
              text: 'Продолжить работу',
              iconPath: '',
              opaqueBackground: true,
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            const Gap(12),
            ButtonWide(
              text: 'Открыть настройки FTP',
              iconPath: 'assets/svg/settings.svg',
              opaqueBackground: true,
              onPressed: () {
                Navigator.of(ctx).pop();
                onGoToSettings();
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showFtpSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: const _FtpSettingsSheetBody(),
      );
    },
  );
}

class _FtpSettingsSheetBody extends StatefulWidget {
  const _FtpSettingsSheetBody();

  @override
  State<_FtpSettingsSheetBody> createState() => _FtpSettingsSheetBodyState();
}

class _FtpSettingsSheetBodyState extends State<_FtpSettingsSheetBody> {
  final _hostCtrl = TextEditingController();
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _hostFocus = FocusNode();

  bool _loadingCheck = false;
  bool _verified = false;
  bool _obscurePassword = true;
  String? _hostError;
  String? _statusText;

  FtpConfigRepository get _repo => Get.find<FtpConfigRepository>();
  Api get _api => Get.find<Api>();

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _hostCtrl.addListener(_onFieldsChanged);
    _loginCtrl.addListener(_onFieldsChanged);
    _passCtrl.addListener(_onFieldsChanged);
  }

  Future<void> _loadInitial() async {
    final c = await _repo.getCredentials();
    if (!mounted) {
      return;
    }
    setState(() {
      _hostCtrl.text = c.host;
      _loginCtrl.text = c.login;
      _passCtrl.text = c.password;
    });
  }

  void _onFieldsChanged() {
    if (_hostError != null) {
      _hostError = null;
    }
    if (_verified) {
      _verified = false;
      _statusText = null;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _hostCtrl.removeListener(_onFieldsChanged);
    _loginCtrl.removeListener(_onFieldsChanged);
    _passCtrl.removeListener(_onFieldsChanged);
    _hostCtrl.dispose();
    _loginCtrl.dispose();
    _passCtrl.dispose();
    _hostFocus.dispose();
    super.dispose();
  }

  bool get _canCheck {
    final hostOk = FtpHostValidator.isValid(_hostCtrl.text);
    return hostOk &&
        _loginCtrl.text.trim().isNotEmpty &&
        _passCtrl.text.isNotEmpty;
  }

  void _unfocusSheet() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _pasteInto(TextEditingController c) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final t = data?.text;
    if (t == null || t.isEmpty) {
      return;
    }
    c.text = t.trim();
    setState(() {});
  }

  Future<void> _onCheck() async {
    _unfocusSheet();
    final err = FtpHostValidator.errorMessage(_hostCtrl.text);
    setState(() => _hostError = err);
    if (err != null) {
      return;
    }
    setState(() {
      _loadingCheck = true;
      _statusText = null;
    });
    final ok = await _api.testFtpConnection(
      _hostCtrl.text.trim(),
      _loginCtrl.text.trim(),
      _passCtrl.text,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _loadingCheck = false;
      _verified = ok;
      _statusText =
          ok ? 'Соединение проверено' : 'Не удалось подключиться к FTP';
    });
  }

  Future<void> _onBind() async {
    _unfocusSheet();
    if (!_verified) {
      return;
    }
    await _repo.saveCredentials(
      host: _hostCtrl.text.trim(),
      login: _loginCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await Restart.restartApp();
  }

  /// Крестик очистки + опционально второй суффикс (например «глаз» у пароля).
  Widget? _ftpFieldSuffix({
    required TextEditingController controller,
    Widget? trailing,
  }) {
    final hasText = controller.text.isNotEmpty;
    if (!hasText && trailing == null) {
      return null;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasText)
          IconButton(
            onPressed: () => controller.clear(),
            icon: const Icon(Icons.close, color: AppColor.white, size: 22),
            tooltip: 'Очистить',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _rowField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onPaste,
    FocusNode? focusNode,
    Widget? suffixIcon,
  }) {
    final suffix = _ftpFieldSuffix(controller: controller, trailing: suffixIcon);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppText.text12.copyWith(color: AppColor.white),
              ),
            ),
            IconButton(
              onPressed: onPaste,
              icon: const Icon(Icons.content_paste, color: AppColor.white, size: 22),
              tooltip: 'Вставить из буфера',
            ),
          ],
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          focusNode: focusNode,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: obscure ? '••••••••' : null,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.white),
            ),
            suffixIcon: suffix,
            suffixIconConstraints: suffix == null
                ? null
                : const BoxConstraints(minHeight: 40, minWidth: 0),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColor.blueFon2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(16),
            Text(
              'Настройки FTP',
              style: AppText.medium18.copyWith(color: AppColor.white),
              textAlign: TextAlign.center,
            ),
            const Gap(20),
            _rowField(
              label: 'Адрес сервера',
              controller: _hostCtrl,
              obscure: false,
              onPaste: () => _pasteInto(_hostCtrl),
              focusNode: _hostFocus,
            ),
            if (_hostError != null) ...[
              const Gap(6),
              Text(
                _hostError!,
                style: AppText.text12.copyWith(color: AppColor.redError),
              ),
            ],
            const Gap(14),
            _rowField(
              label: 'Логин',
              controller: _loginCtrl,
              obscure: false,
              onPaste: () => _pasteInto(_loginCtrl),
            ),
            const Gap(14),
            _rowField(
              label: 'Пароль',
              controller: _passCtrl,
              obscure: _obscurePassword,
              onPaste: () => _pasteInto(_passCtrl),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColor.white,
                  size: 22,
                ),
                tooltip:
                    _obscurePassword ? 'Показать пароль' : 'Скрыть пароль',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
            if (_statusText != null) ...[
              const Gap(16),
              Text(
                _statusText!,
                style: AppText.text14.copyWith(
                  color: _verified ? Colors.lightGreenAccent : AppColor.redError,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const Gap(20),
            if (_loadingCheck)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(color: AppColor.white),
                ),
              )
            else ...[
              ButtonWide(
                text: 'Проверить',
                iconPath: 'assets/svg/edit.svg',
                isEnable: _canCheck,
                onPressed: _onCheck,
              ),
              const Gap(12),
              ButtonWide(
                text: 'Привязать',
                iconPath: 'assets/svg/account.svg',
                isEnable: _verified,
                onPressed: _onBind,
              ),
            ],
            const Gap(8),
            TextButton(
              onPressed: () {
                _unfocusSheet();
                Navigator.of(context).pop();
              },
              child: Text(
                'Закрыть',
                style: AppText.text14.copyWith(color: AppColor.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
