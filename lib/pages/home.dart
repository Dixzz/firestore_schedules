import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scheduler/helpers/auto_path.dart' show reflector;
import 'package:scheduler/helpers/logger.dart';
import 'package:scheduler/provider/global_providers.dart'
    show dbProvider, sharedPreferencesProvider;

abstract class Poof {
  abstract final String p;
}

@reflector
class Home extends StatelessWidget implements Poof {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const Statusbar(),
        ElevatedButton(
            onPressed: () async {
              await FirebaseDatabase.instance.ref().set({
                "name": "John",
                "age": 18,
                "address": {"line1": "100 Mountain View"}
              });
            },
            child: const Text("child"))
      ],
    ));
  }

  @override
  final String p = 'home';
}
