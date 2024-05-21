import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scheduler/helpers/dates.dart';
import 'package:scheduler/helpers/logger.dart';
import 'package:scheduler/main.dart';
import 'package:scheduler/models/fs_event.dart';

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

class CodePage extends StatelessWidget {
  const CodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                          DatePatterns.eeeddmmm.format(ref.watch(_dateNotifier)),
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
                              await faEventColRef.add(
                                  Event('appName', ref.read(_dateNotifier)));
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
          Expanded(child: FirestoreListView(
              query: faEventColRef.orderBy('created', descending: true),
              loadingBuilder: (_) => Center(child: CircularProgressIndicator()),
              itemBuilder: (_, ref) {
                return Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.amber,
                    child: Text(ref.data().appName));
              })),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 12),
          //   child: SizedBox(
          //     height: 100,
          //     child: HookBuilder(builder: (_) {
          //       final controller = useScrollController();
          //
          //       return ListView(
          //         scrollDirection: Axis.horizontal,
          //         children: [
          //           // Center(
          //           //   child: DecoratedBox(
          //           //     decoration: BoxDecoration(
          //           //       color: const Color(0x334993ff),
          //           //       borderRadius: BorderRadius.circular(24),
          //           //     ),
          //           //     child: Padding(
          //           //       padding: const EdgeInsets.only(
          //           //           left: 10, top: 14, right: 10, bottom: 14),
          //           //       child: Column(
          //           //         mainAxisAlignment: MainAxisAlignment.center,
          //           //         mainAxisSize: MainAxisSize.min,
          //           //         crossAxisAlignment: CrossAxisAlignment.center,
          //           //         children: [
          //           //           Text(
          //           //             'THU',
          //           //             textAlign: TextAlign.center,
          //           //             style: GoogleFonts.comfortaa(
          //           //                 fontSize: 10, fontWeight: FontWeight.w700),
          //           //             overflow: TextOverflow.ellipsis,
          //           //           ),
          //           //           const SizedBox(height: 4),
          //           //           Text(
          //           //             '9',
          //           //             textAlign: TextAlign.center,
          //           //             style: GoogleFonts.comfortaa(
          //           //                 fontSize: 24, fontWeight: FontWeight.w700),
          //           //             overflow: TextOverflow.ellipsis,
          //           //           ),
          //           //         ],
          //           //       ),
          //           //     ),
          //           //   ),
          //           // ),
          //         ],
          //       );
          //     }),
          //   ),
          // ),
        ],
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 13,
            top: 153,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'SUN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '3',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'MON',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '3',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'TUE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '3',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'WED',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '3',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0x334993ff),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, top: 14, right: 10, bottom: 14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'THU',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'Comfortaa-SemiBold',
                                      fontWeight: FontWeight.normal),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  '9',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: 'Comfortaa-SemiBold',
                                      fontWeight: FontWeight.normal),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'FRI',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '3',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'SAT',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '3',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'SUN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '3',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'MON',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '3',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xff7d7d7d),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 14,
            width: 364,
            top: 253,
            height: 134,
            child: Container(
              width: 364,
              height: 134,
              decoration: BoxDecoration(
                color: const Color(0xfff9f9f9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    left: 19,
                    top: 24,
                    child: Text(
                      'i-ERM',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Comfortaa-Bold',
                          fontWeight: FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 264,
                    top: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0x265d5d5d),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 14, top: 6, right: 14, bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Customer',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff474747),
                                      fontFamily: 'Comfortaa-SemiBold',
                                      fontWeight: FontWeight.normal),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 51,
                    top: 94,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '09.00 AM',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff545454),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '10.00 AM',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff545454),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    left: 19,
                    top: 53,
                    child: Text(
                      'LIC',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff545454),
                          fontFamily: 'Comfortaa-Regular',
                          fontWeight: FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 14,
            width: 364,
            top: 407,
            height: 152,
            child: Container(
              width: 364,
              height: 152,
              decoration: BoxDecoration(
                color: const Color(0xfff9f9f9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    left: 19,
                    width: 222,
                    top: 19,
                    child: Text(
                      'Name Screening with LN',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Comfortaa-Bold',
                          fontWeight: FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 51,
                    top: 115,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '10.00 AM',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff545454),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '11.00 AM',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff545454),
                                  fontFamily: 'Comfortaa-SemiBold',
                                  fontWeight: FontWeight.normal),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    left: 19,
                    top: 68,
                    child: Text(
                      'SBM',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff545454),
                          fontFamily: 'Comfortaa-Regular',
                          fontWeight: FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Positioned(
                    left: 19,
                    width: 24,
                    top: 111,
                    height: 24,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                    ),
                  ),
                  Positioned(
                    left: 244,
                    top: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0x265d5d5d),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 14, top: 6, right: 14, bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Private Bank',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff474747),
                                      fontFamily: 'Comfortaa-SemiBold',
                                      fontWeight: FontWeight.normal),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
