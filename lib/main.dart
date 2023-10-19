import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:upgrader/upgrader.dart';
import 'package:zal/Screens/MainScreen/main_screen.dart';
import 'Functions/theme.dart';

final _revenueCatConfiguration = PurchasesConfiguration(Platform.isAndroid ? 'goog_xokAwGykaqKIgLAIODrNHTTMnxF' : 'appl_eqiIImrSxvAweggWipqxMOgYidj');
Future<void> main() async {
  //initializations
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  Purchases.configure(_revenueCatConfiguration);

  //for some reason this is needed to allow error printing
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  runApp(ProviderScope(
    child: Sizer(builder: (context, orientation, deviceType) {
      return const App();
    }),
  ));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      themeMode: ref.watch(themeModeProvider),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme.copyWith(
        inputDecorationTheme: AppTheme.darkTheme.inputDecorationTheme
            .copyWith(focusedBorder: AppTheme.darkTheme.inputDecorationTheme.focusedBorder!.copyWith(borderSide: BorderSide.none)),
        textTheme: AppTheme.darkTheme.textTheme.copyWith(
          labelSmall: AppTheme.darkTheme.textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w300),
          titleLarge: GoogleFonts.bebasNeueTextTheme(AppTheme.darkTheme.textTheme).titleLarge,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: UpgradeAlert(
        child: const LoaderOverlay(overlayColor: Colors.black54, child: MainScreen()),
      ),
    );
  }
}
