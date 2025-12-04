import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../modules/app/app_router.dart';
import 'getit_utils.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

class GetItUtils {
  static Future<void> setup() async {
    configureDependencies();
  }
}