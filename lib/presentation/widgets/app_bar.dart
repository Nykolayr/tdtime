import 'package:tdtime/presentation/screens/main/bloc/main_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../theme/theme.dart';

class AppBars extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool isBack;
  final bool isLeft;
  const AppBars(
      {Key? key, this.title = '', this.isBack = true, this.isLeft = false})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppBars> createState() => _AppBarsState();
}

class _AppBarsState extends State<AppBars> {
  @override
  Widget build(BuildContext context) {
    MainBloc bloc = Get.find<MainBloc>();
    return BlocBuilder<MainBloc, MainState>(
      bloc: bloc,
      builder: (context, state) => AppBar(
        elevation: 0,
        title: Text(widget.title, style: AppText.appTitle24),
        centerTitle: !widget.isLeft,
        automaticallyImplyLeading: false,
        leading: widget.isBack
            ? IconButton(
                iconSize: 32,
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColor.white,
                ),
                onPressed: () => Navigator.pop(context, false),
              )
            : null,
        backgroundColor: AppColor.blueFon,
      ),
    );
  }
}
