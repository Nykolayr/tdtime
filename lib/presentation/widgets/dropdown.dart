import 'package:tdtime/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class DropdownButtons extends StatefulWidget {
  final List<String> items;
  const DropdownButtons({required this.items, super.key});

  @override
  State<DropdownButtons> createState() => _DropdownButtonsState();
}

class _DropdownButtonsState extends State<DropdownButtons> {
  String? selectedRegion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.mediaQuerySize.width / 2 - 18,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      // ignore: prefer_const_constructors
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: AppDif.borderRadius10,
        // border: AppDif.borderRadius20,
      ),
      height: 41,
      child: DropdownButton<String>(
        hint: const Text(
          'Выбор региона',
          style: AppText.text14,
        ),
        icon: SvgPicture.asset(
          'assets/svg/down_arrow.svg',
          height: 8,
        ),
        iconSize: 24,
        isExpanded: true,
        style: AppText.text14,
        value: selectedRegion,
        onChanged: (String? newValue) {
          if (newValue != null) {
            selectedRegion = newValue;
            // bloc.add(SortDropEvent(item: selectedRegion!));
          } else {
            selectedRegion = null;
          }
          setState(() {});
        },
        underline: const SizedBox.shrink(),
        items: widget.items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item,
                style: AppText.text14, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ),
    );
  }
}
