import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../../generated/colors.gen.dart';
import '../../../../common/widgets/toast_custom.dart';
import '../../../app/app_router.dart';
import '../component/widget_textfield.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
@RoutePage()
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
            if (!mounted) return;
            state.whenOrNull(
              authenticated: (userId) {
                context.router.replaceAll([const HomeRoute()]);
              },
              pendingVerification: (email) {
                showToastWidget(
                  ToastWidget(title: 'Check Your Email', description: 'We sent a verification link to $email. Please check your inbox.'),
                  duration: const Duration(seconds: 4),
                );
                Future.delayed(const Duration(seconds: 4), () {
                  if (mounted) {
                    context.router.pop();
                  }
                });
              },
              unauthenticated: (emailErr, passErr, msg, isEmailValid, isPasswordValid) {
                if (msg != null && msg.isNotEmpty) {
                  showToastWidget(
                    ToastWidget(title: 'Sign Up Failed', description: msg),
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
            //validation
            final unauth = state.maybeWhen(
              unauthenticated: (emailErr, passErr, msg, isEmailValid, isPasswordValid) => (emailErr, passErr, isEmailValid, isPasswordValid),
              orElse: () => ('', '', false, false),
            );
            //Loading
            final isSignupBusy = state.maybeWhen(
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
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Assets.authImages.signup.image(
                          width: 250.w,
                          height: 250.h,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Get started",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            "By creating a free account",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(),
                          ),
                          
                          WidgetTextfield(
                             emailController: emailController,
                             passwordController: passwordController,
                             emailError: unauth.$1.isNotEmpty ? unauth.$1 : null,
                             passwordError: unauth.$2.isNotEmpty ? unauth.$2 : null,
                          ),

                          Gap(5.h),

                          Gap(60.h),
                          
                          
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
                            onTap: (isFormValid && !isSignupBusy) ?() { 
                              cubit.signUp(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                            } : null,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 10.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.r),
                                color: (isFormValid && !isSignupBusy) 
                                  ? ColorName.background 
                                  : Colors.grey.shade400,
                              ),
                              child: Center(
                                child:Text(
                                        "Register", 
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                              ),
                            ),
                          ),
                          
                          Gap(15.h),
                          Center(
                            child: GestureDetector(
                              onTap: () => {
                                context.router.push(const LoginRoute())
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Already a member? ",
                                  style: Theme.of(context).textTheme.bodySmall,
                                  children: [
                                    TextSpan(
                                      text: "Login now", 
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            color: ColorName.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      recognizer: TapGestureRecognizer()..onTap = () {
                                        context.router.push(const LoginRoute());
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
                ],
              ),
            ),
          ); 
        },
      ),
    );
  }
}
    