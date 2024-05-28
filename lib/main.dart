import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scheduler/firebase_options.dart';
import 'package:scheduler/helpers/logger.dart';
import 'package:scheduler/helpers/router.dart' show generateRouter;
import 'package:scheduler/models/fs_event.dart';
import 'package:scheduler/models/fs_product_member.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'provider/global_providers.dart';

late final CollectionReference<Event> faEventColRef;
late final CollectionReference<ProductMember> faProdMemColRef;
late final CollectionReference<ProductMember> faClientMemColRef;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final collectionRef = FirebaseFirestore.instance.collection('events');
  final collectionProdMemRef = FirebaseFirestore.instance.collection('productMembers');
  final collectionClientMemRef = FirebaseFirestore.instance.collection('clients');

  faEventColRef = collectionRef.withConverter<Event>(
    fromFirestore: (snapshot, _) => Event.fromJson(snapshot.data()!..['id'] = snapshot.id),
    toFirestore: (user, _) => user.toJson(),
  );

  faProdMemColRef = collectionProdMemRef.withConverter<ProductMember>(
    fromFirestore: (snapshot, _) => ProductMember.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );

  faClientMemColRef = collectionClientMemRef.withConverter<ProductMember>(
    fromFirestore: (snapshot, _) => ProductMember.fromJson(snapshot.data()!),
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
    return GetMaterialApp(
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
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      getPages: generateRouter(),
    );
  }
}
