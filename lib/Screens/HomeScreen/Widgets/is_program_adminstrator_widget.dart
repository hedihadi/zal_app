import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:sizer/sizer.dart';

class IsProgramAdminstratorWidget extends ConsumerWidget {
  const IsProgramAdminstratorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerSocket = ref.watch(socketProvider);

    return computerSocket.when(
        skipLoadingOnReload: true,
        data: (data) {
          if (data.cpu.clocks.containsValue(null) && data.cpu.temperature == null) {
            return Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                child: Column(
                  children: [
                    const Text("the program is not running as Adminstrator, some data will not be available."),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(socketObjectProvider.notifier).state!.sendData("restart_admin", "");
                      },
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text("restart program as adminstrator"),
                    ),
                  ],
                ),
              ),
            );
          }
          return Container();
        },
        error: (error, stackTrace) => Container(),
        loading: () => Container());
  }
}
