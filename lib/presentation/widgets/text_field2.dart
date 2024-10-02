import 'package:tdtime/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BestFormField extends StatelessWidget {
  final String iconPath;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isCapitalization;
  final bool readOnly;

  const BestFormField(
      {super.key,
      required this.iconPath,
      required this.hint,
      required this.validator,
      this.keyboardType = TextInputType.text,
      this.isCapitalization = true,
      this.readOnly = false,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          textCapitalization: isCapitalization
              ? TextCapitalization.sentences
              : TextCapitalization.none,
          keyboardType: keyboardType,
          readOnly: readOnly,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
          controller: controller,
          decoration: InputDecoration(
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            prefixIcon: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(bottom: 1, top: 1, right: 10),
              child: SvgPicture.asset(iconPath, width: 24),
            ),
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.white),
            ),
          ),
        ));
  }
}
