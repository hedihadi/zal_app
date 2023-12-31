import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:zal/Widgets/inline_ad.dart';

import '../Functions/firebase_analytics_manager.dart';

class GpuScreen extends ConsumerWidget {
  const GpuScreen({super.key, required this.gpuName});
  final String gpuName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerSocket = ref.watch(socketProvider);
    ref.read(screenViewProvider("gpu"));
    final gpu = computerSocket.value!.gpus.firstWhereOrNull((element) => element.name == gpuName);
    if (gpu == null) return const Text("gpu doesn't exist");
    return Scaffold(
      appBar: AppBar(title: const Text("GPU")),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
              child: Column(
                children: [
                  Text(gpu.name, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor)),
                  SizedBox(height: 3.h),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 20.h,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                  canScaleToFit: true,
                                  startAngle: 0,
                                  endAngle: 360,
                                  showTicks: false,
                                  showLabels: false,
                                  axisLineStyle: const AxisLineStyle(thickness: 10),
                                  pointers: <GaugePointer>[
                                    RangePointer(
                                      value: gpu.corePercentage,
                                      width: 10,
                                      color: Theme.of(context).primaryColor,
                                      enableAnimation: true,
                                      cornerStyle: CornerStyle.bothCurve,
                                    )
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        widget: Text(
                                          "${gpu.corePercentage.round()}%",
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).primaryColor),
                                        ),
                                        angle: 270,
                                        positionFactor: 0.1),
                                  ])
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Table(
                          defaultColumnWidth: const IntrinsicColumnWidth(),
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            tableRow(
                              context,
                              "Power",
                              FontAwesomeIcons.plug,
                              "${gpu.power.round()}W",
                            ),
                            tableRow(
                              context,
                              "Temperature",
                              FontAwesomeIcons.temperatureFull,
                              getTemperatureText(gpu.temperature, ref),
                              addSpacing: true,
                              suffixIcon: InkWell(
                                onTap: () {
                                  showInformationDialog(
                                      null,
                                      "the shown temperature is hotspot temperature, which shows the hottest sensored temp on your GPU.\nGpus has many temperature representations, we have chosen to show hotspot as it's the more critical one amongst the others.",
                                      context);
                                },
                                child: Icon(
                                  FontAwesomeIcons.question,
                                  size: 2.h,
                                ),
                              ),
                            ),
                            tableRow(
                              context,
                              "Load",
                              Icons.scale,
                              "${gpu.corePercentage.round()}%",
                              addSpacing: true,
                            ),
                            tableRow(
                              context,
                              "Core Speed",
                              FontAwesomeIcons.gauge,
                              "${gpu.coreSpeed.round()}Mhz",
                            ),
                            tableRow(
                              context,
                              "Memory Speed",
                              Icons.memory,
                              "${gpu.memorySpeed.round()}Mhz",
                            ),
                            tableRow(
                              context,
                              "Memory Usage",
                              Icons.memory,
                              (gpu.dedicatedMemoryUsed * 1000 * 1000).toSize(),
                            ),
                            tableRow(
                              context,
                              "Power",
                              FontAwesomeIcons.plug,
                              "${gpu.power.round()}W",
                            ),
                            tableRow(
                              context,
                              "Voltage",
                              Icons.electric_bolt,
                              "${gpu.voltage.toStringAsFixed(2)}V",
                            ),
                            tableRow(
                              context,
                              "Fan Speed",
                              FontAwesomeIcons.fan,
                              "${gpu.fanSpeedPercentage.round()}%",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
        ],
      ),
    );
  }
}
