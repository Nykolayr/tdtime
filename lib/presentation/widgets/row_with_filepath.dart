import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/modal_edit_filepath.dart';

class RowWithFilePath extends StatelessWidget {
  final MainBloc mainBloc;
  const RowWithFilePath({
    Key? key,
    required this.mainBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
        bloc: mainBloc,
        builder: (context, state) {
          return Row(
            children: [
              const Text(
                'Файл загрузки:',
                style: AppText.text12,
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  state.filePath,
                  style: AppText.text12.copyWith(color: AppColor.yellow),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // const Spacer(),
              state.isFileExist
                  ? const Icon(Icons.check_circle,
                      color: Colors.green, size: 24)
                  : const Icon(Icons.error_outline,
                      color: Colors.red, size: 24),
              const Gap(8),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColor.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditFileNameModal(
                      mainBloc: mainBloc,
                      initialName: state.filePath.replaceAll('.json', ''),
                      onCheck: (String newName) {
                        String fileName = newName.endsWith('.json')
                            ? newName
                            : '$newName.json';
                        mainBloc
                            .add(LoadMarketCentersEvent(fileName: fileName));
                      },
                    ),
                  );
                },
              ),
            ],
          );
        });
  }
}
