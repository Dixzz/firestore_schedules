import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scheduler/helpers/logger.dart';
import 'package:scheduler/helpers/router.dart';
import 'package:scheduler/main.dart'
    show collectionProdMemRef, faProdMemColRef, pref, saveUser;
import 'package:scheduler/models/fs_product_member.dart';

class LoginController extends GetxController {
  late final userIdCtr = TextEditingController();
  late final passIdCtr = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    userIdCtr.clear();
    passIdCtr.clear();
  }
}

class Login extends StatelessWidget {
  LoginController get c => Get.find();

  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Statusbar(),
                SvgPicture.asset(
                  'assets/images/ic_logo.svg',
                  height: 40,
                ),
                const SizedBox(
                  height: 4,
                ),
                const Text(
                  'Schedule application',
                  style: TextStyle(color: Colors.grey),
                ),
                Image.asset(
                  'assets/images/ic_bg_login.png',
                  fit: BoxFit.fitWidth,
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                // crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'User ID',
                        style: GoogleFonts.comfortaa(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextField(
                    controller: c.userIdCtr,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        hintText: 'Enter ID',
                        isCollapsed: true,
                        hintStyle: GoogleFonts.comfortaa(fontSize: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24))),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Password',
                        style: GoogleFonts.comfortaa(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextField(
                    controller: c.passIdCtr,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        hintText: 'Enter Password',
                        isCollapsed: true,
                        hintStyle: GoogleFonts.comfortaa(fontSize: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24))),
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16)),
                    onPressed: () async {
                      if (c.userIdCtr.text.trim().isEmpty) {
                        Fluttertoast.showToast(msg: 'Please enter user ID');
                        return;
                      }
                      if (c.passIdCtr.text.trim().isEmpty) {
                        Fluttertoast.showToast(msg: 'Please enter password');
                        return;
                      }
                      faProdMemColRef
                          .where('id', isEqualTo: c.userIdCtr.text)
                          .where('password', isEqualTo: c.passIdCtr.text)
                          .get()
                          .then((value) async {
                        if (value.docs.isEmpty) {
                          Fluttertoast.showToast(
                              msg:
                                  'Unable to find user with given credentials');
                        } else {
                          await pref.setBool('login', true);
                          saveUser(Member.fromJson(value.docs.first.data().toJson()..['id'] = value.docs.first.id));
                          Get.offNamed(Routes.home.path);
                        }
                      });
                    },
                    child: Text('Login',
                        style: GoogleFonts.comfortaa(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ));
  }
}
