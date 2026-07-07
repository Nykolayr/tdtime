import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tdtime/common/last_scan_log.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';

/// Просмотр лога последнего сканирования.
class ScanLogPage extends StatefulWidget {
  const ScanLogPage({super.key});

  @override
  State<ScanLogPage> createState() => _ScanLogPageState();
}

class _ScanLogPageState extends State<ScanLogPage> {
  String _text = LastScanLog.text;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await LastScanLog.load();
    if (mounted) {
      setState(() {
        _text = LastScanLog.text;
        _loading = false;
      });
    }
  }

  Future<void> _copy() async {
    if (_text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Лог скопирован'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _share() async {
    if (_text.isEmpty) return;
    await Share.share(_text, subject: 'ТД Время — лог сканирования');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.blueFon,
      appBar: const AppBars(
        title: 'Лог сканирования',
        isBack: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColor.white),
                  )
                : _text.isEmpty
                    ? Center(
                        child: Text(
                          'Логов пока нет.\nОткройте сканер и попробуйте снова.',
                          textAlign: TextAlign.center,
                          style: AppText.text14.copyWith(color: AppColor.white),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: SelectableText(
                          _text,
                          style: AppText.text12.copyWith(
                            color: AppColor.white,
                            fontFamily: 'monospace',
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              children: [
                ButtonWide(
                  text: 'Копировать',
                  iconPath: '',
                  opaqueBackground: true,
                  isEnable: _text.isNotEmpty,
                  onPressed: _copy,
                ),
                const Gap(12),
                ButtonWide(
                  text: 'Поделиться',
                  iconPath: '',
                  opaqueBackground: true,
                  isEnable: _text.isNotEmpty,
                  onPressed: _share,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
