import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../generated/assets.gen.dart';
import '../../../../generated/colors.gen.dart';
import '../../app/app_router.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';

@RoutePage()
class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  StreamSubscription? _authSubscription;
  bool _hasNavigated = false; 

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    final authCubit = context.read<AuthCubit>();

    _checkAuthState(authCubit.state);
    
    _authSubscription = authCubit.stream.listen((state) {
      if (!_hasNavigated) { 
        _checkAuthState(state);
      }
    });
  }

  void _checkAuthState(AuthState state) {
    if (_hasNavigated) return; 
    
    state.maybeWhen(
      authenticated: (_) {
        _hasNavigated = true;
        context.router.replace(const HomeRoute());
      },
      passwordRecovery: () {
        _hasNavigated = true;
        context.router.replace(const UpdatePasswordRoute());
      },
      unauthenticated: (_, __, ___, ____, _____) {
        _hasNavigated = true;
        context.router.replace(const LoginRoute());
      },
      orElse: () {
        // Fallback sau 3 giây
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted || _hasNavigated) return;
          _hasNavigated = true;
          context.router.replace(const LoginRoute());
        });
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel(); //cancel subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.authImages.splash.image(
              width: 250.w,
              height: 250.h,
            ),
            Text(
              'City Life',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: ColorName.textSplash,
                fontWeight: FontWeight.bold,
                fontSize: 35.sp,
                fontFamily: 'Asimovian'
              ),
            ),
          ],
        ),
      ),
    );
  }
}