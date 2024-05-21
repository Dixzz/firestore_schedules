import 'package:flutter/material.dart';
import 'package:scheduler/helpers/logger.dart';

class Home extends StatelessWidget  {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logit("called");
    return Scaffold(
        body: Column(
      children: [
        const Statusbar(),
        ElevatedButton(
            onPressed: () async {

            },
            child: const Text("child"))
      ],
    ));
  }
}
