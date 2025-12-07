import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../../generated/colors.gen.dart';
import '../../../../common/widgets/toast_custom.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class ForgotPasswordBottomSheet extends StatefulWidget {
  final String? emailError;
  const ForgotPasswordBottomSheet({super.key, this.emailError});

  @override
  State<ForgotPasswordBottomSheet> createState() => _ForgotPasswordBottomSheetState();
}

class _ForgotPasswordBottomSheetState extends State<ForgotPasswordBottomSheet> {
  final TextEditingController emailController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          passwordResetSent: (email) {
            // Đóng bottom sheet khi thành công
            Navigator.of(context).pop();
            showToastWidget(
              ToastWidget(
                title: 'Success', 
                description: 'Password reset email sent to $email'
              ),
              duration: const Duration(seconds: 4),
            );
          },
        );
      },
      child: _buildContent(), 
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, 
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, 
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const FaIcon(FontAwesomeIcons.xmark),
                  ),
                ],
              ),
              
              Gap(8.h),
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              
              Gap(32.h),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final cubit = context.read<AuthCubit>();

                  final emailError = state.maybeWhen(
                    unauthenticated: (emailErr, passErr, msg, isEmailValid, isPasswordValid) => emailErr,
                    orElse: () => '',
                  );
                  
                  final isEmailValid = state.maybeWhen(
                    unauthenticated: (emailErr, passErr, msg, isEmailValid, isPasswordValid) => isEmailValid,
                    orElse: () => false,
                  );

                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email", 
                            style: TextStyle(fontSize: 15.sp),
                          ),
                        ),
                        Gap(8.h),
                        Container(
                          decoration: BoxDecoration(
                            color: ColorName.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              errorText: emailError.isNotEmpty == true ? emailError : null,
                              filled: true,
                              fillColor: Colors.transparent, 
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              hintText: 'your@email.com',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              cubit.onChangedEmail(value);
                            },
                          ),
                        ),
                        
                        Gap(24.h),

                        Row(
                          children: [
                            // Cancel Button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.grey.shade700,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            
                            Gap(12.w),
                            
                            // Reset Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed:_isLoading || !isEmailValid ? null : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  
                                  try {
                                    await cubit.resetPassword(email: emailController.text);
                                  } catch (e) {
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorName.background,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Reset',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}