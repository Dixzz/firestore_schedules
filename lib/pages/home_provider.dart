part of 'home.dart';

final dateStateProvider = StateProvider((ref) {
  return DateTime.now();
});

/// low, high, none (multi choice)
final rEventFilterBy = StateProvider((ref) {
  return -1;
});

final rEventStateProvider = StateProvider((ref) {
  return List<REvent>.empty();
});