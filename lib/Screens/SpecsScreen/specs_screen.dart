import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sizer/sizer.dart';

import '../../Functions/firebase_analytics_manager.dart';

class SpecsScreen extends ConsumerWidget {
  SpecsScreen({super.key});
  ScreenshotController screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(screenViewProvider("specs"));
    final socket = ref.watch(socketProvider);
    return socket.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: (data) {
        final table = Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
          },
          children: <TableRow>[
            tableRow(
              context,
              "",
              FontAwesomeIcons.chessBoard,
              data.motherboard.name,
              addSpacing: true,
              customIcon: Image.asset(
                "assets/images/icons/motherboard.png",
                height: 25,
              ),
            ),
            tableRow(
              context,
              "",
              customIcon: Image.asset(
                "assets/images/icons/gpu.png",
                height: 25,
              ),
              Icons.power,
              data.gpu.name,
              addSpacing: true,
            ),
            tableRow(
              context,
              "",
              Icons.power,
              data.cpu.cpuInfo.name,
              customIcon: Image.asset(
                "assets/images/icons/cpu.png",
                height: 25,
              ),
              addSpacing: true,
            ),
            tableRow(
              context,
              "",
              Icons.power,
              "${(data.ram.memoryAvailable + data.ram.memoryUsed).round()} GB:\n${data.ram.ramPieces.map((e) => '      ${e.capacity.toSize(decimals: 0)} ${e.speed}Mhz ${e.manufacturer}\n').toString().replaceAll('(', '').replaceAll(')', '').replaceAll(', ', '')}",
              customIcon: Image.asset(
                "assets/images/icons/ram.png",
                height: 25,
              ),
              addSpacing: true,
            ),
            tableRow(
              context,
              "",
              Icons.power,
              data.storages
                  .map((e) => '${(e.size / 1000 / 1000 / 1000).round()} GB ${e.type.name}\n')
                  .toString()
                  .replaceAll('(', '')
                  .replaceAll(')', '')
                  .replaceAll(', ', ''),
              customIcon: Image.asset(
                "assets/images/icons/memorycard.png",
                height: 25,
              ),
              addSpacing: true,
            ),
            tableRow(
              context,
              "",
              Icons.power,
              data.monitors
                  .map((e) => '${e.width} x ${e.height}${e.primary ? ' primary' : ''}\n')
                  .toString()
                  .replaceAll('(', '')
                  .replaceAll(')', '')
                  .replaceAll(', ', ''),
              customIcon: Image.asset(
                "assets/images/icons/monitor.png",
                height: 25,
              ),
              addSpacing: true,
            ),
          ],
        );
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          child: ListView(
            shrinkWrap: true,
            children: [
              Screenshot(
                controller: screenshotController,
                child: table,
              ),
              //Center(
              //  child: ElevatedButton.icon(
              //      onPressed: () {
              //        screenshotController.captureFromWidget(table).then((capturedImage) async {
              //          //save the image
              //          final result = await ImageGallerySaver.saveImage(capturedImage, quality: 100, name: "${DateTime.now().toString()}");
              //          ScaffoldMessenger.of(context)
              //            ..hideCurrentSnackBar()
              //            ..showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, showCloseIcon: true, content: Text('screenshot saved!')));
              //        });
              //      },
              //      icon: Icon(FontAwesomeIcons.image),
              //      label: Text('take Screenshot')),
              //)
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
