import 'dart:io';
import 'package:club_app_organizations_section/appScreenOrganizations/loginScren/loginScreen.dart';
import 'package:club_app_organizations_section/appScreenOrganizations/sectionsScreen/editSection.dart';
import 'package:club_app_organizations_section/appScreenOrganizations/settingScreen/settingScreen.dart';
import 'package:club_app_organizations_section/appScreenOrganizations/notification/notificationScreen.dart';
import 'package:club_app_organizations_section/saveToken/saveToken.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../ShortCutCode/shortCutCode.dart';
import '../../bloc/Cubit.dart';
import '../../bloc/states.dart';
import '../Managers/managers.dart';
import '../homePage/homePage.dart';
import '../homeScreen/editMembers.dart';

class SectionScreen extends StatefulWidget {

  @override

  State<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  DateTime? berthDateMembers;
  var role = "";


  @override
  void initState() {
    super.initState();

    // سيطبع دائمًا عند دخول الصفحة
    print("Page entered");

    // نفّذ العمليات بعد اكتمال بناء الـ Widget
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      await CubitApp.get(context).checkTokenData();
      if(!CubitApp.get(context).dataCheckToken){
        await deleteTokenOrganization();
        NavigatorMethod(context: context, screen: LoginScreen());


      }else {
        await CubitApp.get(context).getSectionData();
        await CubitApp.get(context).getNotificationData();

        role = (await getRoleOrganization())!;
        await CubitApp.get(context).checkSubscriptions(context: context);


        if (role == "admin") {
          print("doneeeeeeeeeeeeeeeeeeeeeee${CubitApp
              .get(context)
              .checkSubscriptionsBool}");
          await CubitApp.get(context).getManagersData();
          if (CubitApp
              .get(context)
              .dataManagers
              .isEmpty) {
            NavigatorMethod(context: context, screen: Managers());
          }
        }


        print("Managers empty? : ${CubitApp
            .get(context)
            .dataManagers
            .isEmpty}");
      }
    });
  }


  Widget build(BuildContext context) {
    final _w = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final title = TextEditingController();
    final description = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    Map<String, dynamic>? selectedManager;

    return BlocConsumer<CubitApp, StatesApp>(
      listener: (BuildContext context, StatesApp state) {
        if (state is AddMembersDataState ||
            state is EditMembersState ||
            state is AddSuspendMembersState||state is EditSectionTitleState||state is EditSectionDescriptionState||state is EditSectionResponsibleState||
            state is AddSectionDataState) {
          CubitApp.get(context).getSectionData();
        }
      },
      builder: (BuildContext context, StatesApp state) {
        final cubit = CubitApp.get(context);
        DateTime? lastPressed; // لتخزين وقت آخر كبسة

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
              return false;
            }

            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else {
              exit(0);
            }
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              title: Text(
                "الاقسام",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  color: Colors.white,
                ),
              ),

              actions: [




                IconButton(
                  onPressed: () {

                    NavigatorMethod(context: context, screen: NotificationScreen());
                  },
                  icon: Stack(
                    clipBehavior: Clip.none, // مهم للسماح للعداد بالخروج خارج حدود الأيقونة
                    children: [
                      // أيقونة الجرس
                      Container(
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),


                      // عداد الإشعارات
                      if (cubit.indexDataNotification > 0)
                        Positioned(
                          right: cubit.indexDataNotification>10 ?-12: -2, // إزاحة العدّاد قليلاً خارج الأيقونة
                          top: -6,   // إزاحة العدّاد قليلاً إلى الأعلى
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              "${cubit.indexDataNotification>10 ?"+10" : cubit.indexDataNotification}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),







                IconButton(onPressed: (){
                  NavigatorMethod(context: context, screen: SettingScreens());
                }, icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 30,
                )),





              ],



              leading: role == "admin"
                  ? IconButton(
                onPressed: () {
                  // ضع هنا الكود الذي تريده عند الضغط
                  print(role);
                  NavigatorMethod(context: context, screen: Managers());
                },
                icon: Icon(
                  Icons.list,
                  color: Colors.white,
                  size: 30,
                ),
              )
                  : null,


              centerTitle: true,
              elevation: 0,
              backgroundColor: theme.primaryColor,
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
              child: cubit.dataSection.isEmpty
                  ? Center(
                child: Text(
                  "لا يوجد اقسام",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                physics: const BouncingScrollPhysics(),
                itemCount: cubit.indexSection,
                itemBuilder: (context, index) {
                  final section = cubit.dataSection[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        NavigatorMethod(
                            context: context,
                            screen: HomePage(id_section: section["id"]));
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.folder,
                              size: 28.sp,
                              color: theme.primaryColor,
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    section["title"],
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    section["description"],
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: Center(
                                      child: Text(
                                        "تفاصيل القسم",
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildDetailRow(
                                            label: ":العنوان",
                                            value: section["title"]),
                                        _buildDetailRow(
                                            label: ":التفاصيل",
                                            value: section["description"]),
                                        _buildDetailRow(
                                            label: ":تاريخ الإضافة",
                                            value: section["create_at"]),
                                        _buildDetailRow(
                                            label: ":اسم المنشئ",
                                            value: section["manager_name"]),
                                        _buildDetailRow(
                                            label: ":اسم المسؤول عن القسم",
                                            value: section["responsible_name"]),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          "إغلاق",
                                          style: TextStyle(color: theme.primaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),





            floatingActionButton:   role == "admin" ?
           FloatingActionButton(
              onPressed: () {
                if (CubitApp.get(context).dataManagers.isEmpty) {
                  // حالة لا يوجد Managers: عرض Dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Center(
                          child: Text(
                            "تنبيه",
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        content: Text(
                          "الرجاء إضافة مدير أولاً لإنشاء هذا القسم",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        actions: [
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                NavigatorMethod(context: context, screen: Managers()); // لإغلاق الـ Dialog
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "حسناً",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );









                } else {
                  // حالة يوجد Managers: عرض ModalBottomSheet
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
                                  "إضافة عضو",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                InputText(
                                  controller: title,
                                  inputType: TextInputType.text,
                                  prefixIcon: Icons.title,
                                  labelText: "العنوان",
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء إدخال العنوان';
                                    }
                                    if (value.length < 2) {
                                      return 'العنوان يجب أن يحتوي على حرفين على الأقل';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10.h),
                                InputText(
                                  controller: description,
                                  inputType: TextInputType.text,
                                  prefixIcon: Icons.description,
                                  labelText: "التفاصيل",
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء إدخال التفاصيل';
                                    }
                                    if (value.length < 2) {
                                      return 'التفاصيل يجب أن يحتوي على حرفين على الأقل';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20.h),



                                DropdownInput(
                                  labelText: "اختر المدير المسؤول",
                                  prefixIcon: Icons.person,
                                  itemsList: cubit.dataManagers,
                                  selectedValue: selectedManager,
                                  onChanged: (value) {
                                    selectedManager = value;
                                  },
                                  validator: (value) {
                                    if (selectedManager == null) {
                                      return 'الرجاء اختيار المدير المسؤول';
                                    }
                                    return null;
                                  },
                                ),





                                SizedBox(height: 20.h),
                                Button(
                                  title: "إضافة",
                                  onPressed: () async {


                                    print(selectedManager == null);

                                    if (_formKey.currentState!.validate()) {
                                      cubit.showLoadingFun(i: true);

                                      await cubit.addSectionData(
                                        des: description.text,
                                        title: title.text,
                                        id_managers: selectedManager!["id"].toString()
                                      );

                                      cubit.showLoadingFun(i: false);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            cubit.dataAddSection["message"],
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

                                      if (cubit.dataAddSection["status"] == "success") {
                                        Navigator.pop(context);
                                      }
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
                }
              },
              backgroundColor: theme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ) :

            null,









          ),
        );
      },
    );
  }



  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isColumn = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: isColumn
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // يشغل كامل العرض
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.end, // محاذاة النص لليمين
          ),
          SizedBox(height: 4.h),
          Text(
            value.isNotEmpty ? value : "غير متوفر",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.end, // محاذاة النص لليمين
          ),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
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
            label,
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

