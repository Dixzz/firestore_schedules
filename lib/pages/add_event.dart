import 'dart:async';
import 'dart:convert';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:omni_datetime_picker/src/variants/omni_datetime_picker_variants/omni_dtp_basic.dart';
import 'package:scheduler/helpers/dates.dart';
import 'package:scheduler/helpers/iterables.dart';
import 'package:scheduler/helpers/logger.dart';
import 'package:scheduler/main.dart'
    show faClientMemColRef, faEventColRef, faProdMemColRef;
import 'package:scheduler/models/api_helper.dart';
import 'package:scheduler/models/fs_event.dart';
import 'package:scheduler/models/fs_product_member.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AddEventController extends GetxController {
  late final prodMembers = <ProductMember>[].obs;
  late final clientMembers = <ProductMember>[].obs;
  late final StreamSubscription<QuerySnapshot<ProductMember>>? _prodMembersSubs;
  late final StreamSubscription<QuerySnapshot<ProductMember>>? _clientsSubs;
  late final holder = Duration.zero.obs;
  late final meetingLink = TextEditingController();
  late final meetingHolder = RxnString();

  /// input fields
  late final duration = Duration.zero.obs;
  late final meeting = DateTime.now().obs;
  late final ctr = TextEditingController();
  late final appNameCtr = TextEditingController();
  late final clNameCtr = TextEditingController();
  var prodIndex = -1;
  var clientIndex = -1;
  late final virtual = false.obs;

  @override
  void onInit() {
    super.onInit();
    _prodMembersSubs = faProdMemColRef.snapshots().listen((event) {
      prodIndex = -1;
      prodMembers.value = event.docs.map((e) => e.data()).toImmutableList();
    });
    _clientsSubs = faClientMemColRef.snapshots().listen((event) {
      clientIndex = -1;
      clientMembers.value = event.docs.map((e) => e.data()).toImmutableList();
    });
  }

  Future<void> save(Function(String) function) async {
    final appName = appNameCtr.text;
    final clientName = clNameCtr.text;
    final meet = meetingHolder.value;
    final clientSegmentRefId = clientMembers.getOrNull(clientIndex)?.name;
    final prodMemRefId = prodMembers.getOrNull(prodIndex)?.name;

    await faEventColRef
        .add(Event(appName, meeting.value, duration.value, meet!, clientName,
            clientSegmentRefId!, prodMemRefId!, virtual.value))
        .then((value) {
      reset();
      Fluttertoast.showToast(msg: 'Saved');
      Get.back();
    }).onError((error, stackTrace) => function("Unable to create event"));
  }

  void reset() {
    try {
      clientMembers[clientIndex] = ProductMember(clientMembers[clientIndex].name, false);
      prodMembers[prodIndex] = ProductMember(clientMembers[prodIndex].name, false);
      prodIndex = -1;
      clientIndex = -1;
      ctr.clear();
      virtual.value = false;
      clNameCtr.clear();
      meetingLink.clear();
      appNameCtr.clear();
    } catch(_) {

    }
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await _prodMembersSubs?.cancel();
    await _clientsSubs?.cancel();
    ctr.dispose();
    clNameCtr.dispose();
    meetingLink.dispose();
    appNameCtr.dispose();
  }

  Future<void> verify(
      CollectionReference<ProductMember> faClientMemColRef) async {
    logit("Checking ${ctr.text}");
    (await faClientMemColRef
            .where('name', isEqualTo: ctr.text)
            .get()
            .then((value) {
      return ApiResult.success(value.docs.isEmpty);
    }).onError((_, __) => const ApiResult.error("Unable to fetch")))
        .whenOrNull(success: (d) {
      if (!d) {
        Fluttertoast.showToast(
            msg: 'Member exists retry...', gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(msg: 'Created', gravity: ToastGravity.TOP);
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        ctr.clear();
      }
    }, error: (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
        Fluttertoast.showToast(msg: e);
      }

      ctr.clear();
    });
  }
}

class AddEvent extends StatelessWidget {
  AddEventController get c => Get.find();

  const AddEvent({Key? key}) : super(key: key);

  ImageProvider? _buildImageProvider(String? image) {
    ImageProvider? imageProvider = image != null ? NetworkImage(image) : null;
    if (image != null && image.startsWith('data:image')) {
      imageProvider = MemoryImage(
        base64Decode(image.substring(image.indexOf('base64') + 7)),
      );
    }
    return imageProvider;
  }

