import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sorun_takip_sistemi/features/auth/controller/auth_controller.dart';

class MenuDrawer extends ConsumerWidget {
  const MenuDrawer({super.key});

  void navigateToCreateProject(BuildContext context) {
    Routemaster.of(context).push('/create-project');
  }

  void navigateToHome(BuildContext context) {
    Routemaster.of(context).push('/');
  }

  void navigateToNotifications(BuildContext context) {
    Routemaster.of(context).push('/notifications');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    return Drawer(
      child: SafeArea(
        child: ListView(children: [
          Column(
            children: [
              const Text.rich(
                TextSpan(children: [
                  WidgetSpan(
                    child: Icon(Icons.menu_open),
                  ),
                  TextSpan(
                    text: "Menü",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                ]),
              ),
              const SizedBox(height: 5),
              ListTile(
                title: const Text(
                  'Anasayfa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                leading: const Icon(Icons.home),
                onTap: () => navigateToHome(context),
              ),
              const SizedBox(height: 5),
              const Divider(),
              ListTile(
                title: const Text(
                  'Bildirimler',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                leading: const Icon(Icons.notifications),
                onTap: () => navigateToNotifications(context),
              ),
              const SizedBox(height: 5),
              const Divider(),
              ListTile(
                title: const Text(
                  'Proje Oluştur',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                leading: const Icon(Icons.add_circle),
                onTap: () => navigateToCreateProject(context),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
