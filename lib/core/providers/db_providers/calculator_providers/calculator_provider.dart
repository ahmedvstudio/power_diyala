import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/db_models/calculator_model.dart';
import '../../../notifiers/db/calculator_notifier.dart';

final calculatorNotifierProvider =
    AsyncNotifierProvider<CalculatorNotifier, List<CalculatorModel>>(
        CalculatorNotifier.new);
