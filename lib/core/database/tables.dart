import 'package:drift/drift.dart';

class BibleVersions extends Table {
  TextColumn get id => text()(); // 'rv1960', 'nvi'
  TextColumn get name => text()();
  TextColumn get abbreviation => text()();
  TextColumn get language => text().withDefault(const Constant('es'))();
  TextColumn get copyright => text().nullable()();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Books extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get abbreviation => text()();
  TextColumn get testament => text()(); // 'old' | 'new'
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Verses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get versionId => text().references(BibleVersions, #id)();
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();
  TextColumn get content => text()();
}

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get versionId => text()();
  IntColumn get bookId => integer()();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();
  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class Highlights extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get versionId => text()();
  IntColumn get bookId => integer()();
  IntColumn get chapter => integer()();
  IntColumn get verseStart => integer()();
  IntColumn get verseEnd => integer()();
  TextColumn get color => text()(); // hex color
  DateTimeColumn get createdAt => dateTime()();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get versionId => text()();
  IntColumn get bookId => integer()();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class ReadingPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get durationDays => integer()();
}

class ReadingPlanDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer().references(ReadingPlans, #id)();
  IntColumn get day => integer()();
  TextColumn get versionId => text()();
  IntColumn get bookId => integer()();
  IntColumn get chapter => integer()();
  IntColumn get verseStart => integer().withDefault(const Constant(1))();
  IntColumn get verseEnd => integer().nullable()();
}

class ReadingProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get planId => integer().references(ReadingPlans, #id)();
  IntColumn get day => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

class PrayerRequests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get authorName => text()();
  TextColumn get content => text()();
  BoolColumn get isAnonymous => boolean().withDefault(const Constant(false))();
  IntColumn get prayerCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

class PrayerActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get requestId => integer().references(PrayerRequests, #id)();
  TextColumn get userName => text()();
  DateTimeColumn get createdAt => dateTime()();
}
