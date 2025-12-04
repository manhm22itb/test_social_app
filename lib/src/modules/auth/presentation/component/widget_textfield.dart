import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';

import '../../../../../generated/colors.gen.dart';
import '../cubit/auth_cubit.dart';



class WidgetTextfield extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final String? emailError;
  final String? passwordError;
  const WidgetTextfield({
    super.key, 
    required this.emailController, 
    required this.passwordController, 
    this.emailError, this.passwordError
  });

  @override
  State<WidgetTextfield> createState() => _WidgetTextfieldState();
}

class _WidgetTextfieldState extends State<WidgetTextfield> {
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h,)
            ),
            Text("Email", style: TextStyle(fontSize: 13.sp),),
            Gap(8.h),
            TextField(
                controller: widget.emailController,
                decoration: InputDecoration(
                    errorText: widget.emailError?.isNotEmpty ==true? widget.emailError:null,
                    filled: true,
                    fillColor:ColorName.textfield,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder:  OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      borderSide: BorderSide.none,
                    ),
                ),
                onChanged: (value) {
                  context.read<AuthCubit>().onChangedEmail(value);
                },
            ),
            Gap(8.h),
            Text("Password", style: TextStyle(fontSize: 13.sp),),
            TextField(
                controller: widget.passwordController,
                obscureText: isObscure,
                decoration: InputDecoration(
                    errorText: widget.passwordError?.isNotEmpty ==true? widget.passwordError:null,
                    filled: true,
                    fillColor: ColorName.textfield,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                        onPressed: (){
                            setState(() {
                               isObscure = !isObscure;
                            });
                        }, 
                        icon: FaIcon(
                            isObscure ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                            size: 16.sp,
                        ),
                        
                    )
                ),
                onChanged: (value) {
                  context.read<AuthCubit>().onChangedPassword(value);
                },
            ),
            
            
        ],
    );
  }
}