import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduler/models/revent.dart';


const notifChannel = 'package:scheduler_channel';
const notifChannelName = 'package:scheduler_channel_remind';
final dbProvider =
    Provider<AppDatabase>((ref) => throw UnimplementedError());
final notifProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) => throw UnimplementedError());
