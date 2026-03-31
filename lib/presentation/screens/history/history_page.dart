import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:tdtime/domain/models/session.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:tdtime/presentation/screens/main/widget.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  MainBloc bloc = Get.find<MainBloc>();

  @override
  void initState() {
    super.initState();
    // Загружаем неотправленные сессии при инициализации
    bloc.add(LoadUnsentSessionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColor.blueFon,
      appBar: const AppBars(
        title: 'ТТ которые уже посетили',
        isBack: true,
        isLeft: true,
      ),
      body: BlocBuilder<MainBloc, MainState>(
        bloc: bloc,
        buildWhen: (previous, current) {
          // Обновляем UI при изменении неотправленных сессий
          return previous.unsentSessions != current.unsentSessions ||
              previous.hasUnsentSessions != current.hasUnsentSessions ||
              previous.dayHystorySession.listSessions.length !=
                  current.dayHystorySession.listSessions.length;
        },
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Stack(
              children: [
                // Список сессий
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 100),
                  child: _buildSessionsList(state),
                ),
                // Кнопка отправки внизу (если есть неотправленные)
                _buildUploadButton(state),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Список сессий
  Widget _buildSessionsList(MainState state) {
    if (state.dayHystorySession.listSessions.isEmpty) {
      return const Center(
        child: Text(
          'Нет посещений',
          style: AppText.medium14,
        ),
      );
    }

    return ListView.builder(
      itemCount: state.dayHystorySession.listSessions.length,
      itemBuilder: (context, index) {
        SessionScan session = state.dayHystorySession.listSessions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ItemSession(item: session),
        );
      },
    );
  }

  /// Кнопка отправки неотправленных сессий
  Widget _buildUploadButton(MainState state) {
    // Проверяем, есть ли неотправленные сессии
    int totalUnsent = 0;
    for (var sessions in state.unsentSessions.values) {
      totalUnsent += sessions.length;
    }

    Logger.i(
        '_buildUploadButton: totalUnsent = $totalUnsent, hasUnsentSessions = ${state.hasUnsentSessions}');

    // Показываем кнопку только если есть неотправленные сессии
    if (totalUnsent == 0) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: ButtonWide(
        text: 'Отправить все',
        iconPath: 'assets/svg/start.svg',
        onPressed: () async {
          // Показываем диалог подтверждения
          bool? shouldUpload = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Отправка сессий'),
              content: const Text(
                  'Вы уверены, что хотите отправить все неотправленные сессии?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Отправить'),
                ),
              ],
            ),
          );

          if (shouldUpload == true) {
            bloc.add(ForceUploadAllSessionsEvent());
          }
        },
      ),
    );
  }
}
