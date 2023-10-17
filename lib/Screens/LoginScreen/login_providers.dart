import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zal/Screens/LoginScreen/main_login_screen.dart';

class GoogleLoginNotifier extends AsyncNotifier {
  @override
  FutureOr build() {
    return false;
  }

  Future<bool> login() async {
    state = const AsyncValue.loading();
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      try {
        final isConnectingAccount = ref.read(isConnectingAccountProvider);
        if (isConnectingAccount) {
          await auth.currentUser!.linkWithCredential(credential);
          state = const AsyncData(null);
          return true;
        }
        final UserCredential userCredential = await auth.signInWithCredential(credential);
        user = userCredential.user;
        state = const AsyncData(null);
      } on FirebaseAuthException catch (e) {
        state = AsyncError(e.message.toString(), StackTrace.current);
      }
    }
    state = const AsyncData(null);
    return false;
  }
}

final asyncGoogleLoginProvider = AsyncNotifierProvider<GoogleLoginNotifier, dynamic>(() {
  return GoogleLoginNotifier();
});

class AnonymousLoginNotifier extends AsyncNotifier {
  @override
  FutureOr build() {
    return false;
  }

  login() async {
    state = const AsyncValue.loading();

    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signInAnonymously();

      state = const AsyncData(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncError(e.message.toString(), StackTrace.current);
    }

    state = const AsyncData(null);
  }
}

final asyncAnonymousLoginProvider = AsyncNotifierProvider<AnonymousLoginNotifier, dynamic>(() {
  return AnonymousLoginNotifier();
});

final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
