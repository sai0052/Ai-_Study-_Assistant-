import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _collegeController;
  late final TextEditingController _courseController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateChangesProvider).value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _collegeController = TextEditingController(text: user?.collegeName ?? '');
    _courseController = TextEditingController(text: user?.course ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    setState(() => _saving = true);
    final result = await ref.read(authRepositoryProvider).updateProfile(
      uid: user.uid,
      name: _nameController.text.trim(),
      collegeName: _collegeController.text.trim(),
      course: _courseController.text.trim(),
    );
    setState(() => _saving = false);

    result.fold(
          (failure) {
        if (mounted) SnackbarHelper.showError(context, failure.message);
      },
          (_) {
        if (mounted) {
          SnackbarHelper.showSuccess(context, 'Profile updated');
          context.pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Full name',
                validator: (v) => Validators.notEmpty(v, fieldName: 'Name'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: AppSizes.md),
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
              CustomButton(label: 'Save Changes', onPressed: _save, isLoading: _saving),
            ],
          ),
        ),
      ),
    );
  }
}