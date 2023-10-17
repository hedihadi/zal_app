import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/FpsScreen/Widgets/chart.dart';
import 'package:zal/Screens/FpsScreen/Widgets/fps_presets_widget.dart';
import 'package:zal/Screens/FpsScreen/Widgets/save_fps_widget.dart';
import 'package:zal/Screens/FpsScreen/fps_screen_providers.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Widgets/inline_ad.dart';

import 'package:zal/Widgets/title_widget.dart';

import '../../Functions/firebase_analytics_manager.dart';

class FpsScreen extends ConsumerWidget {
  const FpsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fpsData = ref.watch(fpsDataProvider);
    ref.read(screenViewProvider("fps"));
    return WillPopScope(
      onWillPop: () async {
        ref.read(socketObjectProvider.notifier).state!.sendData('stop_fps', '');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("FPS Counter")),
        body: fpsData.when(
          skipLoadingOnReload: true,
          data: (data) {
            return ListView(
              shrinkWrap: true,
              children: [
                const TitleWidget("choose the game process"),
                SizedBox(
                  height: 10.h,
                  child: ListView.builder(
                    itemCount: data.processNames.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final processName = data.processNames.toList()[index];
                      return GestureDetector(
                        onTap: () {
                          ref.read(fpsDataProvider.notifier).chooseProcessName(processName);
                        },
                        child: Card(
                          color: data.chosenProcessName == processName ? Theme.of(context).primaryColor : null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            child: Center(child: Text(processName)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Text(
                          formatTime(((Timestamp.now().millisecondsSinceEpoch - data.timestamp.millisecondsSinceEpoch) / 1000).round()),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "1% fps",
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      "${data.fps01Low.round()}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "FPS",
                                      style: Theme.of(context).textTheme.titleLarge!,
                                    ),
                                    Text(
                                      "${data.fps.round()}",
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "0.1% fps",
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      "${data.fps001Low.round()}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            LineZoneChartWidget(fpsData: data),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SaveFpsWidget(),
                                IconButton(
                                  onPressed: () {
                                    ref.read(fpsDataProvider.notifier).reset();
                                  },
                                  icon: const Icon(FontAwesomeIcons.arrowsRotate),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.only(left: 2.w),
                  child: Text(
                    "Records:-",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const FpsPresetsWidget(),
                const InlineAd(adUnit: "ca-app-pub-5545344389727160/7822053264"),
              ],
            );
          },
          error: (error, stackTrace) {
            print(error);
            print(stackTrace);
            return Text("$error");
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
