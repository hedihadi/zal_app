import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class IsUserPremiumNotifier extends StateNotifier<bool> {
  // We initialize the list of todos to an empty list
  IsUserPremiumNotifier() : super(true) {
    checkUserForSubscriptions();
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      checkUserForSubscriptions();
    });
  }
  checkUserForSubscriptions() {
    Purchases.getCustomerInfo().then((value) {
      if (value.activeSubscriptions.isNotEmpty) {
        state = true;
      } else {
        state = false;
      }
    });
  }
}

final isUserPremiumProvider = StateNotifierProvider<IsUserPremiumNotifier, bool>((ref) {
  return IsUserPremiumNotifier();
});
