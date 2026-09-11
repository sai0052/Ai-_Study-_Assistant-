import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

/// Shown once, right after registration, to collect academic details
/// (college + course) that personalize AI suggestions and campus features.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _collegeController = TextEditingController();
  final _courseController = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final user = ref.read(authStateChangesProvider).value;
    if (user != null) {
      await ref.read(authRepositoryProvider).updateProfile(
            uid: user.uid,
            collegeName: _collegeController.text.trim(),
            course: _courseController.text.trim(),
          );
    }

    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tell us about your studies', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('This helps the AI assistant tailor its suggestions to you.', style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSizes.xl),
                CustomTextField(
                  controller: _collegeController,
                  label: 'College / University',
                  validator: (v) => Validators.notEmpty(v, fieldName: 'College name'),
                  prefixIcon: const Icon(Icons.apartment_outlined),
                ),
                const SizedBox(height: AppSizes.md),
                CustomTextField(
                  controller: _courseController,
                  label: 'Course / Major',
                  validator: (v) => Validators.notEmpty(v, fieldName: 'Course'),
                  prefixIcon: const Icon(Icons.menu_book_outlined),
                ),
                const SizedBox(height: AppSizes.xl),
                CustomButton(label: 'Finish Setup', onPressed: _save, isLoading: _saving),
                TextButton(onPressed: () => context.go('/dashboard'), child: const Text('Skip for now')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
