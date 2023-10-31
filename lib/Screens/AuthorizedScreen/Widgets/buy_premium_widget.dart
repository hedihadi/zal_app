import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';

class BuyPremiumWidget extends ConsumerWidget {
  const BuyPremiumWidget({super.key, required this.offerings});
  final Offerings offerings;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Premium"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                child: Row(
                  children: [
                    const CircleAvatar(
                      child: Text("1Y"),
                    ),
                    SizedBox(width: 1.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Yearly",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          "Save %15",
                          style: Theme.of(context).textTheme.labelMedium,
                        )
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await Purchases.purchaseStoreProduct(offerings.current!.annual!.storeProduct);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: const Text("Purchase successful!"),
                                showCloseIcon: true,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ));
                              Navigator.of(context).pop();
                            } on Exception {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: const Text("Purchase failed."),
                                showCloseIcon: true,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ));
                            }
                          },
                          child: Text("${offerings.current?.annual?.storeProduct.priceString}"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                child: Row(
                  children: [
                    const CircleAvatar(
                      child: Text("1M"),
                    ),
                    SizedBox(width: 1.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Monthly",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          "",
                          style: Theme.of(context).textTheme.labelMedium,
                        )
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await Purchases.purchaseStoreProduct(offerings.current!.monthly!.storeProduct);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: const Text("Purchase successful!"),
                                showCloseIcon: true,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ));
                              Navigator.of(context).pop();
                            } on Exception {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: const Text("Purchase failed."),
                                showCloseIcon: true,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ));
                            }
                          },
                          child: Text("${offerings.current?.monthly?.storeProduct.priceString}"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Text(
              "benefits:-",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              children: const [
                BenefitCard(text: "Remove Ads"),
                BenefitCard(text: "Premium Features (coming soon)"),
                BenefitCard(text: "Support the Developer"),
              ],
            ),
            const Spacer(),
            const RestorePurchasesButton(),
          ],
        ),
      ),
    );
  }
}

class BenefitCard extends ConsumerWidget {
  const BenefitCard({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Theme.of(context).colorScheme.onPrimary,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
final isrestorePurchaseFirstRunProvider=AutoDisposeStateProvider<bool>((ref){
  return true;
});
final restorePurchaseProvider = FutureProvider.autoDispose<bool>((ref) async {
  if(ref.read(isrestorePurchaseFirstRunProvider)==true){
    await Future.delayed(const Duration(milliseconds: 500), () {
ref.read(isrestorePurchaseFirstRunProvider.notifier).state=false;

});
    
    return true;
  }
  await Future.delayed(const Duration(seconds: 5));
  await Purchases.restorePurchases();
  return true;
});

class RestorePurchasesButton extends ConsumerWidget {
  const RestorePurchasesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restorePurchases = ref.watch(restorePurchaseProvider);
    return ElevatedButton(
      onPressed: () {
        ref.invalidate(restorePurchaseProvider);
      },
      child: restorePurchases.when(
        skipLoadingOnRefresh: false,
        data: (data) => restorePurchases.isLoading ? const CircularProgressIndicator() : const Text("Restore Purchases"),
        error: (error, stackTrace) => Text(error.toString(),maxLines: 5),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
