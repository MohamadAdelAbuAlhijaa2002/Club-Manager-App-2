import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../bloc/Cubit.dart';
import '../../../bloc/states.dart';
import '../../saveToken/saveToken.dart';

class SuspendScreen extends StatefulWidget {
  final int id_section;

  SuspendScreen({super.key, required this.id_section});
  @override
  State<SuspendScreen> createState() => _SuspendScreenState();
}

class _SuspendScreenState extends State<SuspendScreen> {
  late int id_section;

    var role ;
  @override
  void initState() {

    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((_) async{
      id_section = widget.id_section;

      final cubit = CubitApp.get(context);
      cubit.getSuspendSubscriptionsData();
      cubit.getSuspendMembersData(section_id: id_section );
      role = (await getRoleOrganization())!;
    });
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CubitApp, StatesApp>(
      listener: (context, state) {
        if (state is StopSuspendMembersState || state is StopSuspendSubscriptionsState ||
         state is DeleteMemberDataState || state is DeleteSubscriptionsTypeDataState) {
          final cubit = CubitApp.get(context);
          cubit.getSuspendMembersData(section_id: id_section );
          cubit.getSuspendSubscriptionsData();
        }
      },
      builder: (context, state) {
        final messenger = ScaffoldMessenger.of(context);

        final cubit = CubitApp.get(context);
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                "المعلّق",
                style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white),
              ),
              centerTitle: true,
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 8,
              //automaticallyImplyLeading: false,
              bottom: TabBar(
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.person, color: Colors.white),
                    text: 'الأعضاء',
                  ),
                  Tab(
                    icon: Icon(Icons.subscriptions_rounded, color: Colors.white),
                    text: 'الاشتراكات',
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: TabBarView(
                children: [
                  // ---------- الأعضاء ----------
                  cubit.dataSuspendMembers.isEmpty
                      ? Center(
                    child: Text(
                      "لا توجد بيانات أعضاء معلّقة",
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.grey,
                      ),
                    ),
                  )
                      : AnimationLimiter(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      physics: const BouncingScrollPhysics(),
                      itemCount: cubit.indexSuspendMembers,
                      itemBuilder: (context, i) {
                        return AnimationConfiguration.staggeredList(
                          position: i,
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
                              child: Slidable(
                                key: ValueKey(cubit.dataSuspendMembers[i]["id"]),
                                endActionPane: ActionPane(
                                  motion: const BehindMotion(),
                                  extentRatio: 0.7,
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) async {
                                        await cubit.stopSuspendMembers(
                                            id: cubit.dataSuspendMembers[i]["id"]);

                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              cubit.dataStopSuspendMembers["message"],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Colors.white),

                                            ),
                                          ),
                                        );
                                      },
                                      backgroundColor: Colors.white,
                                      foregroundColor: Theme.of(context).primaryColor,
                                      icon: Icons.stop_circle,
                                      label: 'إيقاف',
                                      borderRadius: BorderRadius.circular(15),
                                    ),


                                   if(role == "admin")
                                    SlidableAction(
                                      onPressed: (context) async {
                                        print(role);


                                        print(cubit.dataSuspendMembers[i]["id_members"]);

                                        await cubit.deleteMemberData(id_member: cubit.dataSuspendMembers[i]["id_members"].toString() ) ;


                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              cubit.dataDeleteMember["message"],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Colors.white),

                                            ),
                                          ),
                                        );
                                      },
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.red,
                                      icon: Icons.delete,
                                      label: 'حذف',
                                      borderRadius: BorderRadius.circular(15),
                                    )
                                  ],
                                ),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 16.h),
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
                                  child: Padding(
                                    padding: EdgeInsets.all(16.w),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10.w,
                                          height: 30.h,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Text(
                                            "${cubit.dataSuspendMembers[i]["member_name"]}",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.info_outline,
                                            color: Theme.of(context).primaryColor,
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
                                                    "تفاصيل العضو",
                                                    style: TextStyle(
                                                      color:
                                                      Theme.of(context).primaryColor,
                                                      fontSize: 18.sp,
                                                    ),
                                                  ),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      _buildDetailRow(
                                                          label: ":الاسم  ",
                                                          value: cubit.dataSuspendMembers[i]
                                                          ["member_name"]
                                                              .toString()),
                                                      _buildDetailRow(
                                                          label: ":تم الإنشاء بواسطة  ",
                                                          value: cubit.dataSuspendMembers[i]
                                                          ["manager_name"]
                                                              .toString()),
                                                      _buildDetailRow(
                                                          label: ":تاريخ الإنشاء  ",
                                                          value: cubit.dataSuspendMembers[i]
                                                          ["created_at"]
                                                              .toString()),
                                                      _buildDetailRow(
                                                          label: ":ملاحظة  ",
                                                          value: cubit.dataSuspendMembers[i]
                                                          ["note"]
                                                              .toString()),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                      "إغلاق",
                                                      style: TextStyle(
                                                          color: Theme.of(context)
                                                              .primaryColor),
                                                    ),
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
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ---------- الاشتراكات ----------
                  cubit.dataSuspendSubscriptions.isEmpty
                      ? Center(
                    child: Text(
                      "لا توجد بيانات اشتراكات معلّقة",
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.grey,
                      ),
                    ),
                  )
                      : AnimationLimiter(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      physics: const BouncingScrollPhysics(),
                      itemCount: cubit.indexSuspendSubscriptions,
                      itemBuilder: (context, i) {
                        return AnimationConfiguration.staggeredList(
                          position: i,
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
                              child: Slidable(
                                key:
                                ValueKey(cubit.dataSuspendSubscriptions[i]["id"]),
                                endActionPane: ActionPane(
                                  motion: const BehindMotion(),
                                  extentRatio: 0.7,
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) async {
                                        await cubit.stopSuspendSubscriptions(
                                            id: cubit.dataSuspendSubscriptions[i]["id"]);

                                        final message =
                                        cubit.dataStopSuspendSubscriptions["message"];
                                        final isSuccess = cubit.dataStopSuspendSubscriptions["status"] == "success";

                                        if(isSuccess){
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                message,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: Colors.white),

                                              ),
                                            ),
                                          );
                                        }else{
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                message,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: Colors.white),

                                              ),

                                              backgroundColor:  Colors.red,

                                            ),

                                          );
                                        }




                                      },
                                      backgroundColor: Colors.white,
                                      foregroundColor: Theme.of(context).primaryColor,
                                      icon: Icons.stop_circle,
                                      label: 'إيقاف',
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    if(role == "admin")

                                      SlidableAction(
                                      onPressed: (context) async {



                                       await  cubit.deleteSubscriptionsTypeData(id_subscriptions_type: cubit.dataSuspendSubscriptions[i]["id_subscriptions"].toString()) ;


                                        if (cubit.dataDeleteSubscriptionsType["status"] == "success") {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                cubit.dataDeleteSubscriptionsType["message"],
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          );
                                        }else{
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                cubit.dataDeleteSubscriptionsType["message"],
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                              backgroundColor: Colors.red,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              duration: const Duration(seconds: 3),
                                            ),
                                          );
                                        }





                                      },


                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.red,
                                      icon: Icons.delete,
                                      label: 'حذف',
                                      borderRadius: BorderRadius.circular(15),
                                    )

                                  ],
                                ),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 16.h),
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
                                  child: Padding(
                                    padding: EdgeInsets.all(16.w),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10.w,
                                          height: 30.h,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Text(
                                            "${cubit.dataSuspendSubscriptions[i]["subscriptions_name"]}",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.info_outline,
                                            color: Theme.of(context).primaryColor,
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
                                                    "تفاصيل الاشتراك",
                                                    style: TextStyle(
                                                      color:
                                                      Theme.of(context).primaryColor,
                                                      fontSize: 18.sp,
                                                    ),
                                                  ),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      _buildDetailRow(
                                                          label: ":الاسم ",
                                                          value: cubit
                                                              .dataSuspendSubscriptions[
                                                          i]
                                                          ["subscriptions_name"]
                                                              .toString()),
                                                      _buildDetailRow(
                                                          label: ":تم الإنشاء بواسطة ",
                                                          value: cubit
                                                              .dataSuspendSubscriptions[
                                                          i]
                                                          ["organization_managers_name"]
                                                              .toString()),
                                                      _buildDetailRow(
                                                          label: ":تاريخ الإنشاء  ",
                                                          value: cubit
                                                              .dataSuspendSubscriptions[
                                                          i]["created_at"]
                                                              .toString()),
                                                      _buildDetailRow(
                                                          label: ":ملاحظة  ",
                                                          value: cubit
                                                              .dataSuspendSubscriptions[
                                                          i]["note"]
                                                              .toString()),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                      "إغلاق",
                                                      style: TextStyle(
                                                          color: Theme.of(context)
                                                              .primaryColor),
                                                    ),
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
                              ),
                            ),
                          ),
                        );
                      },
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
