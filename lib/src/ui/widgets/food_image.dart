import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';

class FoodImage extends StatelessWidget {
  const FoodImage({
    super.key,
    required this.url,
    this.height = 148,
    this.radius = 14,
  });

  final String url;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          height: height,
          color: AppColors.border.withValues(alpha: 0.45),
          alignment: Alignment.center,
          child: const Icon(Iconsax.gallery, color: AppColors.muted),
        ),
        errorWidget: (_, _, _) => Container(
          height: height,
          color: AppColors.border.withValues(alpha: 0.45),
          alignment: Alignment.center,
          child: const Icon(Iconsax.image, color: AppColors.muted),
        ),
      ),
    );
  }
}

