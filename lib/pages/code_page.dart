import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scheduler/helpers/dates.dart';
import 'package:scheduler/helpers/iterables.dart';
import 'package:scheduler/helpers/logger.dart';
import 'package:scheduler/main.dart';
import 'package:scheduler/models/fs_event.dart';
import 'package:scheduler/pages/add_event.dart';

final _dateNotifier =
    NotifierProvider.autoDispose<DateNotifierProvider, DateTime>(
  DateNotifierProvider.new,
);

class DateNotifierProvider extends AutoDisposeNotifier<DateTime> {
  @override
  DateTime build() {
    return update();
  }

  DateTime update([final DateTime? time]) {
    final now = time ?? DateTime.now();
    return state = now;
  }
}

class CodePageController extends GetxController {
  late final events = <Event>[].obs;

  late final StreamSubscription<QuerySnapshot<Event>>? _eventSubs;

  @override
  void onInit() {
    super.onInit();
    _eventSubs = faEventColRef
        .orderBy('created', descending: true)
        .snapshots()
        .listen((event) {
      events.value = event.docs.map((e) => e.data()).toImmutableList();
    });
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await _eventSubs?.cancel();
  }
}

class CodePage extends StatelessWidget {
  const CodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logit("wew built main");
    final CodePageController c = Get.put(CodePageController());


    return Scaffold(
      body: Column(
        children: [
          const Statusbar(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointments',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: const Color(0xff8d8d8d),
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Consumer(builder: (_, ref, __) {
                        return Text(
                          DatePatterns.eeeddmmm
                              .format(ref.watch(_dateNotifier)),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.comfortaa(
                              fontSize: 24, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff4993ff),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Consumer(
                      builder: (_, ref, __) => InkWell(
                            onTap: () async {
                              final res = await showCustomModalBottomSheet(
                                  context: context,
                                  builder: (_) => const AddEvent(),
                                  containerWidget: (BuildContext context,
                                      Animation<double> animation,
                                      Widget child) {
                                    return Scaffold(
                                        body: child);
                                  });
                              logit(res);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, top: 14, right: 20, bottom: 14),
                              child: Text(
                                'Add New',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.comfortaa(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )),
                ),
              ],
            ),
          ),
          Consumer(builder: (_, ref, __) {
            return EasyDateTimeLine(
              initialDate: ref.watch(_dateNotifier),
              activeColor: const Color(0x334993ff),
              headerProps: const EasyHeaderProps(showHeader: false),
              onDateChange: ref.read(_dateNotifier.notifier).update,
              // timeLineProps: EasyTimeLineProps(
              //   vPadding: 20,
              // ),
              dayProps: EasyDayProps(
                height: 75,
                width: 50,
                dayStructure: DayStructure.dayStrDayNum,
                inactiveDayStyle: DayStyle(
                  dayNumStyle: GoogleFonts.comfortaa(
                      fontSize: 22,
                      color: const Color(0xff7d7d7d),
                      fontWeight: FontWeight.w600),
                  dayStrStyle: GoogleFonts.comfortaa(
                      fontSize: 10,
                      color: const Color(0xff7d7d7d),
                      fontWeight: FontWeight.w600),
                ),
                activeDayStyle: DayStyle(
                  dayNumStyle: GoogleFonts.comfortaa(
                      fontSize: 24, fontWeight: FontWeight.w700),
                  dayStrStyle: GoogleFonts.comfortaa(
                      fontSize: 10, fontWeight: FontWeight.w700),
                  decoration: BoxDecoration(
                    color: const Color(0x334993ff),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(
            height: 16,
          ),
          Expanded(
              child: ObxValue((p0) {
            logit("Wew ${p0.length}");
            return ImplicitlyAnimatedList<Event>(
                items: p0,
                itemBuilder: (_, animation, event, index) {
                  logit("wew built $index");
                  final m = Tween(begin: const Offset(0, 0.2), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: animation, curve: Curves.easeInCubic));
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    child: InkWell(
                      onTap: () {
                        if (p0.any((element) => element.edit)) {
                          final ev =
                              Event(event.appName, event.created, !event.edit);
                          p0[index] = ev;
                        }
                      },
                      onLongPress: () {
                        // if (p0.any((element) => !element.edit)) return;
                        final ev = Event(
                            event.appName, event.created, !p0[index].edit);
                        p0[index] = ev;
                      },
                      child: SlideTransition(
                        position: m,
                        child: FadeTransition(
                          opacity: animation.drive(Tween(begin: 0, end: 1)),
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              padding: const EdgeInsets.all(16),
                              color: !event.edit ? Colors.amber : Colors.green,
                              child: Text(event.appName)),
                        ),
                      ),
                    ),
                  );
                },
                areItemsTheSame: (a, b) {
                  return a == b;
                });
          }, c.events)),
        ],
      ),
    );
  }
}
