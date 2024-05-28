import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scheduler/helpers/dates.dart';
import 'package:scheduler/helpers/iterable_extensions.dart';
import 'package:scheduler/helpers/iterables.dart';
import 'package:scheduler/helpers/logger.dart';
import 'package:scheduler/main.dart';
import 'package:scheduler/models/fs_event.dart';
import 'package:scheduler/pages/add_event.dart';
import 'package:scheduler/pages/view_event.dart';

class HomeController extends GetxController {
  static const _field = 'meeting';

  late final filterDate = DateTime.now().obs;

  late final events = <Event>[].obs;

  StreamSubscription<QuerySnapshot<Event>>? eventSubs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  void fetchEvents() async {
    final now = DateTime(
        filterDate.value.year, filterDate.value.month, filterDate.value.day);
    final endDate = DateTime(now.year, now.month, now.day + 1);

    logit("Fetching for $now to $endDate");
    eventSubs = faEventColRef
        .where(_field, isGreaterThanOrEqualTo: now, isLessThan: endDate)
        .orderBy(_field, descending: true)
        .snapshots()
        .listen((event) {
      logit("Fetched events ${event.docs.length}");
      events.value = event.docs.map((e) => e.data()).toImmutableList();
    });
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await eventSubs?.cancel();
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logit("wew built main");
    final HomeController c = Get.put(HomeController());

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
                      ObxValue(
                          (p0) => Text(
                                DatePatterns.eeeddmmm.format(p0.value),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.comfortaa(
                                    fontSize: 24, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                          c.filterDate),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xff4993ff),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await showCustomModalBottomSheet(
                          context: context,
                          builder: (_) => const AddEvent(),
                          containerWidget: (BuildContext context,
                              Animation<double> animation, Widget child) {
                            return Scaffold(body: child);
                          });
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
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
              child: ObxValue((p0) {
            logit("Wew ${p0.length}");
            final selectedItemCount = p0.where((p0) => p0.edit);
            return Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: selectedItemCount.isNotEmpty
                      ? ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 75),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected',
                                      style: GoogleFonts.comfortaa(
                                          fontSize: 20,
                                          color: const Color(0xff8E8E8E)),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      '${selectedItemCount.length} ${selectedItemCount.length == 1 ? "event" : "events"}',
                                      style: GoogleFonts.comfortaa(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      var batches =
                                          chunk(selectedItemCount, 100);
                                      var commitBatchPromises =
                                          <Future<void>>[];

                                      for (var batch in batches) {
                                        var writeBatch =
                                            FirebaseFirestore.instance.batch();
                                        for (var element in batch) {
                                          writeBatch.delete(
                                              faEventColRef.doc(element.id));
                                        }
                                        commitBatchPromises
                                            .add(writeBatch.commit());
                                        await Future.wait(commitBatchPromises);
                                      }
                                    },
                                    child: Image.asset(
                                      'assets/images/ic_bin.png',
                                      width: 20,
                                    ))
                              ],
                            ),
                          ),
                        )
                      : ObxValue(
                          (p0) => EasyDateTimeLine(
                                initialDate: p0.value,
                                activeColor: const Color(0x334993ff),
                                headerProps:
                                    const EasyHeaderProps(showHeader: false),
                                onDateChange: (d) {
                                  c.filterDate.value = d;
                                  c.eventSubs?.cancel();
                                  c.fetchEvents();
                                },
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
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700),
                                    dayStrStyle: GoogleFonts.comfortaa(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700),
                                    decoration: BoxDecoration(
                                      color: const Color(0x334993ff),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                ),
                              ),
                          c.filterDate),
                ),
                const SizedBox(
                  height: 16,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: p0.isEmpty
                        ? const Text('--- Nothing to see here ---')
                        : ImplicitlyAnimatedList(
                            items: p0,
                            itemBuilder: (_, animation, event, index) {
                              logit("wew built $index ${event.toJson()}");
                              final m = Tween(
                                      begin: const Offset(0, 0.2),
                                      end: Offset.zero)
                                  .animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInCubic));
                              return GestureDetector(
                                onTap: () {
                                  if (p0.any((element) => element.edit)) {
                                    p0[index] = event.updateEdit(!event.edit);
                                  } else {
                                    showCustomModalBottomSheet(
                                        context: context,
                                        builder: (_) =>
                                            ViewEvent(event: p0[index]),
                                        containerWidget: (BuildContext context,
                                            Animation<double> animation,
                                            Widget child) {
                                          return Scaffold(body: child);
                                        });
                                  }
                                },
                                onLongPress: () {
                                  p0[index] = event.updateEdit(!event.edit);
                                },
                                child: SlideTransition(
                                  position: m,
                                  child: FadeTransition(
                                    opacity: animation
                                        .drive(Tween(begin: 0, end: 1)),
                                    child: AnimatedContainer(
                                        margin: const EdgeInsets.all(12),
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                            color: !event.edit
                                                ? const Color(0xfff0f0f0)
                                                : const Color(0xFFEDF4FF),
                                            borderRadius:
                                                BorderRadius.circular(32)),
                                        duration:
                                            const Duration(milliseconds: 400),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 16,
                                                            left: 16,
                                                            top: 16,
                                                            bottom: 8),
                                                    child: Text(
                                                      p0[index].appName,
                                                      style:
                                                          GoogleFonts.comfortaa(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                    ),
                                                  ),
                                                ),
                                                Transform.translate(
                                                  offset: const Offset(5, 0),
                                                  child: DecoratedBox(
                                                    decoration: const BoxDecoration(
                                                        color:
                                                            Color(0x265E5E5E),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        24),
                                                                topRight: Radius
                                                                    .circular(
                                                                        24))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 16,
                                                              right: 24,
                                                              top: 6,
                                                              bottom: 6),
                                                      child: Text(
                                                        p0[index]
                                                            .clientSegmentRefId,
                                                        style: GoogleFonts
                                                            .comfortaa(
                                                                fontSize: 12),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16,
                                                  left: 16,
                                                  bottom: 16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p0[index].clientName,
                                                    style:
                                                        GoogleFonts.comfortaa(),
                                                  ),
                                                  const SizedBox(
                                                    height: 16,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/ic_clock_tinted.png',
                                                        width: 20,
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                        TimePatterns.hhmmaa
                                                            .format(p0[index]
                                                                .meeting),
                                                        style: GoogleFonts
                                                            .comfortaa(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Transform.rotate(
                                                        angle: 180 * 0.01745329,
                                                        child: const Icon(
                                                          Icons.arrow_back,
                                                          size: 15,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                        TimePatterns.hhmmaa
                                                            .format(p0[index]
                                                                .meeting
                                                                .add(p0[index]
                                                                    .duration)),
                                                        style: GoogleFonts
                                                            .comfortaa(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                              );
                            },
                            areItemsTheSame: (a, b) {
                              return a == b;
                            }),
                  ),
                ),
              ],
            );
          }, c.events)),
        ],
      ),
    );
  }
}
