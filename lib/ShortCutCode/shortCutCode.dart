import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;





 Widget listFun({
    required w ,
    required itemCount,
   icon =Icons.edit,
   label = "Edit",
    required child

}){
    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.all(w / 30),
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: itemCount,
        itemBuilder: (BuildContext c, int i) {
          return AnimationConfiguration.staggeredList(
            position: i,
            delay: Duration(milliseconds: 100),
            child: SlideAnimation(
              duration: Duration(milliseconds: 2500),
              curve: Curves.fastLinearToSlowEaseIn,
              horizontalOffset: 30,
              verticalOffset: 300.0,
              child: FlipAnimation(
                duration: Duration(milliseconds: 3000),
                curve: Curves.fastLinearToSlowEaseIn,
                flipAxis: FlipAxis.y,
                child: Slidable(
                  key: ValueKey(i),
                  startActionPane: ActionPane(
                    motion: BehindMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          bool connected = await checkInternet(
                              context: context);

                          if (connected)
                          // افتح شاشة التعديل هنا
                          print('Edit item $i');
                          // يمكنك فتح صفحة تعديل هنا باستخدام Navigator
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => EditScreen()));
                        },

                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF6A1B9A),
                        icon: icon,
                        label: label
                      ),
                    ],
                  ),
                  child: Container(
                    margin: EdgeInsets.only(bottom: w / 20),
                    height: w / 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

Widget InputText({
  required TextInputType inputType,
  required IconData prefixIcon,
  required String labelText,
  TextEditingController? controller,
  Function(String value)? onFieldSubmitted,
  Function(String value)? onChanged,
  bool border = true,
  bool password = false,
  bool onpassword = false,
  IconData suffixIcon = Icons.remove_red_eye_outlined,
  VoidCallback? onPressedSuffixIcon,
  FormFieldValidator<String>? validator,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(100),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 0,
          blurRadius: 0,
          offset: Offset(0, 0), // اتجاه الظل
        ),
      ],
    ),
    child: TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: inputType,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      obscureText: onpassword,
      decoration: InputDecoration(
        label: Text(
          labelText,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.black54),
        suffixIcon: password
            ? IconButton(
          onPressed: onPressedSuffixIcon,
          icon: Icon(suffixIcon, color: Colors.black54),
        )
            : null,
        border: InputBorder.none, // لإزالة الحدود الافتراضية
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
  );
}



Widget Button({
  bool enable = true,

  Color fontColor = Colors.white,
  double width = double.infinity,
  double height = 50,
  double borderRadius = 40,
  VoidCallback? onPressed,
  required String title,
}) {
  return InkWell(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: Color(0xFF6A1B9A),
            borderRadius: BorderRadius.circular(borderRadius)),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
                color: fontColor,
                fontSize:  20.sp,
                ),
          ),
        ),
      ),
    );
}





Widget iconButton({
  Color backColor = Colors.red,
  Color fontColor = Colors.white,
  double width = 180,
  double height = 50,
  double borderRadius = 30,
  VoidCallback? onPressed,
  required IconData icon,
}) {
  return InkWell(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: backColor,
            borderRadius: BorderRadius.circular(borderRadius)),
        child: Center(
          child: Icon(
            icon,
            color: fontColor,
          ),
        ),
      ),
    );
}

Future NavigatorMethod(
    {required BuildContext context, required Widget screen})
async {

  // is check internet
  bool connected = await checkInternet(context: context);

  if(connected) {
    return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => screen),
  );
  }

  //return Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
}






Widget inputDate(
    {
      required DateTime? date,
      required GestureTapCallback onTap,
      width = double.infinity,
      height = 58.0
    }) =>
    Center
      (child: InkWell(
      onTap: onTap,
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        width: width ,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 0,
              offset: Offset(0, 0), // تحكم في اتجاه الظل
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 13),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: Colors.black54,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                date == null
                    ? 'Berth Date'
                    : "${date.day}-${date.month}-${date.year}",
                style: TextStyle(fontSize: 15),
              )
            ],
          ),
        ),
      ),
    ));


Widget DropdownInput({
  required String labelText,
  required IconData prefixIcon,
  required List itemsList,
  Map<String, dynamic>? selectedValue,
  ValueChanged<Map<String, dynamic>?>? onChanged,
  FormFieldValidator<Map<String, dynamic>>? validator,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(100),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 0,
          blurRadius: 0,
          offset: Offset(0, 0),
        ),
      ],
    ),
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: DropdownButtonFormField<Map<String, dynamic>>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
        prefixIcon: Icon(prefixIcon, color: Colors.black54),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 14),
      ),
      items: itemsList.map((item) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: item,
          child: Text(item['name']),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    ),
  );
}



bool checkPasswordSc(String value) {
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return true;
  }

  if (!value.contains(RegExp(r'[a-z]'))) {
    return true;
  }

  if (!value.contains(RegExp(r'[0-9]'))) {
    return true;
  }

  return false;
}







Widget InputTextDate({
  required TextInputType inputType,
  required IconData prefixIcon,
  required String labelText,
  TextEditingController? controller,
  Function(String value)? onFieldSubmitted,
  Function(String value)? onChanged,
  required VoidCallback onTap,
  bool border = true,
  bool password = false,
  bool onpassword = false,
  IconData suffixIcon = Icons.remove_red_eye_outlined,
  VoidCallback? onPressedSuffixIcon,
  FormFieldValidator<String>? validator,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(100),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 0,
          blurRadius: 0,
          offset: Offset(0, 0),
        ),
      ],
    ),
    child: TextFormField(
      readOnly: true, // منع الكتابة اليدوية
      onTap: onTap,   // عند الضغط يفتح الـ DatePicker
      validator: validator,
      controller: controller,
      keyboardType: inputType,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      obscureText: onpassword,
      decoration: InputDecoration(
        label: Text(
          labelText,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.black54),
        suffixIcon: password
            ? IconButton(
          onPressed: onPressedSuffixIcon,
          icon: Icon(suffixIcon, color: Colors.black54),
        )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
  );
}




/// فحص الاتصال الحقيقي بالإنترنت عن طريق Google 204
Future<bool> isInternetAvailable({int timeoutMs = 3000}) async {
  try {
    final response = await http
        .get(Uri.parse('https://clients3.google.com/generate_204'))
        .timeout(Duration(milliseconds: timeoutMs));

    return response.statusCode == 204 || response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

/// ستريم لمراقبة حالة الإنترنت
Stream<bool> internetStatusStream() async* {
  // فحص أولي
  yield await isInternetAvailable();

  // مراقبة تغيّر الشبكة
  final connectivity = Connectivity();

  await for (final result in connectivity.onConnectivityChanged) {
    if (result == ConnectivityResult.none) {
      yield false;
    } else {
      yield await isInternetAvailable();
    }
  }
}

Future<bool> checkInternet({ required context}) async {
  bool connected = await isInternetAvailable();
  print("Internet: $connected");
  if(!connected){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 8,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Row(
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 26,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "انقطع الاتصال بالإنترنت\nيرجى التحقق من الشبكة",
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  return connected ;
}
