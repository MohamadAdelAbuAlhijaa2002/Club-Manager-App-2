import 'package:club_app_organizations_section/appScreenOrganizations/homeScreen/homeScreen.dart';
import 'package:club_app_organizations_section/appScreenOrganizations/sectionsScreen/sectionsScreen.dart';
import 'package:club_app_organizations_section/appScreenOrganizations/subscriptionsScreen/subscriptionsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../ShortCutCode/shortCutCode.dart';
import '../../bloc/Cubit.dart';
import '../../bloc/states.dart';
import '../../saveToken/saveToken.dart';
import '../MassageScreen/MassageScreen.dart';
import '../Suspend/Suspend.dart';
import '../loginScren/loginScreen.dart';

class HomePage extends StatefulWidget {
  final int id_section;

  const HomePage({super.key, required this.id_section});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late int id_section;
  int currentIndex = 0;
  late List<Widget> screens;

  final List<IconData> listOfIcons = [
    Icons.home_rounded,
    Icons.subscriptions_rounded,
    FontAwesomeIcons.pauseCircle,
  ];

  final List<String> listOfStrings = [
    'الرئيسية',
    'الاشتراكات',
    'المعلق',
  ];

  @override
  void initState() {
    super.initState();
    id_section = widget.id_section;

    screens = [
      HomeScreen(id_section: id_section),
      SubscriptionsScreen(id_section: id_section),
      SuspendScreen(id_section: id_section),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final displayWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => CubitApp()
        ..checkSubscriptions(context: context)
        ..checkTokenData(),
      child: BlocConsumer<CubitApp, StatesApp>(
        listener: (context, state) {},
        builder: (context, state) {
          final cubit = CubitApp.get(context);

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: IndexedStack(
              index: currentIndex,
              children: screens,
            ),

            // Bottom Navigation Bar مرتب وأنيق
            bottomNavigationBar: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: displayWidth * 0.15, vertical: displayWidth * 0.02),
              height: displayWidth * 0.10, // أصغر حجم ممكن مع وضوح الأيقونات
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // حواف مستديرة أكثر
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(listOfIcons.length, (index) {
                  bool isSelected = currentIndex == index;
                  return InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () async {
                      setState(() {
                        currentIndex = index;
                      });
                      HapticFeedback.lightImpact();

                      await CubitApp.get(context).checkTokenData();
                      if (!CubitApp.get(context).dataCheckToken) {
                        await deleteTokenOrganization();
                        NavigatorMethod(context: context, screen: LoginScreen());
                      } else if (CubitApp.get(context).checkSubscriptionsBool) {
                        if (index == 0) {
                          CubitApp.get(context).getMembersData(section_id: id_section);
                        } else if (index == 1) {
                          CubitApp.get(context).getSubscriptionsMember(section_id: id_section);
                          CubitApp.get(context).getSubscriptionsType();
                        } else {
                          CubitApp.get(context).getSuspendMembersData(section_id: id_section);
                        }
                      } else {
                        NavigatorMethod(context: context, screen: MassageScreens());
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          listOfIcons[index],
                          size: displayWidth * 0.05, // حجم أصغر
                          color: isSelected
                              ? Colors.purple.shade800
                              : Colors.grey.shade500,
                        ),
                        const SizedBox(height: 2), // مسافة أقل بين الأيقونة والنص
                        Text(
                          listOfStrings[index],
                          style: TextStyle(
                            fontSize: displayWidth * 0.022, // حجم نص أصغر
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.purple.shade800
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}
