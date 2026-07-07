import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../../data/repositories/bible_repository_impl.dart';
import '../../data/repositories/user_data_repository_impl.dart';
import '../../data/repositories/reading_repository_impl.dart';
import '../../domain/repositories/bible_repository.dart';
import '../../domain/repositories/user_data_repository.dart';
import '../../domain/repositories/reading_repository.dart';

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BibleRepositoryImpl(db);
});

final userDataRepositoryProvider = Provider<UserDataRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UserDataRepositoryImpl(db);
});

final readingRepositoryProvider = Provider<ReadingRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReadingRepositoryImpl(db);
});
