import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

import 'xlsx_builder.dart';

class DataExportService {
  static String _ts(dynamic v) {
    if (v is Timestamp) return v.toDate().toIso8601String().split('T').first;
    return v?.toString() ?? '';
  }

  static String _str(dynamic v) => v?.toString() ?? '';
  static String _bool(dynamic v) => v == true ? 'Yes' : v == false ? 'No' : '';
  static String _list(dynamic v) => v is List ? v.join(', ') : v?.toString() ?? '';

  static Future<void> run() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    final results = await Future.wait([
      ref.collection('tasks').get(),
      ref.collection('notes').get(),
      ref.collection('schedule_items').get(),
    ]);

    final tasksSheet = XlsxSheet(
      name: 'Tasks',
      headers: ['Title', 'Description', 'Priority', 'Category', 'Due Date', 'Completed', 'Created At'],
      rows: results[0].docs.map((d) {
        final m = d.data();
        return [
          _str(m['title']),
          _str(m['description']),
          _str(m['priority']),
          _str(m['category']),
          _ts(m['dueDate']),
          _bool(m['isCompleted']),
          _ts(m['createdAt']),
        ];
      }).toList(),
    );

    final notesSheet = XlsxSheet(
      name: 'Notes',
      headers: ['Title', 'Body', 'Tags', 'Linked Task', 'Created At', 'Updated At'],
      rows: results[1].docs.map((d) {
        final m = d.data();
        return [
          _str(m['title']),
          _str(m['body']),
          _list(m['tags']),
          _str(m['linkedTaskId']),
          _ts(m['createdAt']),
          _ts(m['updatedAt']),
        ];
      }).toList(),
    );

    final plannerSheet = XlsxSheet(
      name: 'Planner',
      headers: ['Title', 'Description', 'Date', 'Start Time', 'End Time', 'Emoji', 'Created At'],
      rows: results[2].docs.map((d) {
        final m = d.data();
        return [
          _str(m['title']),
          _str(m['description']),
          _ts(m['date']),
          _str(m['startTime']),
          _str(m['endTime']),
          _str(m['emoji']),
          _ts(m['createdAt']),
        ];
      }).toList(),
    );

    final bytes = XlsxBuilder.build([tasksSheet, notesSheet, plannerSheet]);
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: 'universe_export_$dateStr.xlsx',
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      ],
      subject: 'Uni-Verse Data Export',
    );
  }
}
