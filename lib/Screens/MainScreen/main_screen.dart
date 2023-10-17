import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/AuthorizedScreen/authorized_screen.dart';
import 'package:zal/Screens/LoginScreen/login_providers.dart';
import 'package:zal/Screens/LoginScreen/main_login_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth.hasValue == false) {
      return Container();
    }
    if (auth.value == null) return const MainLoginScreen();
    {
      return AuthorizedScreen();
    }
  }
}
