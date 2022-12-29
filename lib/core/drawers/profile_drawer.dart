import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/core/enums/enums.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';
import 'package:sorun_takip_sistemi/theme_provider.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void logOut({required WidgetRef ref, required BuildContext context}) {
    ref.read(authControllerProvider.notifier).logout(context: context);
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/users/$uid');
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
                radius: 70,
              ),
              const SizedBox(height: 10),
              Text(
                '${user.name} ${user.surname}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              ListTile(
                title: const Text('Profilim'),
                leading: const Icon(Icons.person),
                onTap: () => navigateToUserProfile(context, user.uid),
              ),
              ListTile(
                title: const Text('Çıkış Yap'),
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                onTap: () => logOut(ref: ref, context: context),
              ),
              Switch.adaptive(
                value: ref.watch(themeNotifierProvider.notifier).mode ==
                    ThemeModeEnum.light,
                onChanged: (val) {
                  toggleTheme(ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
