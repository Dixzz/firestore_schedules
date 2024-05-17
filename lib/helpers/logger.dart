
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:scheduler/helpers/context_extensions.dart';

import 'iterables.dart';
import 'package:stack_trace/stack_trace.dart';

import 'package:flutter/foundation.dart';


class Statusbar extends StatelessWidget {
  const Statusbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(top: context.mediaQueryViewPadding.top));
  }
}
void logit(dynamic value) {
  var frame = Trace.from(StackTrace.current).terse.frames;
  var trace = frame.getOrNull(1) ?? frame.firstOrNull();

  var line = trace?.line;
  var ogTraceUriData = trace?.uri;


  if (kDebugMode) {
    log("LINE -> $ogTraceUriData:$line, MESSAGE -> $value");
  }
   // debugPrint(
   //     "LINE -> $ogTraceUriData:$line, MESSAGE -> $value",
   //     wrapWidth: 1024);
}
