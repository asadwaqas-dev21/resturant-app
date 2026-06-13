import 'package:flutter/material.dart';
import 'package:restaurant_os_ai/src/ui/widgets/cart_panel.dart';
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CartPanel(isStandalone: true);
  }
}