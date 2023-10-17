import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';

class AddAddressWidget extends ConsumerWidget {
  const AddAddressWidget({super.key, this.onScanComplete, this.showText = true});

  ///this function will be called after the address has been provided and saved without any error
  final Function? onScanComplete;
  final bool showText;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: _QrCodeWidget(
        onQrCodeProvided: (compressedString) => setAddress(compressedString, ref, context),
      ),
    );
  }

  setAddress(String compressedString, WidgetRef ref, BuildContext context) async {
    context.loaderOverlay.show();
    try {
      //  ref.read(addressWithSecretProvider.notifier).setAddress(compressedString, ref);
      ref.read(socketObjectProvider)?.socket.disconnect();
      onScanComplete?.call();
    } catch (c) {
      print(c);
    }
    context.loaderOverlay.hide();
  }
}

class _QrCodeWidget extends ConsumerWidget {
  const _QrCodeWidget({required this.onQrCodeProvided});
  final Function(String compressedString) onQrCodeProvided;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("download Zal on your PC and scan the QR Code below"),
        SizedBox(height: 1.h),
        Container(
          clipBehavior: Clip.hardEdge,
          height: 40.h,
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
          child: AspectRatio(
            aspectRatio: 1,
            child: MobileScanner(
              fit: BoxFit.fill,
              // fit: BoxFit.contain,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                final Uint8List? image = capture.image;
                for (final barcode in barcodes) {
                  final compressedString = barcode.rawValue.toString();
                  onQrCodeProvided(compressedString);
                }
              },
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: TextField(
            onSubmitted: (value) {
              onQrCodeProvided(value);
            },
            decoration: const InputDecoration(label: Text("or copy the code here")),
          ),
        )
      ],
    );
  }
}