  @override
  Widget build(BuildContext context) {
    final AddEventController c = Get.put(AddEventController());

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        // primary: true,
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
                    'Add new event',
                    style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
                Image.asset(
                  'assets/images/ic_application.png',
                  width: 38,
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            TextField(
              controller: c.appNameCtr,
              decoration: const InputDecoration.collapsed(
                  hintText: 'Application Name',
                  hintStyle: TextStyle(color: Color(0xFFB7B7B7))),
              style: GoogleFonts.comfortaa(
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              controller: c.clNameCtr,
              decoration: const InputDecoration.collapsed(
                  hintText: 'Client Name',
                  hintStyle: TextStyle(color: Color(0xFFB7B7B7))),
              style: GoogleFonts.comfortaa(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(),
            const SizedBox(
              height: 16,
            ),
            Text('Client Segment',
                style: GoogleFonts.comfortaa(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: ObxValue((p0) {
                logit("Built ${p0.toJson()}");
                var i = -1;
                return Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.start,
                  children: [
                    ...p0.map((element) {
                      i += 1;
                      final index = i;
                      logit("Built $index");
                      return GestureDetector(
                        onTap: () {
                          logit(
                              "Updated ${element.toJson()} $index ${c.clientIndex}");
                          if (c.clientIndex == index) return;
                          if (c.clientIndex != -1) {
                            c.clientMembers[c.clientIndex] = ProductMember(
                                c.clientMembers[c.clientIndex].name, false);
                          }
                          c.clientMembers[index] =
                              ProductMember(element.name, !element.edit);
                          c.clientIndex = index;
                        },
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            color: element.edit
                                ? const Color(0x264993FF)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1,
                                  color: Color(
                                      element.edit ? 0xFF98C2FF : 0xFFBDBDBD)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Text(
                              element.name,
                              style: GoogleFonts.comfortaa(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () {
                        Get.dialog(Dialog(
                          backgroundColor: Colors.transparent,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Add Client Member',
                                      style:
                                          GoogleFonts.comfortaa(fontSize: 18)),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  TextField(
                                    controller: c.ctr,
                                    autofocus: true,
                                    style: GoogleFonts.nunito(),
                                    decoration: const InputDecoration.collapsed(
                                        hintText: 'Enter name'),
                                    onSubmitted: (_) async {
                                      await c.verify(faClientMemColRef);
                                    },
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Center(
                                    child: FilledButton(
                                        onPressed: () async {
                                          await c.verify(faClientMemColRef);
                                        },
                                        child: const Text('Create')),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ));
                      },
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0x804993FF)),
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox.square(
                            dimension: 20,
                            child: Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: Color(0xFF4993FF),
                            ),
                          )),
                    ),
                  ],
                );
              }, c.clientMembers),
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Virtual Event',
                    style: GoogleFonts.comfortaa(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                ObxValue(
                    (p0) => FlutterSwitch(
                          width: 30.0,
                          height: 22.0,
                          // valueFontSize: 25.0,
                          toggleSize: 12.0,
                          borderRadius: 30.0,
                          value: p0.value,
                          onToggle: c.virtual,
                        ),
                    c.virtual)
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(),
            const SizedBox(
              height: 24,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 14,
              children: [
                GestureDetector(
                  onTap: () async {
                    var res = await Get.dialog(Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: OmniDtpBasic(
                            firstDate: DateTime.now(),
                            type:
                            OmniDateTimePickerType.dateAndTime,
                          ),
                        )));
                    if (res is DateTime) {
                      c.meeting.value = res;
                    }
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
                                ObxValue(
                                    (p0) => Text(
                                          DatePatterns.eeeddmmmyy
                                              .format(p0.value),
                                          style: GoogleFonts.nunito(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            height: 0,
                                          ),
                                        ),
                                    c.meeting),
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
                ObxValue(
                    (p0) => GestureDetector(
                          onTap: () async {
                            var res = await Get.dialog(Dialog(
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
                              c.meeting.value = res;
                            }
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          TimePatterns.hhmmaa.format(p0.value),
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
                        ),
                    c.meeting),
                GestureDetector(
                  onTap: () async {
                    final bool res = await Get.dialog(Dialog(
                      backgroundColor: Colors.transparent,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Create meeting link',
                                style: GoogleFonts.comfortaa(
                                    fontSize: 16),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              TextField(
                                autofocus: true,
                                controller: c.meetingLink,
                                style: GoogleFonts.nunito(),
                                decoration:
                                const InputDecoration.collapsed(
                                    hintText: 'Paste link'),
                                onSubmitted: (_) async {
                                  Get.back(result: true);
                                },
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              Center(
                                  child: FilledButton(
                                      onPressed: () {
                                        Get.back(result: true);
                                      },
                                      child: const Text('Save')))
                            ],
                          ),
                        ),
                      ),
                    )) ??
                        false;
                    if (res) {
                      c.meetingHolder.value = c.meetingLink.text;
                      c.meetingLink.clear();
                    }

                    // launchUrlString(
                    //     'https://meet.google.com/dye-wojk-wzz?pli=1',
                    //     mode: LaunchMode.externalApplication);
                  },
                  child: SizedBox(
                    width: 160,
                    child: ClipRect(
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
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Link to join',
                                      style: GoogleFonts.nunito(
                                        color: const Color(0xFF929292),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        height: 0,
                                      ),
                                    ),
                                    ObxValue(
                                        (p0) => p0.value != null
                                            ? FutureBuilder(
                                                builder: (_, data) {
                                                  AnyLinkPreview.isValidLink(
                                                      p0.value!);
                                                  if (data.hasError) {
                                                    return Text(
                                                      'Unable to preview',
                                                      style:
                                                          GoogleFonts.comfortaa(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 0,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    );
                                                  }
                                                  final img =
                                                      _buildImageProvider(
                                                          data.data?.image);
                                                  if (img == null) {
                                                    return Text(
                                                        'Unable to preview',
                                                        style: GoogleFonts
                                                            .comfortaa(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          height: 0,
                                                        ));
                                                  }
                                                  return Row(children: [
                                                    Image(
                                                      image: img,
                                                      width: 20,
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                        data.data?.title ??
                                                            'NA',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .comfortaa(
                                                          color: Colors.black,
                                                          // fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          height: 0,
                                                        ))
                                                  ]);
                                                },
                                                future:
                                                    AnyLinkPreview.getMetadata(
                                                        link: p0.value!),
                                              )
                                            : const Text(
                                                'Enter meeting link...',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                        c.meetingHolder),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: SvgPicture.asset(
                                  'assets/images/ic_meeting_outlined.svg',
                                  width: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.dialog(Dialog(
                      backgroundColor: Colors.transparent,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Create meeting duration',
                                style: GoogleFonts.comfortaa(fontSize: 16),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Center(
                                child: ObxValue(
                                        (p0) => DurationPicker(
                                      onChange: c.holder,
                                      duration: c.holder.value,
                                    ),
                                    c.holder),
                              ),
                              Center(
                                  child: FilledButton(
                                      onPressed: () {
                                        c.duration.value = c.holder.value;
                                        Get.back();
                                      },
                                      child: const Text('Save')))
                            ],
                          ),
                        ),
                      ),
                    ));
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
                                  'Duration',
                                  style: GoogleFonts.nunito(
                                    color: const Color(0xFF929292),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  ),
                                ),
                                ObxValue((p0) {
                                  final hour = p0.value.inHours;
                                  final min = p0.value.inMinutes % 60;
                                  return Text(
                                    hour > 0 ? '${hour}h ${min}m' : '${min}m',
                                    style: GoogleFonts.nunito(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      height: 0,
                                    ),
                                  );
                                }, c.duration),
                              ],
                            ),
                            SvgPicture.asset(
                              'assets/images/ic_duration_outlined.svg',
                              width: 16,
                            )
                          ],
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
            Text('Product Members',
                style: GoogleFonts.comfortaa(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: ObxValue((p0) {
                var i = -1;
                return Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.start,
                  children: [
                    ...p0.map((element) {
                      i += 1;
                      final index = i;
                      logit("Built $index");
                      return GestureDetector(
                        onTap: () {
                          logit(
                              "Updated ${element.toJson()} $index ${c.prodIndex}");
                          if (c.prodIndex == index) return;

                          /// deselect old
                          if (c.prodIndex != -1) {
                            c.prodMembers[c.prodIndex] = ProductMember(
                                c.prodMembers[c.prodIndex].name, false);
                          }
                          c.prodMembers[index] =
                              ProductMember(element.name, !element.edit);
                          c.prodIndex = index;
                        },
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            color: element.edit
                                ? const Color(0x264993FF)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1,
                                  color: Color(
                                      element.edit ? 0xFF98C2FF : 0xFFBDBDBD)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Text(
                              element.name,
                              style: GoogleFonts.comfortaa(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () {
                        Get.dialog(Dialog(
                          backgroundColor: Colors.transparent,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Add Product Member',
                                      style:
                                          GoogleFonts.comfortaa(fontSize: 18)),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  TextField(
                                    controller: c.ctr,
                                    autofocus: true,
                                    style: GoogleFonts.nunito(),
                                    decoration: const InputDecoration.collapsed(
                                        hintText: 'Enter name'),
                                    onSubmitted: (_) async {
                                      await c.verify(faProdMemColRef);
                                    },
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Center(
                                    child: FilledButton(
                                        onPressed: () async {
                                          await c.verify(faProdMemColRef);
                                        },
                                        child: const Text('Create')),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ));
                      },
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0x804993FF)),
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox.square(
                            dimension: 20,
                            child: Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: Color(0xFF4993FF),
                            ),
                          )),
                    ),
                  ],
                );
              }, c.prodMembers),
            ),
            const SizedBox(
              height: 24,
            ),
            Center(
              child: FilledButton(
                style: FilledButton.styleFrom(
                    elevation: 4,
                    textStyle: GoogleFonts.comfortaa(fontSize: 14)),
                onPressed: () async {
                  await c.save((msg) {
                    Fluttertoast.showToast(msg: msg);
                  });
                },
                child: const Text('Create Event'),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
          ],
        ),
      ),
    );
  }
}
