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

  HomePage({super.key, required this.id_section});

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
    FontAwesomeIcons.pauseCircle // المعلق
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

    // تهيئة الشاشات مع استخدام id_section
    screens = [
      HomeScreen(id_section: id_section),
      SubscriptionsScreen(id_section:  id_section),
      SuspendScreen(id_section: id_section),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final displayWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => CubitApp()..checkSubscriptions(context: context)..checkTokenData(),
      child: BlocConsumer<CubitApp, StatesApp>(
        listener: (BuildContext context, StatesApp state) {},
        builder: (BuildContext context, StatesApp state) {
          final cubit = CubitApp.get(context);

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: IndexedStack(
              index: currentIndex,
              children: screens,
            ),


            bottomNavigationBar: Container(
              margin: EdgeInsets.symmetric(horizontal: displayWidth * 0.05, vertical: displayWidth * 0.02),
              height: displayWidth * 0.16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(listOfIcons.length, (index) {
                  bool isSelected = currentIndex == index;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                          HapticFeedback.lightImpact();
                          CubitApp.get(context).checkTokenData();
                          if(!CubitApp.get(context).dataCheckToken){
                            deleteTokenOrganization();
                            NavigatorMethod(context: context, screen: LoginScreen());

                          if (cubit.checkSubscriptionsBool) {
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



                          }


                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            listOfIcons[index],
                            size: displayWidth * 0.065,
                            color: isSelected ?  Colors.purple.shade800 : Colors.grey.shade500,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            listOfStrings[index],
                            style: TextStyle(
                              fontSize: displayWidth * 0.028,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ?  Colors.purple.shade800 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
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
