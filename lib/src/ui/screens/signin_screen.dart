import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/widgets/choicepill.dart';
import 'package:restaurant_os_ai/src/ui/widgets/insights_panel.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';
import 'package:restaurant_os_ai/src/ui/widgets/surface_widget.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, required this.initialRole});

  final String initialRole;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late String _role = _normalizeRole(widget.initialRole);
  bool _otpSent = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = ref.watch(restaurantProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.go('/onboarding'),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
        title: Text(_roleTitle, style: Theme.of(context).textTheme.titleMedium),
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Surface(
                    child: Row(
                      children: [
                        Logo(initials: restaurant.logoInitials, size: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.appName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                _roleSubtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Continue as',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoicePill(
                        label: 'Customer',
                        icon: Iconsax.user,
                        selected: _role == 'customer',
                        onTap: () => setState(() {
                          _role = 'customer';
                          _otpSent = false;
                          _inputController.clear();
                          _otpController.clear();
                          _formKey.currentState?.reset();
                        }),
                      ),
                      ChoicePill(
                        label: 'Owner',
                        icon: Iconsax.shop,
                        selected: _role == 'owner',
                        onTap: () => setState(() {
                          _role = 'owner';
                          _otpSent = false;
                          _inputController.clear();
                          _otpController.clear();
                          _formKey.currentState?.reset();
                        }),
                      ),
                      ChoicePill(
                        label: 'Staff',
                        icon: Iconsax.profile_2user,
                        selected: _role == 'staff',
                        onTap: () => setState(() {
                          _role = 'staff';
                          _otpSent = false;
                          _inputController.clear();
                          _otpController.clear();
                          _formKey.currentState?.reset();
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _inputController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Iconsax.sms),
                      labelText: _role == 'customer'
                          ? 'Phone or email'
                          : 'Work email',
                      hintText: _role == 'customer'
                          ? '0300 0000000'
                          : 'owner@restaurant.com',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return _role == 'customer'
                            ? 'Please enter phone or email'
                            : 'Please enter work email';
                      }
                      final trimmed = value.trim();
                      if (_role == 'customer') {
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        final phoneRegex = RegExp(r'^[0-9+\-\s()]{7,15}$');
                        if (!emailRegex.hasMatch(trimmed) && !phoneRegex.hasMatch(trimmed)) {
                          return 'Please enter a valid phone or email';
                        }
                      } else {
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(trimmed)) {
                          return 'Please enter a valid email address';
                        }
                      }
                      return null;
                    },
                  ),
                  if (_otpSent) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Iconsax.password_check),
                        labelText: 'OTP code',
                        hintText: '123456',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter OTP code';
                        }
                        final trimmed = value.trim();
                        if (trimmed.length != 6 || int.tryParse(trimmed) == null) {
                          return 'OTP code must be 6 digits';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_otpSent) {
                          if (_formKey.currentState?.validate() ?? false) {
                            ref.read(userRoleProvider.notifier).setRole(
                                  _role == 'customer'
                                      ? UserRole.customer
                                      : (_role == 'owner'
                                          ? UserRole.owner
                                          : UserRole.staff),
                                );
                            context.go(
                              _role == 'customer'
                                  ? '/'
                                  : (_role == 'owner' ? '/dashboard' : '/workspace'),
                            );
                          }
                        } else {
                          if (_formKey.currentState?.validate() ?? false) {
                            setState(() => _otpSent = true);
                          }
                        }
                      },
                      icon: Icon(_otpSent ? Iconsax.login : Iconsax.send_2),
                      label: Text(_otpSent ? 'Continue' : 'Send OTP'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(userRoleProvider.notifier).setRole(
                              _role == 'customer'
                                  ? UserRole.customer
                                  : (_role == 'owner'
                                      ? UserRole.owner
                                      : UserRole.staff),
                            );
                        context.go(
                          _role == 'customer'
                              ? '/'
                              : (_role == 'owner' ? '/dashboard' : '/workspace'),
                        );
                      },
                      icon: Icon(
                        _role == 'customer'
                            ? Iconsax.shop
                            : Iconsax.cpu_setting,
                        color: primary,
                      ),
                      label: Text(
                        _role == 'customer'
                            ? 'Preview customer app'
                            : 'Preview operations',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _roleTitle {
    switch (_role) {
      case 'owner':
        return 'Owner sign in';
      case 'staff':
        return 'Staff sign in';
      case 'customer':
      default:
        return 'Customer sign in';
    }
  }

  String get _roleSubtitle {
    switch (_role) {
      case 'owner':
        return 'Manage brand, branches, menu, and orders.';
      case 'staff':
        return 'Access assigned kitchen, rider, or manager tools.';
      case 'customer':
      default:
        return 'Order from the branded mobile app.';
    }
  }
}

String _normalizeRole(String value) {
  if (value == 'owner' || value == 'staff') return value;
  return 'customer';
}

