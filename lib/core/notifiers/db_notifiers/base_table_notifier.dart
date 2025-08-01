import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseTableNotifier<T> extends AsyncNotifier<List<T>> {
  Future<List<Map<String, dynamic>>> getRawRows();
  T mapRow(Map<String, dynamic> row);

  @override
  Future<List<T>> build() async {
    final rows = await getRawRows();
    return rows.map(mapRow).toList();
  }

  Future<void> refreshData() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final rows = await getRawRows();
      return rows.map(mapRow).toList();
    });
  }
}
