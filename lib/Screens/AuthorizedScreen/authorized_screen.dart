import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:zal/Functions/interstitial_ad.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/AboutScreen/about_screen.dart';
import 'package:zal/Screens/AccountScreen/account_screen.dart';
import 'package:zal/Screens/AuthorizedScreen/Widgets/buy_premium_widget.dart';
import 'package:zal/Screens/CanRunGameScreen/can_run_game_screen.dart';
import 'package:zal/Screens/HomeScreen/home_screen.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Screens/SettingsScreen/settings_screen.dart';
import 'package:zal/Screens/TaskManagerScreen/task_manager_screen.dart';
import 'package:zal/Widgets/stress_test_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Functions/firebase_analytics_manager.dart';

final bottomNavigationbarIndexProvider = StateProvider((ref) => 0);

class AuthorizedScreen extends ConsumerWidget {
  AuthorizedScreen({super.key});
  final List<Widget> widgets = [
    const HomeScreen(),
    const CanRunGameScreen(),
    const AccountScreen(),
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(interstitialAdProvider);
    ref.read(screenViewProvider("authorized"));
    final index = ref.watch(bottomNavigationbarIndexProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Row(
          children: [
            ConnectionStateWidget(),
            PremiumButton(),
          ],
        ),
        actions: const [
          StressTestButton(),
          TaskmanagerButton(),
        ],
      ),
      body: widgets[index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.gamepad),
            label: 'Can i run it?',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user),
            label: 'Account',
          ),
        ],
        onTap: (value) => ref.read(bottomNavigationbarIndexProvider.notifier).state = value,
      ),
    );
  }
}

class ConnectionStateWidget extends ConsumerWidget {
  const ConnectionStateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(socketProvider);
    final isConnected = ref.watch(socketProvider.notifier).isConnected;
    final isComputerConnected = ref.watch(socketProvider.notifier).isComputerConnected;
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isConnected && isComputerConnected) ? Colors.green : Colors.red,
      ),
    );
  }
}

class AuthorizedDrawer extends StatelessWidget {
  const AuthorizedDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.w,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: TextButton.icon(
                onPressed: () {
                  launchUrl(Uri.parse("https://discord.gg/kfyZmqXjd6"), mode: LaunchMode.externalNonBrowserApplication);
                },
                icon: const Icon(FontAwesomeIcons.discord),
                label: const Text("Discord Server"),
              ),
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AboutScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumButton extends ConsumerWidget {
  const PremiumButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUserPremium = ref.watch(isUserPremiumProvider);
    if (isUserPremium) return Container();
    return IconButton(
        onPressed: () {
          Purchases.getOfferings().then((value) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => BuyPremiumWidget(offerings: value)));
          });
        },
        icon: const Icon(FontAwesomeIcons.crown));
  }
}

class TaskmanagerButton extends ConsumerWidget {
  const TaskmanagerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerSocket = ref.watch(socketProvider);
    if (ref.read(socketProvider.notifier).isProgramRunningAsAdminstrator) {
      return IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TaskManagerScreen()));
          },
          icon: const Icon(FontAwesomeIcons.list));
    }
    return Container();
  }
}
