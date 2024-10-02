import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:tdtime/common/utils.dart';
import 'package:tdtime/domain/models/user.dart';
import 'package:tdtime/domain/repository/user_repository.dart';
import 'package:tdtime/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/app_bar.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';
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
  bool isEdit = false;

  getUser() {
    User user = repo.user;
    nameController.text = user.name;
    familyController.text = user.family;
    idController.text = user.id;
    patronController.text = user.patron;
    setState(() {});
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
                    style: AppText.text14),
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
                const Gap(20),
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
                const Gap(35),
                ButtonWide(
                  text: 'Выйти из приложения',
                  iconPath: 'assets/svg/exit.svg',
                  onPressed: () {
                    repo.clearUser();
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
