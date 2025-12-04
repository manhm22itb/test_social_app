
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_app/src/modules/auth/presentation/cubit/auth_cubit.dart';

import '../../common/utils/getit_utils.dart';
import 'app_router.dart';

class AppWidget extends StatelessWidget {

  const AppWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouter>();
    
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => getIt<AuthCubit>(),
            lazy: false, 
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Poppins',
            
          ),
          
         
          builder: (context, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
              child: SafeArea(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },

          routerConfig: router.config(),
        ),
      ),
    );
  }
}