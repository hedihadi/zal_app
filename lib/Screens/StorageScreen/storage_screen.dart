import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:zal/Screens/StorageScreen/Widgets/storage_errors_widget.dart';
import 'package:zal/Screens/StorageScreen/Widgets/storage_information_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';
import '../../Functions/firebase_analytics_manager.dart';

class StorageScreen extends ConsumerWidget {
  StorageScreen({super.key, required this.name});
  String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(screenViewProvider("storage"));
    final computerSocket = ref.watch(socketProvider);
    final storages = computerSocket.value!.storages;
    final foundStorages = storages.where((element) => element.name == name).toList();
    if (foundStorages.isEmpty) return const Text("storage doesn't exist anymore :o where did it go?");
    final storage = foundStorages.first;

    final storageInfo = ref.read(socketProvider.notifier).storageInfos.firstWhereOrNull((element) => element.info['model'] == storage.name);
    return Scaffold(
      appBar: AppBar(title: Text("Storage ${storage.diskNumber}")),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
              child: Column(
                children: [
                  Text(storage.name, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor)),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 15.h,
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
                                        value: ((storage.size - storage.freeSpace) / storage.size) * 100,
                                        width: 10,
                                        color: Theme.of(context).primaryColor,
                                        enableAnimation: true,
                                        cornerStyle: CornerStyle.bothCurve,
                                      )
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                          widget: Text(
                                            (storage.freeSpace).toSize(decimals: 1),
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).primaryColor),
                                          ),
                                          angle: 270,
                                          positionFactor: 0.1),
                                    ])
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.w),
                          child: Table(
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: <TableRow>[
                              tableRow(
                                context,
                                "Disk number",
                                FontAwesomeIcons.indent,
                                "${storage.diskNumber}",
                              ),
                              tableRow(
                                context,
                                "Temperature",
                                FontAwesomeIcons.temperatureFull,
                                getTemperatureText(storage.temperature, ref),
                              ),
                              tableRow(
                                context,
                                "Type",
                                FontAwesomeIcons.question,
                                storage.type.name,
                              ),
                              tableRow(
                                context,
                                "Size",
                                FontAwesomeIcons.boxesStacked,
                                storage.size.toSize(),
                              ),
                              tableRow(
                                context,
                                "Free",
                                FontAwesomeIcons.boxOpen,
                                storage.freeSpace.toSize(),
                              ),
                              tableRow(
                                context,
                                "Drives",
                                FontAwesomeIcons.list,
                                storage.partitions.map((e) => e.toString().replaceAll(':', '')).toString().replaceAll('(', '').replaceAll(')', ''),
                              ),
                              tableRow(
                                context,
                                "Read",
                                FontAwesomeIcons.eye,
                                "${storage.readRate.toSize()}/s",
                              ),
                              tableRow(
                                context,
                                "Write",
                                FontAwesomeIcons.pencil,
                                "${storage.writeRate.toSize()}/s",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          storageInfo == null ? Container() : StorageErrorsWidget(storageInfo: storageInfo),
          storageInfo == null ? Container() : StorageInformationWidget(storageInfo: storageInfo),
          const InlineAd(adUnit: "ca-app-pub-5545344389727160/7822053264"),
        ],
      ),
    );
  }
}
