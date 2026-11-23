import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

Widget stationImagePlaceholder() => Container(
      color: AppColors.mint,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_a_photo_outlined,
              color: AppColors.brand, size: 34),
          const SizedBox(height: 6),
          Text('أضف صورة للمحطة',
              style: AppTextStyles.caption.copyWith(color: AppColors.brand)),
        ],
      ),
    );
