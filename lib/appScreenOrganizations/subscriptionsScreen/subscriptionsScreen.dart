import 'package:club_app_organizations_section/appScreenOrganizations/subscriptionsScreen/subscriptionsType.dart';
import 'package:club_app_organizations_section/appScreenOrganizations/subscriptionsScreen/threeScreenSubscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../ShortCutCode/shortCutCode.dart';
import '../../bloc/Cubit.dart';
import '../../bloc/states.dart';

class SubscriptionsScreen extends StatefulWidget {
  final int id_section;

  const SubscriptionsScreen({super.key, required this.id_section});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  late int id_section;

  @override
  void initState() {
    super.initState();
    id_section = widget.id_section;

    final cubit = CubitApp.get(context);
    cubit.getSubscriptionsMember(section_id: id_section);
    cubit.getSubscriptionsType();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<CubitApp, StatesApp>(
      listener: (context, state) {
        if (state is AddSubscriptionsMembersState) {
          final cubit = CubitApp.get(context);
          cubit.getSubscriptionsMember(section_id: id_section);
          cubit.getSubscriptionsType();
        }
      },
      builder: (context, state) {
        final cubit = CubitApp.get(context);

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              title: Text(
                "الاشتراكات",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              backgroundColor: theme.primaryColor,
              elevation: 6,
              //automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () {
                    NavigatorMethod(
                        context: context, screen: const SubscriptionsType());
                  },
                  icon: const Icon(Icons.subscriptions_outlined, color: Colors.white),
                ),
              ],
              bottom: TabBar(
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle: TextStyle(
                  fontSize: 8.sp, // تقليل الحجم
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.check_circle, color: Colors.green, size: 20), // تقليل حجم الأيقونة
                    text: 'نشط',
                  ),
                  Tab(
                    icon: Icon(Icons.pause_circle, color: Colors.orange, size: 20),
                    text: 'غير نشط',
                  ),
                  Tab(
                    icon: Icon(Icons.cancel, color: Colors.grey, size: 20),
                    text: 'غير مشترك',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // تبويب الاشتراكات النشطة
                active(
                  context: context,
                  data: cubit.dataSubscriptionsMemberActive,
                  index: cubit.indexSubscriptionsMemberActive,
                ),
                // تبويب الاشتراكات غير النشطة
                inactive(
                  context: context,
                  data: cubit.dataSubscriptionsMemberNonActive,
                  index: cubit.indexSubscriptionsMemberNonActive,
                ),
                // تبويب الأعضاء غير المشتركين
                nonSubscription(
                  context: context,
                  data: cubit.dataSubscriptionsMemberNonSubscribed,
                  index: cubit.indexSubscriptionsMemberNonSubscribed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
