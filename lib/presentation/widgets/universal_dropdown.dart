import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:gap/gap.dart';
import 'package:tdtime/domain/models/market_center.dart';
import 'package:tdtime/presentation/theme/theme.dart';

class UniversalDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T value;
  final ValueChanged<T?> onChanged;
  final String label;
  final String Function(T) itemToString;

  const UniversalDropdown({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.itemToString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value is MarketCenter) {
      for (var item in items) {
        print('item: ${(item as MarketCenter).toJson()}');
      }

      Logger.i(
          'items: ${items.length}   value: ${(value as MarketCenter).toJson()}');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.medium14),
        const Gap(10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemToString(item),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
