import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zal/Functions/SettingsUI/section_setting_ui.dart';
import 'package:zal/Functions/SettingsUI/switch_setting_ui.dart';
import 'package:zal/Functions/firebase_analytics_manager.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import 'package:zal/Screens/LoginScreen/login_providers.dart';
import 'package:zal/Screens/SettingsScreen/settings_providers.dart';
import 'package:url_launcher/url_launcher.dart';

final revenueCatIdProvider = FutureProvider((ref) => Purchases.appUserID);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(screenViewProvider("settings"));
    final settings = ref.watch(settingsProvider).value;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          SectionSettingUi(
            children: [
              SwitchSettingUi(
                title: "Use Celcius",
                subtitle: "switch between Celcius and Fahreneit",
                value: settings?.useCelcius ?? true,
                onChanged: (value) => ref.read(settingsProvider.notifier).updateUseCelcius(value),
                icon: const Icon(FontAwesomeIcons.temperatureHalf),
              ),
            ],
          ),
          SectionSettingUi(
            children: [
              SwitchSettingUi(
                title: "Send Analytics",
                subtitle:
                    "your data will be used to see how the App\nbehaves on different PC Specs,this is \nextremely helpful to me, please leave it ON.",
                value: settings?.sendAnalaytics ?? true,
                onChanged: (value) => ref.read(settingsProvider.notifier).updateSendAnalytics(value),
                icon: const Icon(FontAwesomeIcons.paintRoller),
              ),
              SwitchSettingUi(
                title: "Personalized Ads",
                subtitle: "",
                value: settings?.personalizedAds ?? true,
                onChanged: (value) => ref.read(settingsProvider.notifier).updatePersonalizedAds(value),
                icon: const Icon(FontAwesomeIcons.paintRoller),
              ),
            ],
          ),
          ref.watch(socketProvider).value == null
              ? Container()
              : SectionSettingUi(children: [
                  const Text("Select your primary GPU"),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: ref.watch(socketProvider).value!.gpus.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5),
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        shadowColor: Colors.transparent,
                        child: Center(
                          child: Text(
                            ref.read(socketProvider).value!.gpus[index].name,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      );
                    },
                  ),
                ]),
          //MISC
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  launchUrl(
                    Uri.parse("https://www.freeprivacypolicy.com/live/6a690c4a-7f7a-4614-aee0-fce78a3e2995"),
                  );
                },
                child: const Text("Privacy Policy"),
              ),
              TextButton(
                onPressed: () {
                  launchUrl(
                    Uri.parse("https://developer.apple.com/app-store/review/guidelines/#privacy"),
                  );
                },
                child: const Text("TOS"),
              ),
            ],
          ),
          SectionSettingUi(
            children: [
              Text("Purchases ID:\n${ref.watch(revenueCatIdProvider).value}"),
              Text("UID:\n${ref.watch(authProvider).value!.uid}"),
            ],
          ),
        ],
      ),
    );
  }
}
