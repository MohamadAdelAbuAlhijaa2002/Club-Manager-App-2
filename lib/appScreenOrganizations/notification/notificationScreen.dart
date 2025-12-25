import 'package:club_app_organizations_section/ShortCutCode/shortCutCode.dart';
import 'package:club_app_organizations_section/appScreenOrganizations/sectionsScreen/sectionsScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../bloc/Cubit.dart';
import '../../bloc/states.dart';

class NotificationScreen extends StatefulWidget {
  static const String routeName = "/notification";
  // final RemoteMessage message;

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   CubitApp.get(context).getMembersData(section_id: id_section );
    // });
    CubitApp.get(context).getNotificationData();
  }

  Widget build(BuildContext context) {
    final _w = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return BlocConsumer<CubitApp, StatesApp>(
      listener: (BuildContext context, StatesApp state) {

      },
      builder: (BuildContext context, StatesApp state) {
        final cubit = CubitApp.get(context);


        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text(
              "الاشعارات",
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
            child: cubit.dataNotification.isEmpty
                ? Center(
              child: Text(
                "لا يوجد اشعارات",
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
                itemCount: cubit.indexDataNotification,
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
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {},
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active,
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
                                          cubit.dataNotification[index]["body"],
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
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
                                                "تفاصيل الاشعار",
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
                                                _buildDetailRow(label: "التفاصيل:", value: cubit.dataNotification[index]["body"].toString()),
                                                _buildDetailRow(label: "اسم العضو:", value: cubit.dataNotification[index]["member_name"].toString()),
                                                _buildDetailRow(label: "القسم:", value: cubit.dataNotification[index]["section_name"].toString()),
                                                _buildDetailRow(label: "رقم الهاتف:", value: cubit.dataNotification[index]["member_phone"].toString()),
                                                _buildDetailRow(label: "تاريخ الانتهاء:", value: cubit.dataNotification[index]["end_date"].toString()),

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
                  );
                },
              ),
            ),
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
