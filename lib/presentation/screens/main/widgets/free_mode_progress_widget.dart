import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:tdtime/presentation/widgets/buttons.dart';

class FreeModeProgressWidget extends StatelessWidget {
  final int completedTT;
  final int unsentTT;
  final VoidCallback onViewHistory;
  final VoidCallback? onUploadAll;

  const FreeModeProgressWidget({
    super.key,
    required this.completedTT,
    required this.unsentTT,
    required this.onViewHistory,
    this.onUploadAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.blueFon2,
        borderRadius: AppDif.borderRadius10,
        border: Border.all(color: AppColor.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColor.yellow,
                size: 16,
              ),
              const Gap(8),
              Text(
                'Прогресс дня',
                style: AppText.medium12.copyWith(color: AppColor.white),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'Обработано: $completedTT торговых точек',
            style: AppText.text12.copyWith(color: AppColor.white),
          ),
          if (unsentTT > 0) ...[
            const Gap(4),
            Text(
              'Неотправлено: $unsentTT',
              style: AppText.text12.copyWith(color: Colors.red),
            ),
          ],
          const Gap(12),
          // Кнопка просмотра истории
          SizedBox(
            width: double.infinity,
            child: ButtonWide(
              text: 'Просмотр посещений',
              iconPath: 'assets/svg/reader.svg',
              onPressed: onViewHistory,
            ),
          ),
          // Кнопка отправки всех неотправленных сессий (если есть)
          if (unsentTT > 0 && onUploadAll != null) ...[
            const Gap(8),
            SizedBox(
              width: double.infinity,
              child: ButtonWide(
                text: 'Отправить все',
                iconPath: 'assets/svg/start.svg',
                onPressed: onUploadAll!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
