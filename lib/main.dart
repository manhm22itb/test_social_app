import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/common/utils/getit_utils.dart';
import 'src/modules/app/app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
    try {
    // 1. Load env
    await dotenv.load(fileName: "env/.env.dev");

    // 2. Config EasyLoading
    configLoading();

    // 3. Init Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    await GetItUtils.setup();

    runApp(
      OKToast(
        child: const AppWidget(),
      ),
    );
    
  } catch (e, stackTrace) {
    print('Stack trace: $stackTrace');
    // Không runApp gì cả, để app crash và show error trong log
    rethrow;
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2500)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..userInteractions = false
    ..maskType = EasyLoadingMaskType.black
    ..dismissOnTap = true;
}
