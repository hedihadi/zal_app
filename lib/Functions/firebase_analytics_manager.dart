import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/utils.dart';

class AnalyticsManager {
  static Future<void> setIsUserUsingAdblock() async {
    final result = await isUserUsingAdblock();
    await FirebaseAnalytics.instance.setUserProperty(name: "using-adblock", value: result.toString());
  }

  static Future<void> logScreenView(String name) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'firebase_screen': name,
        'firebase_screen_class': name,
      },
    );
  }

  static Future<void> logEvent(
    String name, {
    Map<String, dynamic> options = const {},

    /// if true, we will send this event whether the user has disabled analytics or not.
    bool ignoreSettings = false,
  }) async {
    await FirebaseAnalytics.instance.logEvent(name: name, parameters: options);
  }
}

final screenViewProvider = FutureProviderFamily((ref, String screenName) async {
  await AnalyticsManager.logScreenView(screenName);
});
