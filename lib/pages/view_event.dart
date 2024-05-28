import 'dart:convert';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scheduler/helpers/dates.dart';
import 'package:scheduler/helpers/logger.dart';
import 'package:scheduler/models/fs_event.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ViewEvent extends StatelessWidget {

  final Event event;
  const ViewEvent({Key? key, required this.event}) : super(key: key);

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

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        // primary: true,
        controller: ModalScrollController.of(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Statusbar(),
            const Text(
              'View Event',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 24),
            ),
            const SizedBox(
              height: 36,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.appName, style: GoogleFonts.comfortaa(
                        fontSize: 24,
                        fontWeight: FontWeight.w700
                      ),),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(event.clientName, style: GoogleFonts.comfortaa(
                          fontSize: 16,
                          color: const Color(0xFFB7B7B7),
                          fontWeight: FontWeight.w500
                      ),),
                      const SizedBox(
                        height: 8,
                      ),
                      DecoratedBox(
                        decoration: ShapeDecoration(
                          color: const Color(0xFFEEEEEE ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Text(
                            event.clientSegmentRefId,
                            style: GoogleFonts.comfortaa(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                        ),
                      )
                    ],
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
            const Divider(),
            const SizedBox(
              height: 16,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 14,
              children: [
                SizedBox(
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
                                DatePatterns.eeeddmmmyy.format(event.meeting),
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
                            'assets/images/ic_date_outlined.svg',
                            width: 16,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
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
                                TimePatterns.hhmmaa.format(event.meeting),
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
                GestureDetector(
                  onTap: () async {
                    if (await canLaunchUrlString(event.meetingLink)) {
                      launchUrlString(event.meetingLink, mode: LaunchMode.externalApplication);
                    }
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
                                    FutureBuilder(
                                      builder: (_, data) {
                                        AnyLinkPreview.isValidLink(
                                            event.meetingLink);
                                        if (data.hasError) {
                                          return Text(
                                            'Unable to preview',
                                            style: GoogleFonts.comfortaa(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              height: 0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }
                                        final img = _buildImageProvider(
                                            data.data?.image);
                                        if (img == null) {
                                          return Text('Unable to preview',
                                              style: GoogleFonts.comfortaa(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
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
                                          Text(data.data?.title ?? 'NA',
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.comfortaa(
                                                color: Colors.black,
                                                // fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                height: 0,
                                              ))
                                        ]);
                                      },
                                      future: AnyLinkPreview.getMetadata(
                                          link: event.meetingLink),
                                    )
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
                SizedBox(
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
                              Builder(builder: (_) {
                                final hour = event.duration.inHours;
                                final min = event.duration.inMinutes % 60;
                                return Text(
                                  hour > 0 ? '${hour}h ${min}m' : '${min}m',
                                  style: GoogleFonts.nunito(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  ),
                                );
                              })
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
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(),
            Text('Product Members',
                style: GoogleFonts.comfortaa(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
            const SizedBox(
              height: 24,
            ),
            DecoratedBox(
              decoration: ShapeDecoration(
                color: const Color(0xFFF9F9F9),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      width: 1,
                      color: Color( 0xFFBDBDBD)),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                child: Text(
                  event.prodMemRefId,
                  style: GoogleFonts.comfortaa(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(),
            const SizedBox(
              height: 16,
            ),
            Text('Business Development',
                style: GoogleFonts.comfortaa(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
            const SizedBox(
              height: 24,
            ),
            Center(
              child: FilledButton(
                style: FilledButton.styleFrom(
                    elevation: 4,
                    backgroundColor: Colors.green,
                    textStyle: GoogleFonts.comfortaa(fontSize: 14)),
                onPressed: () async {
                  if (await canLaunchUrlString(event.meetingLink)) {
                    launchUrlString(event.meetingLink, mode: LaunchMode.externalApplication);
                  } else {
                    Fluttertoast.showToast(msg: "Invalid meeting link");
                  }
                },
                child: const Text('Join'),
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
