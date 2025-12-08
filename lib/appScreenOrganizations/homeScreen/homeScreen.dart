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
import 'editMembers.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreen({super.key , required id_section}){
    this.id_section = id_section ;
  }
  var id_section ;
  State<HomeScreen> createState() => _HomeScreenState(id_section: id_section);
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeScreenState({required   id_section }){
    this.id_section = id_section ;

  }
  var id_section ;

  DateTime? berthDateMembers;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CubitApp.get(context).getMembersData(section_id: id_section );
    });
  }

  Widget build(BuildContext context) {
    final _w = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final editName = TextEditingController();
    final name = TextEditingController();
    final note = TextEditingController();
    final gender = TextEditingController();
    final birth_date = TextEditingController();
    final phone = TextEditingController();
    final height_cm = TextEditingController();
    final weight_kg = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return BlocConsumer<CubitApp, StatesApp>(
      listener: (BuildContext context, StatesApp state) {
        if (state is AddMembersDataState ||
            state is EditMembersState ||
            state is AddSuspendMembersState) {
          CubitApp.get(context).getMembersData(section_id: id_section);
        }
      },
      builder: (BuildContext context, StatesApp state) {
        final cubit = CubitApp.get(context);

        // تعديل الاسم
        void editNameFun({required String id}) {
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
                        const SizedBox(height: 20),
                        Text(
                          "تعديل الاسم",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InputText(
                          controller: editName,
                          inputType: TextInputType.text,
                          prefixIcon: Icons.person,
                          labelText: "الاسم",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'الرجاء إدخال اسم العضو';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Button(
                          title: "تم",
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {}
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        // إيقاف العضو
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
                        "إيقاف العضو",
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
                        prefixIcon: Icons.note,
                        labelText: "ملاحظة",
                      ),
                      const SizedBox(height: 20),
                      Button(
                        title: "تم",
                        onPressed: () async {
                          await cubit.addSuspendMembers(
                              note: note.text, members_id: id);

                          if (cubit.dataAddSuspendMembers["status"] == "success") {
                            Navigator.pop(context);
                            editName.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  cubit.dataAddSuspendMembers["message"],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  cubit.dataAddSuspendMembers["message"],
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
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text(
              "الأعضاء",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: theme.primaryColor,
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: cubit.dataMembers.isEmpty
                ? Center(
              child: Text(
                "لا يوجد أعضاء",
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
                itemCount: cubit.dataMembers.length,
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
                              extentRatio: 0.5,
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    edit(
                                      id: cubit.dataMembers[index]["id"],
                                      context: context,
                                    );
                                  },
                                  backgroundColor: Colors.white,
                                  foregroundColor: theme.primaryColor,
                                  icon: Icons.edit,
                                  label: 'تعديل',
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                SlidableAction(
                                  onPressed: (context) async {
                                    bool connected = await checkInternet(
                                        context: context);

                                    if (connected) {
                                      addSuspend(
                                        id:
                                        "${cubit.dataMembers[index]["id"]}");
                                    }
                                  },
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue,
                                  icon: Icons.stop_circle_outlined,
                                  label: 'إيقاف',
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
                                            cubit.dataMembers[index]
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
                                                  _buildDetailRow(label:":الاسم", value: cubit.dataMembers[index]["name"].toString()),
                                                  _buildDetailRow(label:":الجنس",        value:cubit.dataMembers[index]["gender"].toString()),
                                                  _buildDetailRow(label:":تاريخ الميلاد",value: cubit.dataMembers[index]["birth_date"].toString()),
                                                  _buildDetailRow(label:":رقم الهاتف",   value:cubit.dataMembers[index]["phone"].toString()),
                                                  _buildDetailRow(label:":الطول (سم)",   value:cubit.dataMembers[index]["height_cm"].toString()),
                                                  _buildDetailRow(label:":الوزن (كغ)",   value:cubit.dataMembers[index]["weight_kg"].toString()),
                                                  _buildDetailRow(label:":اسم النادي",   value:cubit.dataMembers[index]["organization_name"].toString()),
                                                  _buildDetailRow(label:":اسم المسوؤل",   value:cubit.dataMembers[index]["responsible"].toString()),
                                                  _buildDetailRow(label:":تاريخ الإضافة",      value:cubit.dataMembers[index]["created_at"].toString()),
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
                                  "إضافة عضو",
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

                                // الجنس
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: "الجنس",
                                    prefixIcon: const Icon(Icons.transgender, color: Colors.black54),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  ),
                                  value: gender.text.isNotEmpty ? gender.text : null,
                                  items: ["ذكر", "أنثى"].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      gender.text = value!;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء اختيار الجنس';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10.h),

                                // تاريخ الميلاد
                                InputTextDate(
                                  controller: birth_date,
                                  inputType: TextInputType.none,
                                  prefixIcon: Icons.date_range,
                                  labelText: "تاريخ الميلاد",
                                  onTap: () async {
                                    final selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: berthDateMembers ?? DateTime(DateTime.now().year - 16),
                                      firstDate: DateTime(DateTime.now().year - 66),
                                      lastDate: DateTime(DateTime.now().year - 5),
                                    );
                                    if (selectedDate != null) {
                                      setState(() {
                                        berthDateMembers = selectedDate;
                                        birth_date.text =
                                        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "الرجاء اختيار تاريخ الميلاد";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10.h),

                                // رقم الهاتف
                                InputText(
                                  controller: phone,
                                  inputType: TextInputType.phone,
                                  prefixIcon: Icons.phone,
                                  labelText: "رقم الهاتف",
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء إدخال رقم الهاتف';
                                    }
                                    if (value.contains(RegExp(r'[A-Za-z]'))) {
                                      return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
                                    }
                                    if (value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                                      return 'رقم الهاتف لا يجب أن يحتوي على رموز';
                                    }
                                    if (value.length != 10) {
                                      return 'رقم الهاتف يجب أن يتكون من 10 أرقام فقط';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10.h),

                                // الطول
                                InputText(
                                  controller: height_cm,
                                  inputType: TextInputType.number,
                                  prefixIcon: Icons.height,
                                  labelText: "الطول (سم)",
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء إدخال الطول بالسنتيمتر';
                                    }
                                    if (value.contains(RegExp(r'[A-Za-z]'))) {
                                      return 'الطول يجب أن يكون رقمًا فقط';
                                    }
                                    double? h = double.tryParse(value);
                                    if (h == null) {
                                      return 'الرجاء إدخال رقم صحيح للطول';
                                    }
                                    if (h < 50 || h > 300) {
                                      return 'الطول يجب أن يكون بين 50 و 300 سم';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10.h),

                                // الوزن
                                InputText(
                                  controller: weight_kg,
                                  inputType: TextInputType.number,
                                  prefixIcon: Icons.monitor_weight_rounded,
                                  labelText: "الوزن (كغ)",
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء إدخال الوزن بالكيلوغرام';
                                    }
                                    if (value.contains(RegExp(r'[A-Za-z]'))) {
                                      return 'الوزن يجب أن يكون رقمًا فقط';
                                    }
                                    double? w = double.tryParse(value);
                                    if (w == null) {
                                      return 'الرجاء إدخال رقم صحيح للوزن';
                                    }
                                    if (w < 20 || w > 500) {
                                      return 'الوزن يجب أن يكون بين 20 و 500 كغ';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10.h),

                                // زر الإضافة
                                Button(
                                  title: "إضافة",
                                  onPressed: () async {
                                    bool connected = await checkInternet(
                                        context: context);


                                    if (_formKey.currentState!.validate() && connected) {
                                      cubit.showLoadingFun(i: true);

                                      // تحويل قيمة gender.text من عربي إلى إنجليزي
                                      if (gender.text.trim() == "ذكر") {
                                        gender.text = "Male";
                                      } else  {
                                        gender.text = "Female";
                                      }



                                      await cubit.addMembersData(
                                        name: name.text,
                                        birth_date: birth_date.text,
                                        gender: gender.text,
                                        height_cm: height_cm.text,
                                        phone: phone.text,
                                        weight_kg: weight_kg.text,
                                        section_id: id_section.toString()
                                      );

                                      cubit.showLoadingFun(i: false);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            cubit.dataAddMembers["message"],
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

                                      if (cubit.dataAddMembers["status"] == "success") {
                                        Navigator.pop(context);
                                      }
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

