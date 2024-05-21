import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scheduler/firebase_options.dart';
import 'package:scheduler/helpers/router.dart' show generateRouter;
import 'package:scheduler/models/fs_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'provider/global_providers.dart';

late final CollectionReference<Event> faEventColRef;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final collectionRef = FirebaseFirestore.instance.collection('events');

  faEventColRef = collectionRef.withConverter<Event>(
    fromFirestore: (snapshot, _) => Event.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );
  runApp(ProviderScope(overrides: [
    sharedPreferencesProvider.overrideWithValue(pref),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: false,
        textTheme: GoogleFonts.comfortaaTextTheme(
            // openSansTextTheme
            // Theme.of(context).textTheme.apply(
            // bodyColor: AppColors.mainTextColor3,
            // ),
            ),
        primarySwatch: Colors.blue,
      ),
      routerConfig: GoRouter(
          debugLogDiagnostics: true,
          initialLocation: '/',
          routes: generateRouter()),
    );
  }
}
