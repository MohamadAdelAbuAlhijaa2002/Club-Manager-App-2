import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../bloc/Cubit.dart';
import '../../bloc/states.dart';
import '../../ShortCutCode/shortCutCode.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  final List<TextEditingController> codeControllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> codeFocusNodes =
  List.generate(6, (index) => FocusNode());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CubitApp(),
      child: BlocConsumer<CubitApp, StatesApp>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = CubitApp.get(context);

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                'نسيت كلمة المرور',
                style: TextStyle(
                  color: Colors.purple.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.purple.shade800),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.w),
                onPressed: () {
                  cubit.onChangeShow(cubit.show > 0 ? cubit.show - 1 : 0);
                  if (cubit.show == 0) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),

                      /// الخطوة الأولى: إدخال البريد الإلكتروني
                      cubit.show == 0
                          ? Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              'أدخل عنوان بريدك الإلكتروني وسنرسل لك رمز تحقق لإعادة تعيين كلمة المرور.',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 32.h),
                            SizedBox(
                                height: MediaQuery.of(context).size.height * 0.2),
                            Text(
                              'البريد الإلكتروني',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            InputText(
                              controller: emailController,
                              inputType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              labelText: "your@gmail.com",
                              validator: (value) {
                                if (value!.isEmpty) return 'البريد الإلكتروني مطلوب';
                                if (!value.contains('@'))
                                  return 'صيغة البريد الإلكتروني غير صحيحة';
                                return null;
                              },
                            ),
                            SizedBox(height: 24.h),
                            SizedBox(
                              width: double.infinity,
                              height: 48.h,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    bool connected = await checkInternet(context: context);

                                    if(connected){
                                      cubit.showLoadingFun(i: true);
                                      await cubit.checkEmail(email: emailController.text);

                                      if (cubit.dataCheckEmail["status"] == "success") {
                                        if (await EmailOTP.sendOTP(
                                          email: emailController.text.trim(),
                                        )) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("تم إرسال رمز التحقق إلى بريدك الإلكتروني"),
                                              backgroundColor: Colors.green,
                                            ),
                                          );

                                          cubit.showLoadingFun(i: false);
                                          cubit.onChangeShow(1);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("فشل في إرسال رمز التحقق"),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } else {
                                        cubit.showLoadingFun(i: false);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("${cubit.dataCheckEmail["message"]}"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }

                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade800,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'إرسال رمز التحقق',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 32.h),
                          ],
                        ),
                      )
                          : Container(),

                      /// الخطوة الثانية: إدخال رمز التحقق
                      cubit.show == 1
                          ? Form(
                        key: _formKey2,
                        child: Column(
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context).size.height * 0.2),
                            Text(
                              'رمز التحقق',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'أدخل الرمز المكون من 6 أرقام المرسل إلى بريدك الإلكتروني',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return SizedBox(
                                  width: 45.w,
                                  child: TextFormField(
                                    controller: codeControllers[index],
                                    focusNode: codeFocusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                        borderSide: BorderSide(
                                            color: Colors.purple.shade800, width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.length == 1 && index < 5) {
                                        FocusScope.of(context)
                                            .requestFocus(codeFocusNodes[index + 1]);
                                      } else if (value.isEmpty && index > 0) {
                                        FocusScope.of(context)
                                            .requestFocus(codeFocusNodes[index - 1]);
                                      }
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) return '';
                                      return null;
                                    },
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 32.h),

                            SizedBox(
                              width: double.infinity,
                              height: 48.h,
                              child: ElevatedButton(
                                onPressed: () async {
                                  bool connected = await checkInternet(context: context);

                                  if (connected) {
                                    cubit.showLoadingFun(i: true);

                                    String verificationCode =
                                    codeControllers.map((c) => c.text).join();

                                    if (verificationCode.length != 6) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'يرجى إدخال الرمز المكون من 6 أرقام بالكامل'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      cubit.showLoadingFun(i: false);
                                      return;
                                    }

                                    if (await EmailOTP.verifyOTP(
                                      otp: verificationCode.trim(),
                                    )) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "تم التحقق من الرمز بنجاح"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      cubit.onChangeShow(2);
                                      cubit.showLoadingFun(i: false);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("رمز التحقق غير صحيح"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      cubit.showLoadingFun(i: false);
                                    }
                                  }
                                },




                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade800,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'تحقق من الرمز',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "لم يصلك الرمز؟ ",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {

                                      bool connected = await checkInternet(context: context);

                                      if (connected) {
                                        cubit.showLoadingFun(i: true);

                                        if (await EmailOTP.sendOTP(
                                          email: emailController.text.trim(),
                                        )) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "تمت إعادة إرسال الرمز"),
                                            ),
                                          );
                                          cubit.showLoadingFun(i: false);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "فشل في إعادة إرسال الرمز"),
                                            ),
                                          );
                                          cubit.showLoadingFun(i: false);
                                        }

                                    }
                                  },
                                  child: Text(
                                    "إعادة الإرسال",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.purple.shade800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                          : Container(),

                      /// الخطوة الثالثة: تعيين كلمة مرور جديدة
                      cubit.show == 2
                          ? Form(
                        key: _formKey3,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                  height:
                                  MediaQuery.of(context).size.height * 0.2),
                              InputText(
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
                                    return 'يرجى إدخال كلمة المرور';
                                  }
                                  if (value.length < 8) {
                                    return 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل';
                                  } else if (checkPasswordSc(value)) {
                                    return 'يجب أن تحتوي كلمة المرور على أحرف كبيرة وصغيرة وأرقام ورموز';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 24.h),
                              InputText(
                                controller: confirmPassword,
                                inputType: TextInputType.visiblePassword,
                                prefixIcon: Icons.lock,
                                labelText: "تأكيد كلمة المرور",
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
                                    return 'يرجى إدخال تأكيد كلمة المرور';
                                  }
                                  if (value != password.text) {
                                    return 'كلمة المرور غير متطابقة';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 24.h),
                              SizedBox(
                                width: double.infinity,
                                height: 48.h,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey3.currentState!.validate()) {
                                      bool connected = await checkInternet(
                                          context: context);

                                      if (connected) {
                                        cubit.showLoadingFun(i: true);
                                        await cubit.forgotPassword(
                                          password: password.text,
                                          email: emailController.text,
                                        );

                                        if (cubit
                                            .dataForgotPassword["status"] ==
                                            "success") {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "${cubit
                                                      .dataForgotPassword["message"]}"),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          cubit.onChangeShow(0);
                                          cubit.showLoadingFun(i: false);
                                          Navigator.pop(context);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "${cubit
                                                      .dataForgotPassword["message"]}"),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          cubit.showLoadingFun(i: false);
                                        }
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple.shade800,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Text(
                                    'تم',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 32.h),
                            ],
                          ),
                        ),
                      )
                          : Container(),
                    ],
                  ),
                ),

                /// تحميل أثناء العمليات
                if (cubit.showLoading)
                  Center(child: CircularProgressIndicator())
              ],
            ),
          );
        },
      ),
    );
  }
}
