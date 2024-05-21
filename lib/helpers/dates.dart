import 'package:intl/intl.dart';

enum DatePatterns {
  eeeddmmm('E, dd MMM'), //Mon, 20 May
  ;
  const DatePatterns(this._pattern);
  final String _pattern;

  String format(final DateTime date){
    return DateFormat(_pattern).format(date);
  }
}