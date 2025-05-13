import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tdtime/common/utils.dart';
import 'package:tdtime/domain/models/user.dart';
import 'package:tdtime/domain/repository/user_repository.dart';
import 'package:tdtime/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:tdtime/presentation/screens/scan/qr_code_scan.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';
import 'package:tdtime/presentation/widgets/row_with_filepath.dart';
import 'package:tdtime/presentation/widgets/text_field2.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  UserRepository repo = Get.find<UserRepository>();
  final nameController = TextEditingController();
  final familyController = TextEditingController();
  final idController = TextEditingController();
  final patronController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  AuthBloc bloc = Get.find<AuthBloc>();
  MainBloc mainBloc = Get.find<MainBloc>();
  bool isEdit = false;
  String error = '';
  late Barcode result;
  late User user;

  getUser() {
    user = repo.user;
    nameController.text = user.name;
    familyController.text = user.family;
    patronController.text = user.patron;
    idController.text = user.id;
    setState(() {});
  }

  void startScanning() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ScanScreen(onScan: (Barcode scanResult) {
                result = scanResult;
              })),
    );
    if (!mounted) return;
    setState(() {
      if (result.code == null) {
        error = 'Ошибка сканирования';
      } else {
        List<String> fio = result.code!.split(' ');
        if (fio.length != 3) {
          error = 'Отсканированные данные не соответсвуют формату';
        } else {
          isEdit = true;
          nameController.text = fio[1];
          familyController.text = fio[0];
          patronController.text = fio[2];
        }
        setState(() {});
      }
    });

    await Future.delayed(const Duration(seconds: 8));
    setState(() {
      error = '';
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  void dispose() {
    nameController.dispose();
    familyController.dispose();
    idController.dispose();
    patronController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: AppColor.blueFon,
      appBar: const AppBars(
        title: 'Настройки',
        isBack: false,
        isLeft: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height - 80,
        width: MediaQuery.of(context).size.width,
        color: AppColor.blueFon,
        padding: const EdgeInsets.only(
          left: 25,
          right: 25,
          top: 100,
          bottom: 15,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                    'Будьте бдительны при заполнении данных! В случае, если у вас возникли проблемы при эксплуатации данного приложения —пожалуйста, уведомите об этом старшего сотрудника, для скорейшего устранения выявляенных проблем.',
                    style: AppText.text10),
                const Gap(15),
                BestFormField(
                  iconPath: 'assets/svg/account.svg',
                  hint: 'Фамилия',
                  controller: familyController,
                  validator: (value) =>
                      Utils.validateNotEmpty(value, 'Укажите Фамилию'),
                  keyboardType: TextInputType.name,
                  readOnly: !isEdit,
                ),
                BestFormField(
                  iconPath: 'assets/svg/account.svg',
                  hint: 'Имя',
                  controller: nameController,
                  validator: (value) =>
                      Utils.validateNotEmpty(value, 'Укажите имя'),
                  keyboardType: TextInputType.name,
                  readOnly: !isEdit,
                ),
                BestFormField(
                  iconPath: 'assets/svg/account.svg',
                  hint: 'Отчество',
                  controller: patronController,
                  validator: (value) =>
                      Utils.validateNotEmpty(value, 'Укажите отчество'),
                  keyboardType: TextInputType.name,
                  readOnly: !isEdit,
                ),
                BestFormField(
                  iconPath: 'assets/svg/account.svg',
                  hint: 'ID агента',
                  controller: idController,
                  validator: (value) =>
                      Utils.validateNotEmpty(value, 'Укажите ID агента'),
                  keyboardType: TextInputType.name,
                  isCapitalization: false,
                  readOnly: !isEdit,
                ),
                const Gap(8),
                RowWithFilePath(mainBloc: mainBloc),
                if (error.isNotEmpty)
                  Container(
                    height: 45,
                    width: double.infinity,
                    alignment: Alignment.topCenter,
                    child: Text(
                      error,
                      style: AppText.medium14.copyWith(
                        color: AppColor.redError,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  const Gap(45),
                ButtonWide(
                    text: isEdit ? 'Сохранить данные' : 'Редактировать данные',
                    iconPath: 'assets/svg/edit.svg',
                    onPressed: () {
                      if (isEdit) {
                        if (formKey.currentState!.validate()) {
                          bloc.add(AuthUserEvent(
                            name: nameController.text,
                            family: familyController.text,
                            patron: patronController.text,
                            id: idController.text,
                          ));
                          isEdit = false;
                          setState(() {});
                        }
                      } else {
                        isEdit = true;
                        setState(() {});
                      }
                    }),
                const Gap(20),
                ButtonWide(
                  text: 'Сканировать данные',
                  iconPath: 'assets/svg/reader.svg',
                  onPressed: () => startScanning(),
                ),
                const Gap(20),
                ButtonWide(
                  text: 'Выйти из приложения',
                  iconPath: 'assets/svg/exit.svg',
                  onPressed: () {
                    mainBloc.add(ExitUserEvent());
                    context.go('/splash');
                  },
                ),
                const Gap(20),
                ButtonWide(
                  text: 'Удалить аккаунт',
                  iconPath: 'assets/svg/trash.svg',
                  onPressed: () {
                    mainBloc.add(ExitUserEvent());
                    context.go('/splash');
                  },
                ),
                const Gap(35),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditFileNameModal extends StatefulWidget {
  final String initialName;
  final void Function(String) onCheck;

  const EditFileNameModal({
    Key? key,
    required this.initialName,
    required this.onCheck,
  }) : super(key: key);

  @override
  State<EditFileNameModal> createState() => _EditFileNameModalState();
}

class _EditFileNameModalState extends State<EditFileNameModal> {
  late TextEditingController controller;
  bool isLoading = false;

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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Изменить имя файла'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Имя файла (без .json)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  setState(() => isLoading = true);
                  widget.onCheck(controller.text);
                },
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Проверить'),
        ),
      ],
    );
  }
}
