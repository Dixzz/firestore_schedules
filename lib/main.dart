import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scheduler/pages/home.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'models/revent.dart';
import 'provider/global_providers.dart';

Future<void> main() async {
  tz.initializeTimeZones();
  var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final pref =
      await $FloorAppDatabase.databaseBuilder('floor_reminder.db').build();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  final fnp = FlutterLocalNotificationsPlugin();
  await fnp.initialize(const InitializationSettings(
    iOS: DarwinInitializationSettings(),
    android: AndroidInitializationSettings('ic_logo'),
  ));

  await fnp.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  await Future.delayed(const Duration(seconds: 1));
  runApp(ProviderScope(overrides: [
    dbProvider.overrideWithValue(pref),
    notifProvider.overrideWithValue(fnp),
  ], child: const MyApp()));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scheduler',
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
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}
