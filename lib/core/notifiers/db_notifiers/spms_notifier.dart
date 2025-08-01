import 'package:power_diyala/data_helper/database_helper.dart';

import '../../models/db_models/spms_model.dart';
import 'base_table_notifier.dart';

class SpmsNotifier extends BaseTableNotifier<SpmsModel> {
  @override
  Future<List<Map<String, dynamic>>> getRawRows() async {
    final db = await DatabaseHelper.getDatabase();
    return db.query(DatabaseHelper.spmsTable);
  }

  @override
  SpmsModel mapRow(Map<String, dynamic> row) {
    return SpmsModel.fromMap(row);
  }
}

Future<List<SpmsModel>> getBySiteCode(String siteCode) async {
  final db = await DatabaseHelper.getDatabase();
  final rows = await db.query(
    DatabaseHelper.spmsTable,
    where: 'siteCode = ?',
    whereArgs: [siteCode],
  );
  return rows.map(SpmsModel.fromMap).toList();
}
