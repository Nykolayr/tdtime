import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';

import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:tdtime/presentation/theme/theme.dart';

class EditFileNameModal extends StatefulWidget {
  final String initialName;
  final void Function(String) onCheck;
  final MainBloc mainBloc;

  const EditFileNameModal({
    super.key,
    required this.initialName,
    required this.onCheck,
    required this.mainBloc,
  });

  @override
  State<EditFileNameModal> createState() => _EditFileNameModalState();
}

class _EditFileNameModalState extends State<EditFileNameModal> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
        bloc: widget.mainBloc,
        buildWhen: (previous, current) {
          Logger.i('buildWhen ${previous.isFileExist} ${current.isFileExist}');
          if (previous.isFileExist != current.isFileExist &&
              current.isFileExist) {
            Navigator.of(context).pop();
          }
          return true;
        },
        builder: (context, state) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Изменить имя файла'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Имя файла (без .json)',
                  ),
                ),
                const Gap(10),
                if (!state.isFileExist)
                  Text(
                    'Файла не существует',
                    style: AppText.medium12.copyWith(color: AppColor.redError),
                  ),
                if (state.isFileExist)
                  Text(
                    'Файл существует',
                    style: AppText.medium12.copyWith(color: AppColor.green),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Закрыть'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    widget.onCheck(controller.text);
                  }
                },
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Проверить'),
              ),
            ],
          );
        });
  }
}
