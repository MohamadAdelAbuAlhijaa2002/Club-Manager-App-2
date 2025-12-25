import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../ShortCutCode/shortCutCode.dart';
import '../../bloc/Cubit.dart';
import '../../bloc/states.dart';
import 'editMembers.dart';

class HomeScreen extends StatefulWidget {
  final int id_section;
  HomeScreen({super.key, required this.id_section});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int id_section;
  DateTime? berthDateMembers;

  _HomeScreenState();

  @override
  void initState() {
    super.initState();
    id_section = widget.id_section;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CubitApp.get(context).getMembersData(section_id: id_section);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = CubitApp.get(context);
    final editName = TextEditingController();
    final name = TextEditingController();
    final note = TextEditingController();
    final gender = TextEditingController();
    final birth_date = TextEditingController();
    final phone = TextEditingController();
    final height_cm = TextEditingController();
    final weight_kg = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    void showEditName(String id) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        isScrollControlled: true,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSheetHandle(),
                SizedBox(height: 16.h),
                Text("تعديل الاسم",
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor)),
                SizedBox(height: 12.h),
                InputText(
                  controller: editName,
                  inputType: TextInputType.text,
                  prefixIcon: Icons.person,
                  labelText: "الاسم",
                  validator: (v) => v!.isEmpty ? "الرجاء إدخال اسم العضو" : null,
                ),
                SizedBox(height: 20.h),
                Button(
                  title: "تم",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // تنفيذ تعديل الاسم هنا
                      Navigator.pop(context);
                    }
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      );
    }

    void showSuspend(String id) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        isScrollControlled: true,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetHandle(),
              SizedBox(height: 16.h),
              Text("إيقاف العضو",
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor)),
              SizedBox(height: 12.h),
              InputText(
                controller: note,
                inputType: TextInputType.text,
                prefixIcon: Icons.note,
                labelText: "ملاحظة",
              ),
              SizedBox(height: 20.h),
              Button(
                title: "تم",
                onPressed: () async {
                  await cubit.addSuspendMembers(note: note.text, members_id: id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(cubit.dataAddSuspendMembers["message"]),
                      backgroundColor: Colors.purple.shade800,
                    ),
                  );
                  note.clear();
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("الأعضاء",
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 20.sp, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        //automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: cubit.dataMembers.isEmpty
            ? Center(
          child: Text("لا يوجد أعضاء",
              style: TextStyle(fontSize: 18.sp, color: Colors.grey)),
        )
            : AnimationLimiter(
          child: ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: cubit.dataMembers.length,
            itemBuilder: (_, index) {
              var member = cubit.dataMembers[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  child: FlipAnimation(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 15,
                                spreadRadius: 2)
                          ]),
                      child: Slidable(
                        key: ValueKey(index),
                        startActionPane: ActionPane(
                          motion: const BehindMotion(),
                          extentRatio: 0.5,
                          children: [
                            SlidableAction(
                              onPressed: (_) => showEditName(member["id"]),
                              backgroundColor: Colors.white,
                              foregroundColor: theme.primaryColor,
                              icon: Icons.edit,
                              label: "تعديل",
                              borderRadius: BorderRadius.circular(15),
                            ),
                            SlidableAction(
                              onPressed: (_) => showSuspend("${member["id"]}"),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              icon: Icons.stop_circle_outlined,
                              label: "إيقاف",
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              children: [
                                Icon(Icons.person,
                                    size: 28.sp, color: theme.primaryColor),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(member["name"],
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                IconButton(
                                  icon: Icon(Icons.info_outline,
                                      color: theme.primaryColor, size: 24.sp),
                                  onPressed: () => _showMemberDetails(member),
                                )
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemberSheet(cubit),
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        width: 50,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showMemberDetails(Map member) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
            child: Text("تفاصيل العضو",
                style: TextStyle(color: theme.primaryColor))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(label: ":الاسم", value: member["name"].toString()),
            _buildDetailRow(label: ":الجنس", value: member["gender"].toString()),
            _buildDetailRow(
                label: ":تاريخ الميلاد", value: member["birth_date"].toString()),
            _buildDetailRow(label: ":رقم الهاتف", value: member["phone"].toString()),
            _buildDetailRow(label: ":الطول (سم)", value: member["height_cm"].toString()),
            _buildDetailRow(label: ":الوزن (كغ)", value: member["weight_kg"].toString()),
            _buildDetailRow(
                label: ":اسم النادي", value: member["organization_name"].toString()),
            _buildDetailRow(label: ":اسم المسؤول", value: member["responsible"].toString()),
            _buildDetailRow(label: ":تاريخ الإضافة", value: member["created_at"].toString()),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("إغلاق", style: TextStyle(color: theme.primaryColor)))
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(value.isNotEmpty ? value : "غير متوفر",
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)),
          ),
          SizedBox(width: 10.w),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))
        ],
      ),
    );
  }

  void _showAddMemberSheet(CubitApp cubit) {
    // هنا يمكنك وضع الكود لإضافة عضو جديد بطريقة مشابهة للـ BottomSheet السابق
  }
}
