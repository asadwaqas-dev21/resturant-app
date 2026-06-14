import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/domain/models.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
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
          SectionTitle(
            title: 'Menu control',
            trailing: IconButton(
              icon: const Icon(Iconsax.add_circle, color: AppColors.primary),
              tooltip: 'Add menu item',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const _AddMenuItemDialog(),
                );
              },
            ),
          ),
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

class _AddMenuItemDialog extends StatefulWidget {
  const _AddMenuItemDialog();

  @override
  State<_AddMenuItemDialog> createState() => _AddMenuItemDialogState();
}

class _AddMenuItemDialogState extends State<_AddMenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController(text: '12');
  final _caloriesController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedCategory = 'burgers';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _caloriesController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Menu Item'),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item name',
                    hintText: 'e.g. Cheese Fries',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price (AED)',
                    hintText: 'e.g. 15.00',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter price';
                    }
                    final price = double.tryParse(val.trim());
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'burgers', child: Text('Burgers')),
                    DropdownMenuItem(value: 'drinks', child: Text('Drinks')),
                    DropdownMenuItem(value: 'sides', child: Text('Sides')),
                    DropdownMenuItem(value: 'combos', child: Text('Combos')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'e.g. Crispy skin-on fries, cheese sauce...',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _prepTimeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Prep time (mins, optional)',
                    hintText: 'e.g. 12',
                  ),
                  validator: (val) {
                    if (val != null && val.trim().isNotEmpty) {
                      final time = int.tryParse(val.trim());
                      if (time == null || time <= 0) {
                        return 'Please enter a valid preparation time';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories (kcal, optional)',
                    hintText: 'e.g. 320',
                  ),
                  validator: (val) {
                    if (val != null && val.trim().isNotEmpty) {
                      final cals = int.tryParse(val.trim());
                      if (cals == null || cals <= 0) {
                        return 'Please enter a valid number of calories';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _imageUrlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                    hintText: 'e.g. https://images.unsplash.com/...',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        Consumer(
          builder: (context, ref, child) {
            return TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final newItem = MenuItem(
                    id: 'item-${DateTime.now().millisecondsSinceEpoch}',
                    categoryId: _selectedCategory,
                    name: _nameController.text.trim(),
                    description: _descriptionController.text.trim(),
                    basePrice: double.parse(_priceController.text.trim()),
                    preparationTimeMin:
                        int.tryParse(_prepTimeController.text.trim()) ?? 12,
                    imageUrl: _imageUrlController.text.trim().isNotEmpty
                        ? _imageUrlController.text.trim()
                        : 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=900&q=80',
                    totalOrders: 0,
                    averageRating: 5.0,
                    calories: int.tryParse(_caloriesController.text.trim()),
                  );
                  ref.read(menuProvider.notifier).addItem(newItem);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${newItem.name} added to menu!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            );
          },
        ),
      ],
    );
  }
}
