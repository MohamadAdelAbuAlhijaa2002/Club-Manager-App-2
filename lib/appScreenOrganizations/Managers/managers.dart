import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../ShortCutCode/shortCutCode.dart';
import '../../bloc/Cubit.dart';
import '../../bloc/states.dart';

class Managers extends StatefulWidget {
  @override
  Managers({super.key });
  State<Managers> createState() => _ManagersState();
}

class _ManagersState extends State<Managers> {
  _ManagersState();

  DateTime? berthDateMembers;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
       CubitApp.get(context).getManagersData();
       await CubitApp.get(context).checkSubscriptions(context: context);

    });
  }

  Widget build(BuildContext context) {
    final _w = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();

    final _formKey = GlobalKey<FormState>();
    final messenger = ScaffoldMessenger.of(context);

    return BlocConsumer<CubitApp, StatesApp>(
      listener: (BuildContext context, StatesApp state) {
        if(state is AddManagersDataState || state is DeleteManagersDataState){
          CubitApp.get(context).getManagersData();


        }
      },
      builder: (BuildContext context, StatesApp state) {
        final cubit = CubitApp.get(context);


        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text(
              "المديرين",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: theme.primaryColor,
            //automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: cubit.dataManagers.isEmpty
                ? Center(
              child: Text(
                "لا يوجد مديرين",
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.grey,
                ),
              ),
            )
                : AnimationLimiter(
              child: ListView.builder(
                padding: EdgeInsets.all(_w / 30),
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                itemCount: cubit.dataManagers.length,
                itemBuilder: (BuildContext context, int index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    delay: const Duration(milliseconds: 100),
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.fastLinearToSlowEaseIn,
                      horizontalOffset: 30,
                      verticalOffset: 50.0,
                      child: FlipAnimation(
                        duration: const Duration(milliseconds: 2000),
                        curve: Curves.fastLinearToSlowEaseIn,
                        flipAxis: FlipAxis.y,
                        child: Container(
                          margin: EdgeInsets.only(bottom: _w / 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Slidable(
                            key: ValueKey(index),
                            startActionPane: ActionPane(
                              motion: const BehindMotion(),
                              extentRatio: 0.3,
                              children: [
                                SlidableAction(
                                  onPressed: (context) async{
                                    print(cubit.dataManagers[index]["id"]);
                                   await cubit.deleteManagersData(id_managers: cubit.dataManagers[index]["id"].toString());


                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          cubit.dataDeleteManagers["message"],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.purple.shade800,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );

                                  },
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.red,
                                  icon: Icons.delete,
                                  label: 'حذف',
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ],
                            ),






                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {},
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 30.sp,
                                      color: theme.primaryColor,
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cubit.dataManagers[index]
                                            ["name"],
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.info_outline,
                                        color: theme.primaryColor,
                                        size: 24.sp,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext context) {
                                            return AlertDialog(
                                              shape:
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                              ),
                                              title: Center(
                                                child: Text(
                                                  "تفاصيل العضو",
                                                  style: TextStyle(
                                                    color: theme
                                                        .primaryColor,
                                                  ),
                                                ),
                                              ),
                                              content: Column(
                                                mainAxisSize:
                                                MainAxisSize.min,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  _buildDetailRow(label:":الاسم", value: cubit.dataManagers[index]["name"].toString()),
                                                  _buildDetailRow(label:":البريد الالكتروني", value:cubit.dataManagers[index]["email"].toString()),
                                                  _buildDetailRow(label:":تاريخ الإنشاء",value: cubit.dataManagers[index]["created_at"].toString()),

                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context),
                                                  child: Text(
                                                    "إغلاق",
                                                    style: TextStyle(
                                                      color: theme
                                                          .primaryColor,
                                                    ),
                                                  ),
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
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),



          floatingActionButton: Stack(
            children: [
              FloatingActionButton(
                onPressed: ()
                {
                  showModalBottomSheet
                    (
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25.0)),
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
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
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
                                  SizedBox(height: 20.h),
                                  Text(
                                    "إضافة مدير",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),

                                  // الاسم
                                  InputText(
                                    controller: name,
                                    inputType: TextInputType.text,
                                    prefixIcon: Icons.person,
                                    labelText: "الاسم",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'الرجاء إدخال اسم العضو';
                                      }
                                      if (value.length < 2) {
                                        return 'الاسم يجب أن يحتوي على حرفين على الأقل';
                                      }

                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 10.h),

                                  InputText(
                                    controller: email,
                                    inputType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email,
                                    labelText: "البريد الإلكتروني",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'الرجاء إدخال البريد الإلكتروني';
                                      }

                                      // التحقق من التنسيق العام للبريد
                                      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'الرجاء إدخال بريد إلكتروني صحيح ينتهي بـ @gmail.com';
                                      }

                                      return null;
                                    },
                                  ),

                                  SizedBox(height: 10.h),

                                  InputText(
                                    controller: password,
                                    inputType: TextInputType.visiblePassword,
                                    prefixIcon: Icons.lock,
                                    labelText: "كلمة المرور",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'الرجاء إدخال كلمة المرور';
                                      }

                                      if (value.length < 8) {
                                        return 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل';
                                      }

                                      // حرف كبير
                                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                        return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';
                                      }

                                      // رقم
                                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                                        return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';
                                      }

                                      // رمز خاص
                                      if (!RegExp(r'[!@#\$%^&*(),-_.?":{}|<>]').hasMatch(value)) {
                                        return 'يجب أن تحتوي كلمة المرور على رمز خاص واحد على الأقل';
                                      }

                                      return null;
                                    },
                                  ),

                                  SizedBox(height: 20.h),

                                  // زر الإضافة
                                  Button(
                                    title: "إضافة",
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        cubit.showLoadingFun(i: true);




                                        await cubit.addManagersData(
                                          name: name.text,
                                         email: email.text,
                                          password: password.text
                                        );

                                        cubit.showLoadingFun(i: false);

                                      messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              cubit.dataAddManagers["message"],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                            backgroundColor: Colors.purple.shade800,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            duration: const Duration(seconds: 3),
                                          ),
                                        );

                                          Navigator.pop(context);

                                      }
                                    },
                                  ),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                            ),
                          )

                      );
                    },
                  );
                },
                backgroundColor: theme.primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        );
      },
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

