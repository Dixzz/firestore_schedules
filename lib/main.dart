import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scheduler/helpers/logger.dart';
import 'package:scheduler/helpers/router.dart';
import 'package:scheduler/models/fs_client_member.dart';
import 'package:scheduler/models/fs_event.dart';
import 'package:scheduler/models/fs_product_member.dart';
import 'package:scheduler/pages/home.dart';
import 'package:scheduler/pages/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final CollectionReference<Event> faEventColRef;
late final CollectionReference<Member> faProdMemColRef;
late final CollectionReference<ClientMember> faClientMemColRef;
late final SharedPreferences pref;


Future<void> saveUser(Member user) async {
  await pref.setString('user', jsonEncode(user));
}

Future<Member> getUser() async {
  logit('gawd ${pref.getString('user')}');
  return Member.fromJson(jsonDecode(pref.getString('user')!));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final collectionRef = FirebaseFirestore.instance.collection('events');
  final collectionProdMemRef =
      FirebaseFirestore.instance.collection('productMembers');
  final collectionClientMemRef =
      FirebaseFirestore.instance.collection('clients');

  pref = await SharedPreferences.getInstance();
  faEventColRef = collectionRef.withConverter<Event>(
    fromFirestore: (snapshot, _) =>
        Event.fromJson(snapshot.data()!..['id'] = snapshot.id),
    toFirestore: (user, _) => user.toJson(),
  );

  faProdMemColRef = collectionProdMemRef.withConverter<Member>(
    fromFirestore: (snapshot, _) => Member.fromJson(snapshot.data()!..['id'] = snapshot.id),
    toFirestore: (user, _) => user.toJson(),
  );

  faClientMemColRef = collectionClientMemRef.withConverter<ClientMember>(
    fromFirestore: (snapshot, _) => ClientMember.fromJson(snapshot.data()!),
    toFirestore: (user, _) => user.toJson(),
  );
  runApp(const MyApp());
}

int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);

MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.5),
    100: tintColor(color, 0.4),
    200: tintColor(color, 0.3),
    300: tintColor(color, 0.2),
    400: tintColor(color, 0.1),
    500: tintColor(color, 0),
    600: tintColor(color, -0.1),
    700: tintColor(color, -0.2),
    800: tintColor(color, -0.3),
    900: tintColor(color, -0.4),
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Scheduler',
      initialBinding: BindingsBuilder(() {}),
      theme: ThemeData(
        useMaterial3: false,
        textTheme: GoogleFonts.comfortaaTextTheme(
            // openSansTextTheme
            // Theme.of(context).textTheme.apply(
            // bodyColor: AppColors.mainTextColor3,
            // ),
            ),
        primarySwatch: generateMaterialColor(const Color(0xFF9DE1AA)),
      ),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
            middlewares: [Xyz()],
            name: '/${Routes.home.path}',
            binding: BindingsBuilder(() {
              Get.put(HomeController());
            }),
            page: () => Routes.home.className),
        GetPage(
            middlewares: [Xyz()],
            binding: BindingsBuilder(() {
              Get.put(LoginController());
            }),
            name: '/${Routes.login.path}',
            page: () => Routes.login.className),
      ],
    );
  }
}
