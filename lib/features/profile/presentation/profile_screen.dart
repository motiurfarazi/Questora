import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/auth_screen.dart';
import '../providers/profile_provider.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'edit_profile_screen.dart';
import 'academic_info_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 54,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              profile?.fullName ?? user?.email ?? 'Guest User',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (profile?.institution != null || profile?.passingYear != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  [
                    if (profile?.institution != null &&
                        profile!.institution!.isNotEmpty)
                      profile.institution,
                    if (profile?.passingYear != null)
                      'Batch ${profile!.passingYear}',
                  ].join(' • '),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: AppColors.textPrimary,
                    ),
                    title: const Text(
                      'Edit Profile',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textPrimary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.school_outlined,
                      color: AppColors.textPrimary,
                    ),
                    title: const Text(
                      'Academic Information',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textPrimary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AcademicInfoScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textPrimary,
                    ),
                    title: const Text(
                      'Change Password',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textPrimary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.textPrimary,
                    ),
                    title: const Text(
                      'Settings',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textPrimary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.help_outline,
                      color: AppColors.textPrimary,
                    ),
                    title: const Text(
                      'Help & Support',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textPrimary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () async {
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
