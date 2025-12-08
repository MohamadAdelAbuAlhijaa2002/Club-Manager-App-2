import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../bloc/Cubit.dart';
import '../../ShortCutCode/shortCutCode.dart';

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
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28.sp, color: color ?? theme.primaryColor),
          SizedBox(width: 16.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, size: 18.sp, color: Colors.grey),
        ],
      ),
    ),
  );
}

Future edit({context, id}) {
  final name = TextEditingController();
  final phone = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();

  final theme = Theme.of(context);
  final formKey = GlobalKey<FormState>();
  var cubit = CubitApp.get(context);

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          "تعديل بيانات العضو",
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18.sp),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- تعديل الاسم ----------------
            _buildSettingButton(
              context,
              icon: Icons.person,
              text: "تعديل الاسم",
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        top: 20,
                        left: 20,
                        right: 20,
                      ),
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            spacing: 10.h,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 50,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                "تعديل الاسم",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              InputText(
                                controller: name,
                                inputType: TextInputType.name,
                                prefixIcon: Icons.person,
                                labelText: "الاسم",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال الاسم';
                                  }
                                  if (value.length < 2) {
                                    return 'الاسم يجب أن يحتوي على حرفين على الأقل';
                                  }

                                  return null;
                                },
                              ),
                              Button(
                                title: "تعديل",
                                onPressed: () async {
                                  bool connected = await checkInternet(
                                      context: context);


                                  if (formKey.currentState!.validate() && connected) {
                                    await cubit.editNameMembers(Members_id: id, name: name.text);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // ---------------- تعديل رقم الهاتف ----------------
            _buildSettingButton(
              context,
              icon: Icons.phone,
              text: "تعديل رقم الهاتف",
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        top: 20,
                        left: 20,
                        right: 20,
                      ),
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            spacing: 10.h,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 50,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                "تعديل رقم الهاتف",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              InputText(
                                controller: phone,
                                inputType: TextInputType.phone,
                                prefixIcon: Icons.phone,
                                labelText: "رقم الهاتف",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال رقم الهاتف';
                                  }
                                  for (int i = 0; i < value.length; i++) {
                                    if (value[i].contains(RegExp(r'[A-Za-z]'))) {
                                      return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
                                    }
                                    if (value[i].contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                                      return 'رقم الهاتف لا يجب أن يحتوي على رموز';
                                    }
                                  }
                                  if (value.length != 10) {
                                    return 'رقم الهاتف يجب أن يتكون من 10 أرقام فقط';
                                  }
                                  return null;
                                },
                              ),
                              Button(
                                title: "تعديل",
                                onPressed: () async {
                                  bool connected = await checkInternet(
                                      context: context);
                                  if (formKey.currentState!.validate() && connected) {
                                    await cubit.editPhoneMembers(Members_id: id, phone: phone.text);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // ---------------- تعديل الطول ----------------
            _buildSettingButton(
              context,
              icon: Icons.height,
              text: "تعديل الطول",
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        top: 20,
                        left: 20,
                        right: 20,
                      ),
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            spacing: 10.h,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 50,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                "تعديل الطول",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              InputText(
                                controller: height,
                                inputType: TextInputType.number,
                                prefixIcon: Icons.height,
                                labelText: "الطول (سم)",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال الطول';
                                  }
                                  for (int i = 0; i < value.length; i++) {
                                    if (value[i].contains(RegExp(r'[A-Za-z]'))) {
                                      return 'الطول يجب أن يحتوي على أرقام فقط';
                                    }
                                    if (value[i].contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                                      return 'الطول لا يجب أن يحتوي على رموز';
                                    }
                                  }
                                  double? h = double.tryParse(value);
                                  if (h == null) return 'الرجاء إدخال رقم صحيح للطول';
                                  if (h < 50 || h > 300) {
                                    return 'الطول يجب أن يكون بين 50 و 300 سم';
                                  }
                                  return null;
                                },
                              ),
                              Button(
                                title: "تعديل",
                                onPressed: () async {
                                  bool connected = await checkInternet(
                                      context: context);
                                  if (formKey.currentState!.validate() && connected) {
                                    await cubit.editHeightMembers(Members_id: id, height: height.text);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // ---------------- تعديل الوزن ----------------
            _buildSettingButton(
              context,
              icon: Icons.monitor_weight_sharp,
              text: "تعديل الوزن",
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        top: 20,
                        left: 20,
                        right: 20,
                      ),
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            spacing: 10.h,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 50,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                "تعديل الوزن",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              InputText(
                                controller: weight,
                                inputType: TextInputType.number,
                                prefixIcon: Icons.monitor_weight_sharp,
                                labelText: "الوزن (كغ)",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال الوزن';
                                  }
                                  for (int i = 0; i < value.length; i++) {
                                    if (value[i].contains(RegExp(r'[A-Za-z]'))) {
                                      return 'الوزن يجب أن يحتوي على أرقام فقط';
                                    }
                                    if (value[i].contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                                      return 'الوزن لا يجب أن يحتوي على رموز';
                                    }
                                  }
                                  double? w = double.tryParse(value);
                                  if (w == null) return 'الرجاء إدخال رقم صحيح للوزن';
                                  if (w < 20 || w > 500) {
                                    return 'الوزن يجب أن يكون بين 20 و 500 كغ';
                                  }
                                  return null;
                                },
                              ),
                              Button(
                                title: "تعديل",
                                onPressed: () async {
                                  bool connected = await checkInternet(
                                      context: context);
                                  if (formKey.currentState!.validate() && connected) {
                                    await cubit.editWeightMembers(Members_id: id, weight: weight.text);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("إغلاق", style: TextStyle(color: theme.primaryColor)),
        ),
      ],
    ),
  );
}
