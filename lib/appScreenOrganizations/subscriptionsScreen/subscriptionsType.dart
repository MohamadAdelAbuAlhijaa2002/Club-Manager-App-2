import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../bloc/Cubit.dart';
import '../../../bloc/states.dart';
import '../../ShortCutCode/shortCutCode.dart';
import '../../saveToken/saveToken.dart';
import 'editFunSub.dart';

class SubscriptionsType extends StatefulWidget {
  const SubscriptionsType({super.key});

  @override
  State<SubscriptionsType> createState() => _SubscriptionsTypeState();
}

class _SubscriptionsTypeState extends State<SubscriptionsType> {

  var role ;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
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
    final _formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    final note = TextEditingController();
    final name = TextEditingController();
    final price = TextEditingController();
    final numberDays = TextEditingController();
    final noteActionButton = TextEditingController();

    return BlocProvider(
      create: (context) => CubitApp()..getSubscriptionsType(),
      child: BlocConsumer<CubitApp, StatesApp>(
        listener: (context, state) {
          final cubit = CubitApp.get(context);
          if (state is AddSubscriptionsTypeState ||
              state is EditSubscriptionState ||
              state is AddSuspendSubscriptionsState) {
            cubit.getSubscriptionsType();
          }
        },
        builder: (context, state) {
          final cubit = CubitApp.get(context);

          void addSuspend({required String id}) {
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
                        const SizedBox(height: 20),
                        Text(
                          "تعليق الاشتراك",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InputText(
                          controller: note,
                          inputType: TextInputType.text,
                          prefixIcon: Icons.note_alt,
                          labelText: "ملاحظة",
                        ),
                        const SizedBox(height: 20),
                        Button(
                          title: "تم",
                          onPressed: () async {
                            await cubit.addSuspendSubscriptions(
                                note: note.text, subscriptions_id: id);

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  cubit.dataAddSuspendSubscriptions["message"],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: cubit
                                    .dataAddSuspendSubscriptions["status"] ==
                                    "success"
                                    ? theme.primaryColor
                                    : Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,

              title: Text(
                "أنواع الاشتراكات",
                style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white),
              ),
              centerTitle: true,
              foregroundColor: Colors.white,
              backgroundColor: theme.primaryColor,
              elevation: 8,
            ),
            body: SafeArea(
              child: cubit.dataSubscriptionsType.isEmpty
                  ? Center(
                child: Text(
                  "لا توجد اشتراكات",
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
                  itemCount: cubit.dataSubscriptionsType.length,
                  itemBuilder: (context, i) {
                    final subscription = cubit.dataSubscriptionsType[i];
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
                            key: ValueKey(subscription["id"]),
                            endActionPane: ActionPane(
                              motion: const BehindMotion(),
                              extentRatio: 0.7,
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    addSuspend(
                                        id: subscription["id"].toString());
                                  },
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue,
                                  icon: Icons.stop_circle_outlined,
                                  label: 'تعليق',
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                SlidableAction(
                                  onPressed: (context) {
                                    editSubscription(
                                        context: context,
                                        id: subscription["id"]);
                                  },
                                  backgroundColor: Colors.white,
                                  foregroundColor: theme.primaryColor,
                                  icon: Icons.edit,
                                  label: 'تعديل',
                                  borderRadius: BorderRadius.circular(15),
                                ),
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
                                        color: theme.primaryColor,
                                        borderRadius:
                                        BorderRadius.circular(5),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        subscription["name"] ?? "",
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
                                        color: theme.primaryColor,
                                        size: 24.sp,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20),
                                            ),
                                            title: Center(
                                              child: Text(
                                                "تفاصيل الاشتراك",
                                                style: TextStyle(
                                                  color: theme.primaryColor,
                                                  fontSize: 18.sp,
                                                ),
                                              ),
                                            ),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize:
                                                MainAxisSize.min,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  _buildDetailRow(
                                                      label: ":الاسم ",
                                                      value: subscription[
                                                      "name"]
                                                          .toString()),
                                                  _buildDetailRow(
                                                      label: ":السعر ",
                                                      value:
                                                      "${subscription["price"]} ${subscription["currency"]}"),
                                                  _buildDetailRow(
                                                      label: ":عدد الأيام ",
                                                      value: subscription[
                                                      "number_days"]
                                                          .toString()),
                                                  _buildDetailRow(
                                                      label: ":تاريخ الإنشاء ",
                                                      value: subscription[
                                                      "create_at"]
                                                          .toString()),
                                                  _buildDetailRow(
                                                      label: ":ملاحظة ",
                                                      value: subscription[
                                                      "note"]
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
                                                      color: theme.primaryColor),
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
            ),


            floatingActionButton:    role == "admin" ?
          FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
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
                                "إضافة نوع اشتراك",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              InputText(
                                controller: name,
                                inputType: TextInputType.text,
                                prefixIcon: Icons.person,
                                labelText: "الاسم",
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'الرجاء إدخال الاسم';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.h),
                              InputText(
                                controller: price,
                                inputType: TextInputType.number,
                                prefixIcon: CupertinoIcons.money_dollar_circle,
                                labelText: "السعر",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال السعر';
                                  }
                                  // تحقق أن القيمة رقمية
                                  final number = double.tryParse(value);
                                  if (number == null) {
                                    return 'الرجاء إدخال رقم صالح';
                                  }
                                  if (number <= 0) {
                                    return 'الرجاء إدخال رقم أكبر من صفر';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 10.h),
                              InputText(
                                controller: numberDays,
                                inputType: TextInputType.number,
                                prefixIcon: CupertinoIcons.calendar,
                                labelText: "عدد الأيام",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال عدد الأيام';
                                  }
                                  final number = int.tryParse(value);
                                  if (number == null) {
                                    return 'الرجاء إدخال رقم صحيح';
                                  }
                                  if (number <= 0) {
                                    return 'عدد الأيام يجب أن يكون أكبر من صفر';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 10.h),
                              InputText(
                                controller: noteActionButton,
                                inputType: TextInputType.text,
                                prefixIcon: Icons.note_alt_outlined,
                                labelText: "ملاحظة",
                              ),
                              SizedBox(height: 20.h),
                              Button(
                                title: "إضافة",
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    cubit.showLoadingFun(i: true);
                                    await cubit.addSubscriptionsType(
                                        note: noteActionButton.text,
                                        name: name.text,
                                        numberDays: numberDays.text,
                                        price: price.text);
                                    Navigator.pop(context);
                                    cubit.showLoadingFun(i: false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          cubit.dataAddSubscriptionsType["message"],
                                          textAlign: TextAlign.center,
                                          style:
                                          const TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: theme.primaryColor,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
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
              backgroundColor: theme.primaryColor,
              child: Icon(Icons.add, size: 30, color: Colors.white),
            ):
          null,
          );
        },
      ),
    );
  }
}
