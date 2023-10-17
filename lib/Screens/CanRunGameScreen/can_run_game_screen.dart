import 'dart:async';
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Screens/CanRunGameScreen/Widgets/search_game_widget.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:sizer/sizer.dart';

import '../../Functions/firebase_analytics_manager.dart';

final isStreamLoadingProvider = StateProvider.autoDispose((ref) => false);

final streamProvider = StreamProvider.autoDispose<dynamic>((ref) async* {
  StreamController stream = StreamController();
  final socket = ref.watch(socketObjectProvider);
  socket!.socket.on('can_run_game_response', (data) {
    stream.add(data);
  });

  await for (final value in stream.stream) {
    if (value != null) {
      yield value;
      ref.read(isStreamLoadingProvider.notifier).state = false;
    }
  }
});

class CanRunGameScreen extends ConsumerWidget {
  const CanRunGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socket = ref.watch(socketProvider);
    ref.read(screenViewProvider("can-run-game"));
    return socket.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: (data) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
          child: ListView(
            children: [
              SizedBox(height: 2.h),
              const SearchGameWidget(),
              const ProceedButton(),
              const ResultTextWidget(),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        return Container();
      },
      loading: () => const CircularProgressIndicator(),
    );
  }
}

class ProceedButton extends ConsumerWidget {
  const ProceedButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGame = ref.watch(selectedGameProvider);
    final isStreamLoading = ref.watch(isStreamLoadingProvider);

    return selectedGame == null
        ? Container()
        : ElevatedButton(
            onPressed: () {
              final data = ref.read(socketProvider).value!;
              ref.invalidate(streamProvider);

              ref.read(socketObjectProvider.notifier).state!.sendData(
                  'can_i_run_game',
                  jsonEncode([
                    selectedGame,
                    'gpu:${data.gpu.name}, cpu: ${data.cpu.name}, ram: ${(data.ram.memoryAvailable + data.ram.memoryUsed).toSize(decimals: 0)}'
                  ]));
              ref.read(isStreamLoadingProvider.notifier).state = true;
              AnalyticsManager.logEvent("can-run-game", options: {'game': selectedGame});
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: isStreamLoading ? const CircularProgressIndicator() : const Text("Proceed"),
            ),
          );
  }
}

class ResultTextWidget extends ConsumerWidget {
  const ResultTextWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(streamProvider);
    if (stream.hasValue == false) return Container();
    return AnimatedTextKit(
      key: GlobalStringKey(stream.value),
      animatedTexts: [
        TypewriterAnimatedText(
          '${stream.value!}',
          textStyle: Theme.of(context).textTheme.labelMedium,
          speed: const Duration(milliseconds: 40),
        ),
      ],
      totalRepeatCount: 1,
      pause: const Duration(milliseconds: 40),
    );
  }
}
