import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Widgets/card_widget.dart';
import 'package:zal/Widgets/inline_ad.dart';
import 'package:zal/Widgets/title_widget.dart';

import '../Functions/firebase_analytics_manager.dart';

class NetworkScreen extends ConsumerWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final computerSocket = ref.watch(socketProvider);
    ref.read(screenViewProvider("network"));
    return Scaffold(
      appBar: AppBar(title: const Text("Network")),
      body: ListView(
        children: [
          const TitleWidget("change your Primary Network"),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: (computerSocket.value?.networkInterfaces ?? []).map(
              (e) {
                return GestureDetector(
                  onTap: () {
                    ref.read(socketObjectProvider.notifier).state?.sendData("change_primary_network", e.name);
                  },
                  child: CardWidget(
                    titleContainerColor: e.isPrimary
                        ? Theme.of(context).primaryColor
                        : e.isEnabled
                            ? null
                            : Theme.of(context).colorScheme.errorContainer,
                    title: e.name,
                    child: Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        tableRow(
                          context,
                          "Description",
                          FontAwesomeIcons.plug,
                          e.description,
                          showIcon: false,
                        ),
                        tableRow(
                          context,
                          "Status",
                          FontAwesomeIcons.plug,
                          e.isEnabled ? "Enabled" : "Disabled",
                          showIcon: false,
                        ),
                        tableRow(
                          context,
                          "Download",
                          FontAwesomeIcons.plug,
                          e.bytesReceived.toSize(decimals: 0, addSpace: true),
                          showIcon: false,
                        ),
                        tableRow(
                          context,
                          "Upload",
                          FontAwesomeIcons.plug,
                          e.bytesSent.toSize(decimals: 0, addSpace: true),
                          showIcon: false,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          InlineAd(adUnit: Platform.isAndroid ? "ca-app-pub-5545344389727160/7822053264" : "ca-app-pub-5545344389727160/7748436032"),
        ],
      ),
    );
  }
}
