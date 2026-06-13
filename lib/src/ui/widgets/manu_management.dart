import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/theme.dart';
import 'package:restaurant_os_ai/src/ui/widgets/choicepill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/section_title.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class MenuManagement extends ConsumerWidget {
  const MenuManagement({super.key, required this.menu});

  final List<MenuItem> menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Menu control'),
          const SizedBox(height: 12),
          for (final item in menu) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        money(item.price),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                ChoicePill(
                  label: item.isAvailable ? 'Online' : 'Paused',
                  selected: item.isAvailable,
                  onTap: () => ref
                      .read(menuProvider.notifier)
                      .toggleAvailability(item.id),
                  compact: true,
                  icon: item.isAvailable
                      ? Iconsax.tick_circle
                      : Iconsax.close_circle,
                ),
              ],
            ),
            if (item != menu.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}
