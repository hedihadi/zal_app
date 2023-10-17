import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MoreInfoButton extends ConsumerWidget {
  const MoreInfoButton({super.key, this.onTap});
  final Function? onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: const Icon(
          FontAwesomeIcons.question,
          fill: 0.2,
        ),
      ),
    );
  }
}
