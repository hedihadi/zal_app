import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/network_screen.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:sizer/sizer.dart';

class NetworkWidget extends ConsumerWidget {
  const NetworkWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerSocket = ref.watch(socketProvider);

    return computerSocket.when(
        skipLoadingOnReload: true,
        data: (data) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NetworkScreen()));
            },
            child: CardWidget(
              title: "Network",
              titleIcon: Image.asset(
                "assets/images/icons/wifi.png",
                height: 3.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: IntrinsicColumnWidth(flex: 2),
                          1: IntrinsicColumnWidth(flex: 2),
                        },
                        children: <TableRow>[
                          tableRow(
                            context,
                            "",
                            FontAwesomeIcons.cloudArrowUp,
                            "${data.networkSpeed.upload.toSize(decimals: 1)}/s",
                          ),
                          tableRow(
                            context,
                            "",
                            FontAwesomeIcons.cloudArrowDown,
                            "${data.networkSpeed.download.toSize(decimals: 1)}/s",
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        error: (error, stackTrace) => Container(),
        loading: () => Container());
  }
}
