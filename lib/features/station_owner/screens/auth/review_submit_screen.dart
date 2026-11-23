import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/owner_widgets.dart';

class ReviewSubmitScreen extends StatelessWidget {
  const ReviewSubmitScreen({
    super.key,
    required this.ownerName,
    required this.phone,
    required this.establishment,
    required this.city,
    required this.documentCount,
    required this.onSubmit,
  });

  final String ownerName;
  final String phone;
  final String establishment;
  final String city;
  final int documentCount;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('المراجعة والإرسال'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('راجع بيانات طلبك',
                    textAlign: TextAlign.right, style: AppTextStyles.h1),
                const SizedBox(height: 12),
                const Text('بيانات صاحب المحطة',
                    textAlign: TextAlign.right, style: AppTextStyles.body),
                const SizedBox(height: 12),
                OwnerCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('$ownerName · $phone',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 12),
                      Text('$establishment · $city',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 12),
                      Text('$documentCount وثائق مرفقة',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'بإرسال الطلب، ستتم مراجعة البيانات والوثائق من فريق EV YEMEN.',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 16),
                OwnerButton(
                  label: 'العودة للوثائق',
                  outlined: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: OwnerStickyAction(
          child: OwnerButton(label: 'إرسال الطلب', onPressed: onSubmit),
        ),
      );
}
