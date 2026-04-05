import 'package:flutter/material.dart';
import 'package:frontend_mob/shared/widgets/shrimmer_card.dart';

class LoadingShimmerList extends StatelessWidget {
  final int itemCount;

  const LoadingShimmerList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const ShimmerCard(),
    );
  }
}
