import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scheduler/models/fs_event.dart';
import 'package:scheduler/models/fs_product_member.dart';
import 'package:scheduler/pages/home.dart';

import 'models/revent.dart';
import 'provider/global_providers.dart';

late final CollectionReference<Event> faEventColRef;
late final CollectionReference<ProductMember> faProdMemColRef;
late final CollectionReference<ProductMember> faClientMemColRef;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref =
      await $FloorAppDatabase.databaseBuilder('floor_reminder.db').build();

  runApp(ProviderScope(overrides: [
    dbProvider.overrideWithValue(pref),
  ], child: const MyApp()));
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
