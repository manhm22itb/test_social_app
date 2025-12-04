import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:oktoast/oktoast.dart';
import 'package:social_app/src/modules/auth/presentation/component/forgot_password.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../../generated/colors.gen.dart';
import '../../../../common/widgets/toast_custom.dart';
import '../../../app/app_router.dart';
import '../component/widget_textfield.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<AuthCubit, AuthState>(
          
          listener: (context, state) {
            state.whenOrNull(
              authenticated: (userId) {
                final cubit = context.read<AuthCubit>();
                final token = cubit.accessToken;
                final refreshToken = cubit.refreshToken;
                
                print('🔑 LOGIN SUCCESS:');
                print('   User ID: $userId');
                print('   Access Token Length: ${token?.length ?? 0} chars');
                print('   Refresh Token Length: ${refreshToken?.length ?? 0} chars');
                print('   Access Token: $token');
                print('   Refresh Token: $refreshToken');
                
                if (token != null) {
                    debugPrint('🎯 FULL TOKEN:', wrapWidth: 1024);
                    debugPrint(token, wrapWidth: 1024);
                    
                    // Hoặc chia thành chunks
                    final chunkSize = 200;
                    for (int i = 0; i < token.length; i += chunkSize) {
                      final end = i + chunkSize < token.length ? i + chunkSize : token.length;
                      debugPrint('CHUNK${i ~/ chunkSize}: ${token.substring(i, end)}');
                    }
                  }
                showToastWidget(  
                  ToastWidget(title: 'Success', description: 'Login successful!'),
                  duration: const Duration(seconds: 2),
                );
                context.router.replaceAll([const HomeRoute()]);
              },
              unauthenticated: (emailErr, passErr, msg, isEmailValid, isPasswordValid ) {
                if (msg != null && msg.isNotEmpty) {
                 showToastWidget(
                  ToastWidget(title: 'Login Failed', description: msg),
                  duration: const Duration(seconds: 4),
                );
                }
              },
              failure: (message) {
                showToastWidget(
                  ToastWidget(title: 'Error', description: message),
                  duration: const Duration(seconds: 4),
                );
              },
            );
          },
          builder: (context, state) {
            final cubit = context.read<AuthCubit>();
            
            final unauth = state.maybeWhen(
              unauthenticated: (emailErr, passErr, msg, isEmailValid, isPasswordValid) => (emailErr, passErr, isEmailValid, isPasswordValid),
              orElse: () => ('', '', false, false),
            );
            
            final isNormalLoginBusy = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );
            
            final isGoogleLoginBusy = state.maybeWhen(
              googleLoading: () => true,
              orElse: () => false,
            );
            final isFormValid = unauth.$3 && unauth.$4; //3: maildValid, 4: passwordValid

            return SingleChildScrollView( 
              child: Padding(
                padding: EdgeInsets.all(30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Assets.authImages.login.image(
                        width: 250.w, 
                        height: 250.h, 
                      ),
                    ),
                    SizedBox(height: 20.h), 

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5.h), 
                        Text(
                          "Sign in to access your account",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(),
                        ),
                        SizedBox(height: 20.h), 

                        WidgetTextfield(
                          emailController: emailController,
                          passwordController: passwordController,
                          emailError: unauth.$1.isNotEmpty ? unauth.$1 : null,
                          passwordError: unauth.$2.isNotEmpty ? unauth.$2 : null,

                        ),

                        Gap(10.h),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: (){
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent, 
                                builder: (context) => ForgotPasswordBottomSheet(),
                              );
                            },
                            child: Text(
                              "Forgot password?", 
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: ColorName.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 30.h), 
                        GestureDetector(
                          onTap: isGoogleLoginBusy ? null : () {
                            cubit.signInWithGoogle();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 10.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              color: isGoogleLoginBusy ? Colors.grey.shade400 : ColorName.background,
                            ),
                            child: Center(
                              child: Text(
                                "Continue with Google",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ),
                        ),
                        
                        Gap(15.h),
                        GestureDetector(
                          onTap: (isFormValid && !isNormalLoginBusy) ? () {
                            cubit.signIn(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                          } : null,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 10.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              color: (isFormValid && !isNormalLoginBusy) 
                                ? ColorName.background 
                                : Colors.grey.shade400,
                            ),
                            child: Center(
                              child: isNormalLoginBusy
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Login",
                                      style: Theme.of(context).textTheme.titleSmall
                                    ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 15.h),
                        Center(
                          child: GestureDetector(
                            onTap: () {},
                            child: RichText(
                              text: TextSpan(
                                text: "New member? ",
                                style: Theme.of(context).textTheme.bodySmall,
                                children: [
                                  TextSpan(
                                    text: "Register now",
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: ColorName.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.router.push(const SignupRoute());
                                      },
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
  }
}