import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/db_models/spms_model.dart';
import '../../../notifiers/db/spms_notifier.dart';

final spmsNotifierProvider =
    AsyncNotifierProvider<SpmsNotifier, List<SpmsModel>>(SpmsNotifier.new);
