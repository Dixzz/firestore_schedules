import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DatePatterns {
  eeeddmmm('E, dd MMM'), //Mon, 20 May
  eeeddmmmyy('E, dd MMM yy\''), //Mon, 20 May 24'
  ;

  const DatePatterns(this._pattern);

  final String _pattern;

  String format(final DateTime date) {
    return DateFormat(_pattern).format(date);
  }
}

enum TimePatterns {
  hhmmaa('hh:mm aa'),
  ;

  const TimePatterns(this._pattern);

  final String _pattern;

  String format(final DateTime date) {
    return DateFormat(_pattern).format(date);
  }
}
