import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'revent.g.dart';

@Database(version: 1, entities: [REvent])
@TypeConverters([DateTimeConverter])
abstract class AppDatabase extends FloorDatabase {
  PersonDao get personDao;
}

@dao
abstract class PersonDao {
  @Query('SELECT * FROM REvent WHERE event between :start and :end ORDER BY event ASC')
  Stream<List<REvent>> findAllPersons(DateTime start, DateTime end);

  @Query('SELECT * FROM REvent WHERE priority = :priority AND event between :start and :end  ORDER BY event ASC')
  Stream<List<REvent>> findAllPersonsFiltered(int priority, DateTime start, DateTime end);

  @insert
  Future<void> insertItem(REvent person);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateItem(REvent person);

  @delete
  Future<void> deletePeople(List<REvent> people);
}

class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}

@entity
class REvent {
  @primaryKey
  final String title;
  final String desc;
  final DateTime event;
  final bool edit;
  final int priority;

  REvent(this.title, this.desc, this.event,
      [this.priority = -1, this.edit = false]);

  REvent toggleEdit(bool edit) => REvent(title, desc, event, priority, edit);

  // REvent updatePriority() => REvent(title, desc, event, priority, !edit);

  @override
  String toString() {
    return 'REvent{desc: $desc, event: $event, priority: $priority}';
  }

  REvent updateContent(String desc, DateTime event, int priority) {
    return REvent(title, desc, event, priority, edit);
  }
}
