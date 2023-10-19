import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/StorageScreen/Widgets/more_info_button.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:zal/Widgets/staggered_gridview.dart';

class StorageInformationWidget extends ConsumerWidget {
  const StorageInformationWidget({super.key, required this.storageInfo});
  final StorageInfo storageInfo;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ssdWrite = storageInfo.smartAttributes?.firstWhereOrNull((element) => element['attributeName'] == "Host Writes");
    //final hddWrite = storageInfo.smartAttributes.firstWhereOrNull((element) => element['attributeName'] == "Total Host Writes");
    final healthPercentage = storageInfo.info.entries.firstWhereOrNull((element) => element.key == "healthPercentage")?.value;
    final healthText = storageInfo.info.entries.firstWhereOrNull((element) => element.key == "healthText")?.value;
    return ListView(
      shrinkWrap: true,
      children: [
        StaggeredGridview(
          children: [
            CardWidget(
              titleIconAtRight: true,
              titleIcon: MoreInfoButton(
                onTap: () {
                  showConfirmDialog(
                      "Power ON Time",
                      "'Power on time' measures the total time your Storage has been running since it was last powered on. It doesn't include idle periods when the drive is not actively reading or writing data. This helps estimate the device's overall usage.",
                      context,
                      showButtons: false);
                },
              ),
              title: "Power on time",
              child: Text(
                secondsToWrittenTime(storageInfo.info['powerOnHours'] * 60 * 60),
              ),
            ),
            healthPercentage == null
                ? null
                : CardWidget(
                    titleIconAtRight: true,
                    titleIcon: MoreInfoButton(
                      onTap: () {
                        showConfirmDialog(
                            "SSD Health",
                            "'SSD health percentage' shows how much you've written stuff to your SSD. SSDs can only handle a certain amount of writing, so when the health reaches 0%, the SSD becomes read-only and you can't use it for anything new. You can only get your existing data from it at that point.",
                            context,
                            showButtons: false);
                      },
                    ),
                    title: "Health",
                    child: Column(
                      children: [
                        Text(
                          "$healthPercentage% ${(healthText != null) ? '($healthText)' : ''}",
                        ),
                        SizedBox(height: 0.5.h),
                        LinearProgressIndicator(value: healthPercentage / 100),
                        SizedBox(height: 0.5.h),
                      ],
                    ),
                  ),
            ssdWrite == null
                ? null
                : CardWidget(
                    titleIcon: MoreInfoButton(
                      onTap: () {
                        showConfirmDialog(
                            "Total Write",
                            "'Total Write' for an SSD is the measurement of how much data you've written or stored on the drive over time. Think of it like tracking how many times you've saved or edited documents, downloaded files, or installed software on your computer. This metric is important because it can give you an idea of how much life is left in your SSD.",
                            context,
                            showButtons: false);
                      },
                    ),
                    titleIconAtRight: true,
                    title: "Total Write",
                    child: Text(
                      ((ssdWrite['rawValue'] as int) * 1024 * 1024 * 1024).toSize(addSpace: true),
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}
