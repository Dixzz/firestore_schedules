import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:omni_datetime_picker/src/variants/omni_datetime_picker_variants/omni_dtp_basic.dart';
import 'package:scheduler/helpers/dates.dart';
import 'package:scheduler/helpers/logger.dart';
import 'package:scheduler/models/revent.dart';
import 'package:scheduler/provider/global_providers.dart';
import 'package:timezone/timezone.dart' as tz;

final _dateStateProvider = StateProvider((ref) {
  return DateTime.now();
});

final _priorityStateProvider = StateProvider((ref) {
  return -1;
});
final _editStateProvider = StateProvider((ref) {
  return false;
});

class AddREvent extends ConsumerStatefulWidget {
  final REvent? event;
  final DateTime? date;

  const AddREvent({this.event, this.date, Key? key}) : super(key: key);

  @override
  AddREventState createState() => AddREventState();
}

class AddREventState extends ConsumerState {
  REvent? get ogEvent => (widget as AddREvent).event;
  DateTime? get date => (widget as AddREvent).date;

  late final titleCtr = TextEditingController();
  late final descCtr = TextEditingController();

  Future<void> _showDatePicker(WidgetRef ref) async {
    var res = await showDialog(
        context: context,
        builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: OmniDtpBasic(
                firstDate: DateTime.now(),
                type: OmniDateTimePickerType.dateAndTime,
              ),
            )));
    if (res is DateTime) {
      ref.read(_dateStateProvider.notifier).state = res;
    }
  }

  void reset() {
    ref.read(_priorityStateProvider.notifier).state = -1;
    ref.read(_editStateProvider.notifier).state = false;
    titleCtr.clear();
    descCtr.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final ogEventRef = ogEvent;
    final dateRef = date;
    if (dateRef != null) {
      Future.delayed(Duration.zero, () => ref.read(_dateStateProvider.notifier).state = dateRef);
    }
    if (ogEventRef != null) {
      titleCtr.text = ogEventRef.title;
      descCtr.text = ogEventRef.desc;

      Future.delayed(Duration.zero,
          () => ref.read(_dateStateProvider.notifier).state = ogEventRef.event);
      Future.delayed(
          Duration.zero,
          () => ref.read(_priorityStateProvider.notifier).state =
              ogEventRef.priority);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Statusbar(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    ref.watch(_editStateProvider) ? 'Edit event' : 'View event',
                    style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue),
                  ),
                ),
                Image.asset(
                  'assets/images/ic_application.png',
                  width: 38,
                )
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            TextField(
              controller: titleCtr,
              enabled: !ref.watch(_editStateProvider),
              decoration: const InputDecoration.collapsed(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Color(0xFFB7B7B7))),
              style: GoogleFonts.comfortaa(
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: descCtr,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              //Normal textInputField will be displayed
              maxLines: 5,
              decoration: const InputDecoration.collapsed(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Color(0xFFA4A4A4))),
              style: GoogleFonts.comfortaa(fontSize: 14),
            ),
            const SizedBox(
              height: 24,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 14,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _showDatePicker(ref);
                    },
                    child: SizedBox(
                      width: 160,
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0xFFC6C6C6)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Date',
                                    style: GoogleFonts.nunito(
                                      color: const Color(0xFF929292),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 0,
                                    ),
                                  ),
                                  Text(
                                    DatePatterns.eeeddmmmyy
                                        .format(ref.watch(_dateStateProvider)),
                                    style: GoogleFonts.nunito(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 0,
                                    ),
                                  )
                                ],
                              ),
                              SvgPicture.asset(
                                'assets/images/ic_date_outlined.svg',
                                width: 16,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await _showDatePicker(ref);
                    },
                    child: SizedBox(
                      width: 160,
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0xFFC6C6C6)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Clock',
                                    style: GoogleFonts.nunito(
                                      color: const Color(0xFF929292),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 0,
                                    ),
                                  ),
                                  Text(
                                    TimePatterns.hhmmaa
                                        .format(ref.watch(_dateStateProvider)),
                                    style: GoogleFonts.nunito(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 0,
                                    ),
                                  ),
                                ],
                              ),
                              SvgPicture.asset(
                                'assets/images/ic_clock_outlined.svg',
                                width: 16,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'Priority',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const SizedBox(
              height: 8,
            ),
            Wrap(
              spacing: 4,
              children: [
                GestureDetector(
                  onTap: () {
                    ref.read(_priorityStateProvider.notifier).state = 0;
                  },
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: ref.watch(_priorityStateProvider) == 0
                          ? Colors.blue.shade50
                          : const Color(0xFFF9F9F9),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: .5, color: Color(0xFFBDBDBD)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Text(
                        'High',
                        style: GoogleFonts.comfortaa(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ref.read(_priorityStateProvider.notifier).state = 1;
                  },
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: ref.watch(_priorityStateProvider) == 1
                          ? Colors.blue.shade50
                          : const Color(0xFFF9F9F9),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: .5, color: Color(0xFFBDBDBD)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Text(
                        'Low',
                        style: GoogleFonts.comfortaa(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ref.read(_priorityStateProvider.notifier).state = -1;
                  },
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: ref.watch(_priorityStateProvider) == -1
                          ? Colors.blue.shade50
                          : const Color(0xFFF9F9F9),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: .5, color: Color(0xFFBDBDBD)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Text(
                        'None',
                        style: GoogleFonts.comfortaa(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(),
            const SizedBox(
              height: 16,
            ),
            ogEvent == null || ref.read(_editStateProvider)
                ? Center(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          elevation: 4,
                          textStyle: GoogleFonts.comfortaa(fontSize: 14)),
                      onPressed: () async {
                        await save((msg) {
                          Fluttertoast.showToast(msg: msg);
                        }, ref);
                      },
                      child: Text(!ref.watch(_editStateProvider)
                          ? 'Create Event'
                          : 'Update Event'),
                    ),
                  )
                : const SizedBox.shrink(),
            ogEvent == null
                ? const SizedBox.shrink()
                : Center(
                    child: ref.read(_editStateProvider)
                        ? const SizedBox.shrink()
                        : TextButton(
                            onPressed: () {
                              ref.read(_editStateProvider.notifier).state =
                                  !ref.read(_editStateProvider);
                            },
                            child: const Text('Looking to update event?')),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    descCtr.dispose();
    titleCtr.dispose();
  }

  Future<void> save(Function(String msg) param0, WidgetRef ref) async {

    if (!ref.read(_editStateProvider) && titleCtr.text.trim().isEmpty) {
      param0("Please enter title");
      return;
    }
    if (descCtr.text.trim().isEmpty) {
      param0("Please enter description");
      return;
    }
    if (!ref.read(_editStateProvider) && ref.read(_dateStateProvider.notifier).state.difference(DateTime.now()).inSeconds < 5) {
      param0("Reminder schedule time too short");
      return;
    }
    final ogRef = ogEvent;
    if (!ref.watch(_editStateProvider) && ogRef == null) {
      await ref.read(dbProvider).personDao.insertItem(REvent(
          titleCtr.text,
          descCtr.text,
          ref.read(_dateStateProvider),
          ref.read(_priorityStateProvider)));

    } else {
      await ref.read(dbProvider).personDao.updateItem(ogRef!.updateContent(
          descCtr.text,
          ref.read(_dateStateProvider),
          ref.read(_priorityStateProvider)));
    }
    
    var scTime = tz.TZDateTime.from(ref.read(_dateStateProvider), tz.local);
    logit("Notification scheduled for ${scTime.toLocal()} -- $scTime");
    await ref.read(notifProvider).zonedSchedule(
        titleCtr.text.hashCode,
        titleCtr.text,
        null,
        scTime,
        const NotificationDetails(
            android:
            AndroidNotificationDetails(notifChannel, notifChannelName)),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
    titleCtr.clear();
    descCtr.clear();
    if (!mounted) return;
    Navigator.pop(context);
  }
}
