import 'package:power_diyala/data_helper/database_helper.dart';

import '../../models/db_models/calculator_model.dart';
import 'base_table_notifier.dart';

class CalculatorNotifier extends BaseTableNotifier<CalculatorModel> {
  @override
  Future<List<Map<String, dynamic>>> getRawRows() async {
    final db = await DatabaseHelper.getDatabase();
    return db.query(DatabaseHelper.calculatorTable);
  }

  @override
  CalculatorModel mapRow(Map<String, dynamic> row) {
    return CalculatorModel.fromMap(row);
  }
}

Future<List<CalculatorModel>> getBySiteCode(String siteCode) async {
  final db = await DatabaseHelper.getDatabase();
  final rows = await db.query(
    DatabaseHelper.calculatorTable,
    where: 'siteCode = ?',
    whereArgs: [siteCode],
  );
  return rows.map(CalculatorModel.fromMap).toList();
}
