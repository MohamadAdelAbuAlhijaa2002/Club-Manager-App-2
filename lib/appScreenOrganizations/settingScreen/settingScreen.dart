import 'package:club_app_organizations_section/bloc/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../bloc/Cubit.dart';
import '../../ShortCutCode/shortCutCode.dart';

class SettingScreens extends StatelessWidget {
  const SettingScreens({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formKey = GlobalKey<FormState>();

    return BlocProvider(
      create: (BuildContext context) => CubitApp()..getInfoOrganization(),
      child: BlocConsumer<CubitApp, StatesApp>(
        listener: (BuildContext context, state) {},
        builder: (BuildContext context, Object? state) {
          final cubit = CubitApp.get(context);
          final nameController = TextEditingController();
          final emailController = TextEditingController();
          final newPasswordController = TextEditingController();
          final currentPasswordController = TextEditingController();
          final passwordForEmailController = TextEditingController();
          final passwordForNameController = TextEditingController();

          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: Stack(
              children: [
                // تصميم الخلفية
                Positioned(
                  top: -90.h,
                  left: -90.w,
                  child: Container(
                    width: 240.w,
                    height: 240.w,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 60.h,
                  right: -60.w,
                  child: Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // المحتوى الرئيسي
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            SizedBox(height: 40.h),
                            Text(
                              'الإعدادات',
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 40.h),
                            AnimationLimiter(
                              child: Column(
                                children: AnimationConfiguration.toStaggeredList(
                                  duration: const Duration(milliseconds: 500),
                                  childAnimationBuilder: (widget) => SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(child: widget),
                                  ),
                                  children: [
                                    _buildSettingButton(
                                      context,
                                      icon: Icons.person_outline,
                                      text: "معلوماتي",
                                      onTap: () async {
                                        await cubit.getInfoOrganization();
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              title: Center(
                                                child: Text(
                                                  "بياناتي الشخصية",
                                                  style: TextStyle(color: theme.primaryColor),
                                                ),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _buildDetailRow(label: ":الاسم", value: "${cubit.dataInfoOrganization["manager"]["name"]}"),
                                                  _buildDetailRow(label:":اسم النادي", value: "${cubit.dataInfoOrganization["manager"]["organization_name"]}"),
                                                  _buildDetailRow(label:":البريد الإلكتروني", value: "${cubit.dataInfoOrganization["manager"]["email"]}"),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 20),
                                                    child: Center(
                                                      child: Text(
                                                        "الاشتراكات الخاصة بي",
                                                        style: TextStyle(color: theme.primaryColor),
                                                      ),
                                                    ),
                                                  ),
                                                  _buildDetailRow(label: ":حالة الاشتراك", value: "${cubit.dataInfoOrganization["manager"]["subscription_status"]}"),
                                                  if ("${cubit.dataInfoOrganization["manager"]["subscription_status"]}" != "non_subscription")
                                                    _buildDetailRow(label: ":تاريخ البداية", value: "${cubit.dataInfoOrganization["manager"]["subscriptions"][0]["start_date"]}"),
                                                  if ("${cubit.dataInfoOrganization["manager"]["subscription_status"]}" != "non_subscription")
                                                    _buildDetailRow(label: ":تاريخ الانتهاء", value: "${cubit.dataInfoOrganization["manager"]["subscriptions"][0]["end_date"]}"),
                                                  if ("${cubit.dataInfoOrganization["manager"]["subscription_status"]}" == "active")
                                                    _buildDetailRow(
                                                        label: ":السعر",
                                                        value: "${cubit.dataInfoOrganization["manager"]["subscriptions"][0]["price"]} ${cubit.dataInfoOrganization["manager"]["subscriptions"][0]["currency"]}"),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: Text("إغلاق", style: TextStyle(color: theme.primaryColor)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    SizedBox(height: 40.h),
                                    _buildSettingButton(
                                      context,
                                      icon: Icons.person_outline,
                                      text: "تعديل الاسم الشخصي",
                                      onTap: () => _showEditNameBottomSheet(
                                        context,
                                        formKey,
                                        nameController,
                                        passwordForNameController,
                                        cubit,
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    _buildSettingButton(
                                      context,
                                      icon: Icons.email_outlined,
                                      text: "تعديل البريد الإلكتروني",
                                      onTap: () => _showEditEmailBottomSheet(
                                        context,
                                        formKey,
                                        emailController,
                                        passwordForEmailController,
                                        cubit,
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    _buildSettingButton(
                                      context,
                                      icon: Icons.lock_outline,
                                      text: "تغيير كلمة المرور",
                                      onTap: () => _showChangePasswordBottomSheet(
                                        context,
                                        formKey,
                                        newPasswordController,
                                        currentPasswordController,
                                        cubit,
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    _buildSettingButton(
                                      context,
                                      icon: Icons.logout,
                                      text: "تسجيل الخروج",
                                      color: Colors.red,
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              title: Text(
                                                "تأكيد تسجيل الخروج",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.primaryColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              content: Text(
                                                "هل أنت متأكد أنك تريد تسجيل الخروج؟",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Colors.grey.shade700),
                                              ),
                                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: Text("لا", style: TextStyle(color: Colors.grey.shade600)),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async{
                                                    bool connected = await checkInternet(
                                                        context: context);
                                                    if(connected) {
                                                      await cubit.logOutOrganization(context: context);
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: theme.primaryColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: const Text("نعم", style: TextStyle(color: Colors.white)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required VoidCallback onTap,
        Color? color,
      }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28.sp, color: color ?? theme.primaryColor),
            SizedBox(width: 16.w),
            Text(
              text,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: color ?? Colors.black87),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 18.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // تعديل الاسم
  void _showEditNameBottomSheet(
      BuildContext context,
      GlobalKey<FormState> formKey,
      TextEditingController nameController,
      TextEditingController passwordController,
      CubitApp cubit) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)))),
                SizedBox(height: 20.h),
                Center(
                  child: Text("تعديل الاسم الشخصي", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                ),
                SizedBox(height: 20.h),
                InputText(
                  controller: nameController,
                  inputType: TextInputType.name,
                  prefixIcon: Icons.person_outline,
                  labelText: "الاسم الجديد",
                  validator: (value) {
                    if (value!.isEmpty) return 'الرجاء إدخال الاسم';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                InputText(
                  controller: passwordController,
                  inputType: TextInputType.visiblePassword,
                  prefixIcon: Icons.lock_outline,
                  labelText: "كلمة المرور الحالية",
                  validator: (value) {
                    if (value!.isEmpty) return 'الرجاء إدخال كلمة المرور';
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                Button(
                  title: "تحديث الاسم",
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await cubit.editNameOrganization(
                        name: nameController.text,
                        password: passwordController.text,
                      );
                      _handleUpdateResponse(context, cubit.dataEditNameOrganization, nameController, passwordController);
                    }
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // تعديل البريد الإلكتروني
  void _showEditEmailBottomSheet(
      BuildContext context,
      GlobalKey<FormState> formKey,
      TextEditingController emailController,
      TextEditingController passwordController,
      CubitApp cubit) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)))),
                SizedBox(height: 20.h),
                Center(
                  child: Text("تعديل البريد الإلكتروني", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                ),
                SizedBox(height: 20.h),
                InputText(
                  controller: emailController,
                  inputType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  labelText: "البريد الإلكتروني الجديد",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    } else if (!value.endsWith('@gmail.com')) {
                      return 'يجب أن ينتهي البريد بـ @gmail.com';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                InputText(
                  controller: passwordController,
                  inputType: TextInputType.visiblePassword,
                  prefixIcon: Icons.lock_outline,
                  labelText: "كلمة المرور الحالية",
                  validator: (value) {
                    if (value!.isEmpty) return 'الرجاء إدخال كلمة المرور';
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                Button(
                  title: "تحديث البريد الإلكتروني",
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await cubit.editEmailOrganization(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      _handleUpdateResponse(context, cubit.dataEditEmailOrganization, emailController, passwordController);
                    }
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // تغيير كلمة المرور
  void _showChangePasswordBottomSheet(
      BuildContext context,
      GlobalKey<FormState> formKey,
      TextEditingController newPasswordController,
      TextEditingController currentPasswordController,
      CubitApp cubit) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)))),
                SizedBox(height: 20.h),
                Center(
                  child: Text("تغيير كلمة المرور", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                ),
                SizedBox(height: 20.h),
                InputText(
                  controller: newPasswordController,
                  inputType: TextInputType.visiblePassword,
                  prefixIcon: Icons.lock_outline,
                  labelText: "كلمة المرور الجديدة",
                  validator: (value) {
                    if (value!.isEmpty) return 'الرجاء إدخال كلمة المرور الجديدة';
                    if (value.length < 6) return 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                InputText(
                  controller: currentPasswordController,
                  inputType: TextInputType.visiblePassword,
                  prefixIcon: Icons.lock_outline,
                  labelText: "كلمة المرور الحالية",
                  validator: (value) {
                    if (value!.isEmpty) return 'الرجاء إدخال كلمة المرور الحالية';
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                Button(
                  title: "تحديث كلمة المرور",
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await cubit.editPasswordOrganization(
                        password: newPasswordController.text,
                        passwordOld: currentPasswordController.text,
                      );
                      _handleUpdateResponse(context, cubit.dataEditPasswordOrganization, newPasswordController, currentPasswordController);
                    }
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleUpdateResponse(BuildContext context, Map<String, dynamic> response, TextEditingController controller1, TextEditingController controller2) {
    final theme = Theme.of(context);
    final isSuccess = response["status"] == "success";

    Navigator.pop(context);
    controller1.clear();
    controller2.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response["message"],
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isSuccess ? theme.primaryColor : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center ,
        children: [

          Expanded(
            child: Text(
              value.isNotEmpty ? value : "غير متوفر",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.end,

            ),
          ),
          SizedBox(width: 10.w),
          Text(
            "$label",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.end,
          ),

        ],
      ),
    );
  }

}
