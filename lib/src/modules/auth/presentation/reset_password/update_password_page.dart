
import 'package:auto_route/auto_route.dart';
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



@RoutePage()
class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

 
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state){
        state.whenOrNull(
          updatePasswordSuccess: () {
            // Đóng bottom sheet khi thành công
            Navigator.of(context).pop();
            showToastWidget(
              ToastWidget(
                title: 'Success', 
                description: 'Update password successfull'
              ),
              duration: const Duration(seconds: 4),
            );
          },
          failure: (message) {
            showToastWidget(
              ToastWidget(
                title: 'Error',
                description: message,
              ),
              duration: const Duration(seconds: 4),
            );
          },
        );
      },
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
          final passwordError = state.maybeWhen(
            unauthenticated: (emailErr, passErr, msg, isEmailValid, isPasswordValid) => passErr,
            orElse: () => '',
          );

          final isPasswordValid = state.maybeWhen(
            unauthenticated: (emailErr, passErr, msg, isEmailValid, isPasswordValid) => isPasswordValid,
            orElse: () => false,
          );

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
              // QUAN TRỌNG: Thêm các property này
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, 
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enter new password',
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
                  
                  Gap(32.h),
                  
                  // Form
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "New password", 
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
                            controller: passwordController,
                            decoration: InputDecoration(
                              errorText: passwordError.isNotEmpty ==true? passwordError:null,
                              filled: true,
                              fillColor: Colors.transparent, 
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              hintText: 'Your new password',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              cubit.onChangedPassword(value);
                            },
                          ),
                        ),
                        
                        Gap(24.h),
                        
                        // Buttons
                        Row(
                          children: [
                            // Cancel Button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: loading ? null : () => Navigator.of(context).pop(),
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
                                onPressed:loading || !isPasswordValid ? null : () {
                                  cubit.updatePassword(newPassword: passwordController.text);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorName.background,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                ),
                                child: loading
                                    ? SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Ok',
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    
  }
}
