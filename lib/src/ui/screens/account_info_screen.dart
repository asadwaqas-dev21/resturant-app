import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:restaurant_os_ai/src/state/providers.dart';
import 'package:restaurant_os_ai/src/ui/app_colors.dart';

class AccountInfoScreen extends ConsumerStatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  ConsumerState<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends ConsumerState<AccountInfoScreen> {
  bool _isEditing = false;
  String _gender = 'Female';
  bool _receiveOffers = false;
  bool _subscribeNewsletter = false;

  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Retrieve customer state to prefill fields
    final customer = ref.read(customerProvider);
    final nameParts = customer.fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : 'Asad';
    final lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : 'Waqas';
    final email = customer.fullName.isNotEmpty
        ? '${customer.fullName.toLowerCase().replaceAll(' ', '')}@gmail.com'
        : 'asadkambo2021@gmail.com';

    _emailController = TextEditingController(text: email);
    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/settings'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                            color: Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF1E1E1E),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Account info',
                        style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Edit / Save Action Button
                  GestureDetector(
                    onTap: () {
                      if (_isEditing) {
                        // Save changes to profile name
                        final newFullName =
                            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
                        ref
                            .read(customerProvider.notifier)
                            .updateProfileName(newFullName);
                        setState(() {
                          _isEditing = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User saved!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        // Enter Edit mode
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        _isEditing ? 'Save' : 'Edit',
                        style: const TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Form Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Field
                    _buildEditableField(
                      label: 'Email',
                      controller: _emailController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),

                    // First Name
                    _buildEditableField(
                      label: 'First name',
                      controller: _firstNameController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Last Name
                    _buildEditableField(
                      label: 'Last name',
                      controller: _lastNameController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    _buildEditableField(
                      label: 'Phone number',
                      controller: _phoneController,
                      enabled: _isEditing,
                      suffixIcon: Iconsax.edit_2,
                    ),
                    const SizedBox(height: 16),

                    // Date of birth
                    _buildEditableField(
                      label: 'Date of birth (optional)',
                      controller: _dobController,
                      enabled: _isEditing,
                      suffixIcon: Iconsax.calendar,
                      readOnly: true,
                      onTap: _isEditing ? () => _selectDate(context) : null,
                    ),
                    const SizedBox(height: 24),

                    // Gender Section
                    const Text(
                      'Gender (optional)',
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildGenderRadio('Male'),
                        const SizedBox(width: 24),
                        _buildGenderRadio('Female'),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Offer Checkboxes
                    _buildCheckboxRow(
                      value: _receiveOffers,
                      label: 'Yes, I want to receive offers and discounts',
                      onChanged: (val) {
                        setState(() {
                          _receiveOffers = val ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCheckboxRow(
                      value: _subscribeNewsletter,
                      label: 'Subscribe to newsletter',
                      onChanged: (val) {
                        setState(() {
                          _subscribeNewsletter = val ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 36),

                    // Delete Account Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _confirmDeleteAccount(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E1E1E),
                          side: const BorderSide(
                            color: Color(0xFF1E1E1E),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Delete account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    IconData? suffixIcon,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(
        color: Color(0xFF1E1E1E),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        suffixIcon: suffixIcon != null
            ? (onTap != null
                  ? GestureDetector(
                      onTap: onTap,
                      child: Icon(
                        suffixIcon,
                        color: const Color(0xFF8E8E8E),
                        size: 20,
                      ),
                    )
                  : Icon(suffixIcon, color: const Color(0xFF8E8E8E), size: 20))
            : null,
      ),
    );
  }

  Widget _buildGenderRadio(String value) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = value;
        });
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFE0E0E0),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: isSelected
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF757575), // Grey/Black dot
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: value
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFE0E0E0),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
              color: value ? const Color(0xFF1E1E1E) : Colors.transparent,
            ),
            alignment: Alignment.center,
            child: value
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1E1E1E),
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E1E1E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Perform sign out and return to onboarding
              context.go('/onboarding');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
