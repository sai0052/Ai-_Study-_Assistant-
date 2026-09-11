import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit profile',
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null
                  ? Icon(Icons.person, size: 44, color: theme.colorScheme.primary)
                  : null,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Center(
            child: Text(
              user?.name.isNotEmpty == true ? user!.name : 'Student',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 2),
          Center(child: Text(user?.email ?? '', style: theme.textTheme.bodyMedium)),
          const SizedBox(height: AppSizes.xl),

          Text('Account Details', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: AppSizes.sm),
          Card(
            child: Column(
              children: [
                _DetailTile(icon: Icons.badge_outlined, label: 'Full Name', value: user?.name ?? 'Not set'),
                const Divider(height: 1),
                _DetailTile(icon: Icons.email_outlined, label: 'Email', value: user?.email ?? 'Not set'),
                const Divider(height: 1),
                _DetailTile(
                  icon: Icons.apartment_outlined,
                  label: 'College / University',
                  value: (user?.collegeName?.isNotEmpty == true) ? user!.collegeName! : 'Not set',
                ),
                const Divider(height: 1),
                _DetailTile(
                  icon: Icons.menu_book_outlined,
                  label: 'Course / Major',
                  value: (user?.course?.isNotEmpty == true) ? user!.course! : 'Not set',
                ),
                const Divider(height: 1),
                _DetailTile(icon: Icons.fingerprint, label: 'User ID', value: user?.uid ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),

          CustomButton(
            label: 'Edit Profile',
            icon: Icons.edit_outlined,
            outlined: true,
            onPressed: () => context.push('/profile/edit'),
          ),
          const SizedBox(height: AppSizes.md),

          CustomButton(
            label: 'Sign Out',
            outlined: true,
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
      subtitle: Text(value, style: theme.textTheme.bodyLarge),
    );
  }
}