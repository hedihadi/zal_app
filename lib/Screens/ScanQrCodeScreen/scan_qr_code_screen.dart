import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zal/Widgets/add_address_widget.dart';

class ScanQrCodeScreen extends ConsumerWidget {
  ScanQrCodeScreen({super.key});
  bool popped = false;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: AddAddressWidget(
        onScanComplete: () {
          if (popped == false) {
            Navigator.of(context).pop();
            popped = true;
          }
        },
      ),
    );
  }
}
