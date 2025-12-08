import 'dart:io';

import 'package:club_app_organizations_section/appScreenOrganizations/homePage/homePage.dart';
import 'package:club_app_organizations_section/appScreenOrganizations/sectionsScreen/sectionsScreen.dart';
import 'package:club_app_organizations_section/bloc/Cubit.dart';
import 'package:club_app_organizations_section/bloc/states.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../ShortCutCode/shortCutCode.dart';
import '../MassageScreen/ContactSpecialistsScreen.dart';
import '../MassageScreen/MassageScreen.dart';
import '../forgotPassword/forgotPasswordScreen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    DateTime? lastPressed; // لتخزين وقت آخر كبسة

    return BlocProvider(
      create: (BuildContext context) => CubitApp(),
      child: BlocConsumer<CubitApp, StatesApp>(
        listener: (BuildContext context, state) {

          // if(state is LoginOrganizationSuccessState){
          //   NavigatorMethod(context: context, screen: SectionScreen());
          // }

        },
        builder: (BuildContext context, Object? state) {
          var cubit = CubitApp.get(context);

          return WillPopScope(
            onWillPop: () async {
              final now = DateTime.now();

              if (lastPressed == null ||
                  now.difference(lastPressed!) > const Duration(seconds: 2)) {
                lastPressed = now;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("اضغط مرة أخرى للخروج"),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.purple.shade800,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );

                return false; // لا يخرج من التطبيق
              }

              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else {
                exit(0);
              }
              return false;
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade50,
                      Colors.white,
                      Colors.purple.shade50,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // خلفيات دائرية جميلة
                    Positioned(
                      top: -50.h,
                      left: -50.w,
                      child: Container(
                        width: 200.w,
                        height: 200.w,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80.h,
                      right: -80.w,
                      child: Container(
                        width: 250.w,
                        height: 250.w,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // المحتوى الرئيسي
                    SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // الشعار
                                  Container(
                                    width: 130.w,
                                    height: 130.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.purple.withOpacity(0.2),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.purple.shade100,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(65.w),
                                      child: Image.asset(
                                        'lib/assets/icon.png', // ضع مسار شعارك هنا
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30.h),

                                  // عنوان الصفحة
                                  Text(
                                    'مرحباً بك',
                                    style: TextStyle(
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'تسجيل الدخول إلى حسابك',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 40.h),

                                  // البريد الإلكتروني
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.purple.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: InputText(
                                      controller: email,
                                      inputType: TextInputType.emailAddress,
                                      prefixIcon: Icons.email,
                                      labelText: "البريد الإلكتروني",
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'الرجاء إدخال البريد الإلكتروني';
                                        }
                                        if (!value.contains('@')) {
                                          return 'الرجاء إدخال بريد إلكتروني صحيح';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20.h),

                                  // كلمة المرور
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.purple.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: InputText(
                                      controller: password,
                                      inputType: TextInputType.visiblePassword,
                                      prefixIcon: Icons.lock,
                                      labelText: "كلمة المرور",
                                      password: true,
                                      suffixIcon: cubit.passwordUser1
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      onpassword: cubit.passwordUser1,
                                      onPressedSuffixIcon: () {
                                        cubit.onChangeUserPassword1();
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'الرجاء إدخال كلمة المرور';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 16.h),

                                  // زر تسجيل الدخول
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {



                                          bool connected = await checkInternet(context: context);
                                          print("Internet: $connected");
                                           if(connected){
                                             cubit.showLoadingFun(i: true);
                                             await cubit.loginOrganization(
                                                 email: email.text,
                                                 password: password.text);

                                             if (cubit.dataLogin["status"] == "success") {
                                               await cubit.checkSubscriptions(
                                                   context: context);

                                               if (cubit.checkSubscriptionsBool) {
                                                 NavigatorMethod(
                                                     context: context,
                                                     screen: SectionScreen());
                                               }

                                             } else {
                                               ScaffoldMessenger.of(context)
                                                   .showSnackBar(
                                                 SnackBar(
                                                   content: Text(
                                                     cubit.dataLogin["msg"]??"error",
                                                     textAlign: TextAlign.center,
                                                     style: const TextStyle(
                                                         color: Colors.white),
                                                   ),
                                                   backgroundColor:
                                                   Colors.purple.shade800,
                                                   behavior:
                                                   SnackBarBehavior.floating,
                                                   shape: RoundedRectangleBorder(
                                                     borderRadius:
                                                     BorderRadius.circular(10),
                                                   ),
                                                   duration:
                                                   const Duration(seconds: 3),
                                                 ),
                                               );
                                               cubit.showLoadingFun(i: false);
                                             }
                                           }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple.shade800,
                                        padding:
                                        EdgeInsets.symmetric(vertical: 16.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 5,
                                        shadowColor: Colors.purple.withOpacity(0.3),
                                      ),
                                      child: Text(
                                        'تسجيل الدخول',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  TextButton(
                                    onPressed: () async {
                                      NavigatorMethod(
                                          context: context,
                                          screen: ForgotPasswordScreen());
                                    },
                                    child: Text(
                                      'نسيت كلمة المرور؟',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.purple.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (cubit.showLoading)
                      Center(child: CircularProgressIndicator())
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
