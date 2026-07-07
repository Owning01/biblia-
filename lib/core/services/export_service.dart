import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref);
});

class ExportService {
  final Ref _ref;
  ExportService(this._ref);

  Future<String> buildBackupJson() async {
    final db = _ref.read(appDatabaseProvider);
    final bookmarks = await db.customSelect('SELECT * FROM bookmarks').get();
    final highlights = await db.customSelect('SELECT * FROM highlights').get();
    final notes = await db.customSelect('SELECT * FROM notes').get();
    final progress = await db
        .customSelect('SELECT * FROM reading_progress')
        .get();
    final payload = {
      'app': 'biblia',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'data': {
        'bookmarks': bookmarks.map((r) => r.data).toList(),
        'highlights': highlights.map((r) => r.data).toList(),
        'notes': notes.map((r) => r.data).toList(),
        'reading_progress': progress.map((r) => r.data).toList(),
      },
    };
    return jsonEncode(payload);
  }

  Future<void> shareBackup() async {
    final json = await buildBackupJson();
    await Share.share(json, subject: 'Mi respaldo de la Biblia');
  }
}
