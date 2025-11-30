import 'package:bloc/bloc.dart';
import 'package:club_app_organizations_section/bloc/states.dart';
import 'package:club_app_organizations_section/appScreenOrganizations/notification/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Server/connectServer.dart';
import '../Server/links.dart';
import '../ShortCutCode/shortCutCode.dart';
import '../appScreenOrganizations/MassageScreen/MassageScreen.dart';
import '../appScreenOrganizations/loginScren/loginScreen.dart';
import '../saveToken/saveToken.dart';

class CubitApp extends Cubit<StatesApp> {
  CubitApp() :super(ProjectInitialStates());

  static CubitApp get(context) => BlocProvider.of(context);


  bool passwordUser1 = true ;
  void onChangeUserPassword1() {
    passwordUser1 = !passwordUser1 ;
    emit(ChangeShowPassState());
  }

  bool passwordUser2 = true ;
  void onChangeUserPassword2() {
    passwordUser2 = !passwordUser2 ;
    emit(ChangeShowPassState());
  }

  int show = 0 ;
  void onChangeShow(i) {
    show = i ;
    emit(ChangeShowPassState());
  }


  bool showLoading = false ;

  showLoadingFun({i}){

    showLoading = i ;
    emit(ChangeShowLoadingState());
  }



  DateTime? berthDateMembers  ;



  Future selectDate({
    required BuildContext context
  })async{
    //print(DateTime.now());
    DateTime? _Picker = await showDatePicker(
        context: context,
        initialDate:  berthDateMembers.toString() == 'null' ? DateTime(int.parse(DateTime.now().year.toString())-19) : berthDateMembers,
        firstDate: DateTime(int.parse(DateTime.now().year.toString())-66),
        lastDate: DateTime(int.parse(DateTime.now().year.toString())-18)
    );

    if(_Picker == null){

    }else {
      berthDateMembers = _Picker!;
    }

    emit(ChangeDateState());
  }

  var dataCheckEmail;
  Future checkEmail({email }) async
  {

    Crud  crud = Crud();
    var res = await crud.postReq(
      linkCheckEmail,

      {
        "email": "$email",

      },

    );

    dataCheckEmail = res;
    print("res Check Email : ${res}");
    // print("id  : ${res["data"].length}");


    emit(StopCheckEmailState());

  }




  var dataForgotPassword;
  Future forgotPassword({email , password}) async
  {

    Crud  crud = Crud();
    var res = await crud.postReq(
      linkForgotPassword,

      {
        "email": "$email",
        "password": "$password",

      },

    );

    dataForgotPassword = res;
    print("res  forgot password : ${res}");
    // print("id  : ${res["data"].length}");


    emit(StopForgotPasswordState());

  }



//------------------------------------------------------------------------------------------------



  var dataLogin = {} ;
  Future loginOrganization({email, password} ) async {
    print("res  sssssssssssssssssssssss");

    Crud  crud = Crud();
    var res = await crud.postReq(linkLogInOrganization, {
      "email" : email,
      "password" : password
    });
    dataLogin = res ;
    print("res : $res");

    if(res["status"] == "success") {
      saveTokenOrganization(res["data"]["manager_data"]["token"]);
      saveRoleOrganization(res["data"]["manager_data"]["role"]);








      var token = await getTokenOrganization();

      var fcmToken = await FirebaseNotification().initNotifications();
      var resFcm = await crud.postReqH(
          linkSaveFcmToken,
          headers: {
            'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
            'Accept': 'application/json',
          },

          {
            "fcmToken" : "$fcmToken"
          }
      );

    }

    var t = await getTokenOrganization();
    var r = await getRoleOrganization();

    print("token: ${t == null}");
    print("r: $r");
    print("res  login data  : $res");
    emit(LoginOrganizationState());



  }




  var dataMembers = [] ;
  int indexDataMembers = 0 ;

  Future getMembersData({required section_id}) async  {
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkGatDataMembers,
      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },

      {
        "section_id" : "$section_id"
      }
    );

    //  print("token : $token");
    print("res getOrganizationData : ${res}");

    if(res["status"] == "success"){
      dataMembers = [];
      dataMembers = res["data"];
      indexDataMembers = res["data"].length ;
      //  print("index  : $indexDataOrganization");
      print("res : $res");
    }

    emit(GetMembersDataState());



  }






  var dataAddMembers ;
  Future addMembersData({ name , gender , birth_date ,phone ,height_cm ,weight_kg , section_id}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkAddDataMembers,

      {
        "name" : name ,
        "gender" : gender ,
        "birth_date" : birth_date ,
        "phone" : phone ,
        "height_cm" : height_cm ,
        "weight_kg" : weight_kg ,
        "section_id" : section_id
      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataAddMembers = res;
    print("res  : $res");
    print("token  : $token");


    emit(AddMembersDataState());

  }








  var dataEditNameMembers;
  Future editNameMembers({name, Members_id}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditNameMembers,


      {
        "name": "$name",
        "id": "$Members_id",

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditNameMembers = res;
    print("res  : ${res["status"]}");
    print("token  : $token");


    emit(EditMembersState());

  }



  var dataEditWeightMembers;
  Future editWeightMembers({weight, Members_id}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditWeightMembers,


      {
        "weight": "$weight",
        "id": "$Members_id",

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditWeightMembers = res;
    print("res  : ${res["status"]}");
    print("token  : $token");


    emit(EditMembersState());

  }





  var dataEditPhoneMembers;
  Future editPhoneMembers({phone, Members_id}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditPhoneMembers,


      {
        "phone": "$phone",
        "id": "$Members_id",

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditPhoneMembers = res;
    print("res  : ${res["status"]}");
    print("token  : $token");


    emit(EditMembersState());

  }




  var dataEditHeightMembers;
  Future editHeightMembers({height, Members_id}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditHeightMembers,


      {
        "height": "$height",
        "id": "$Members_id",

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditHeightMembers = res;
    print("res  : ${res["status"]}");
    print("token  : $token");


    emit(EditMembersState());

  }





  var dataEditNameOrganization;
  Future editNameOrganization({name , password}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditNameOrganization,

      {
        "name": "$name",
        "password": "$password",

      },
      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditNameOrganization = res;
    print("res  : ${res}");
    print("token  : $token");
    // print("id  : ${res["data"].length}");


    emit(EditNameOrganizationState());

  }




  var dataEditEmailOrganization;
  Future editEmailOrganization({email , password}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditEmailOrganization,

      {
        "email": "$email",
        "password": "$password",

      },
      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditEmailOrganization = res;
    print("res  : ${res}");
    print("token  : $token");
    // print("id  : ${res["data"].length}");


    emit(EditEmailOrganizationState());

  }




  var dataEditPasswordOrganization;
  Future editPasswordOrganization({password , passwordOld}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditPasswordOrganization,

      {
        "passwordOld": "$passwordOld",
        "password": "$password",

      },
      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditPasswordOrganization = res;
    print("res  : ${res}");
    print("token  : $token");
    // print("id  : ${res["data"].length}");


    emit(EditPasswordOrganizationState());

  }





  var dataLogOutOrganization;
  Future logOutOrganization({context}) async
  {

    var token = await getTokenOrganization();
    print("token  : $token");

    Crud  crud = Crud();
    var res = await crud.getReqH(
      linkLogOutOrganization,

      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );
    deleteTokenOrganization();

    dataLogOutOrganization  = res ;
    print("res  : ${res}");


      NavigatorMethod(context: context, screen: LoginScreen());





    emit(LogOutOrganizationState());

  }







  var dataSubscriptionsType = [] ;
  int indexSubscriptionsType = 0 ;

  Future getSubscriptionsType() async  {
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.getReqH(
      linkGetSubscriptionsType,
      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },
    );

    //  print("token : $token");
    // print("res  : ${res["data"].length}");
    dataSubscriptionsType = [];
    if(res["status"] == "success"){

      dataSubscriptionsType = res["data"];
      indexSubscriptionsType = res["data"].length ;
      //  print("index  : $indexDataOrganization");

    }

    emit(GetSubscriptionsTypeState());



  }















  var dataSubscriptionsMemberActive = [] ;
  var dataSubscriptionsMemberNonActive = [] ;
  var dataSubscriptionsMemberNonSubscribed = [] ;


  int indexSubscriptionsMemberActive = 0 ;
  int indexSubscriptionsMemberNonActive = 0 ;
  int indexSubscriptionsMemberNonSubscribed = 0 ;


  Future getSubscriptionsMember({required section_id}) async  {
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkGetSubscriptionsMembers,
      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },
      {
        "section_id": "${section_id}"
      }
    );

    print("token : $token");
    print("res getSubscriptionsOrganization : ${res["active"]}");

    if(res["status"] == "success"){
      dataSubscriptionsMemberActive = [];
      dataSubscriptionsMemberActive = res["active"] ;
      indexSubscriptionsMemberActive = dataSubscriptionsMemberActive.length;

      dataSubscriptionsMemberNonActive = [];
      dataSubscriptionsMemberNonActive = res["expired"] ;
      indexSubscriptionsMemberNonActive = dataSubscriptionsMemberNonActive.length;


      dataSubscriptionsMemberNonSubscribed = [];
      dataSubscriptionsMemberNonSubscribed = res["not_subscribed"] ;
      indexSubscriptionsMemberNonSubscribed = dataSubscriptionsMemberNonSubscribed.length ;

      print("index 1 $indexSubscriptionsMemberNonSubscribed");
      print("index 2 $indexSubscriptionsMemberNonActive");

    }

    emit(GetSubscriptionsMemberState());



  }







  var dataAddSubscriptionsMembers ;
  Future addSubscriptionsMembers({memberId, startDate, note, typeId}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkAddSubscriptionsMembers,


      {
        "member_id": "$memberId",
        "start_date" : "$startDate",
        "note": "$note",
        "type_id": "$typeId",
      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataAddSubscriptionsMembers = res;
    print("res  : $res");
    print("token  : $token");
    // print("id  : ${res["data"].length}");


    emit(AddSubscriptionsMembersState());

  }










  var dataAddSubscriptionsType ;
  Future addSubscriptionsType({name, price, numberDays, note}) async
  {


    print("res  $name ,  $price , $numberDays , $note");

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkAddSubscriptionsType,


      {
        "name": "$name",
        "price" : "$price",
        "number_days": "$numberDays",
        "note": "$note",
      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataAddSubscriptionsType = res;
    print("res  : $res");
    print("token  : $token");


    emit(AddSubscriptionsTypeState());

  }











  var dataEditNameSubscription;
  Future editNameSubscription({name , password , id}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditNameSubscription,


      {
        "name": "$name",
        "password": "$password",
        "id": "$id",

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditNameSubscription = res;
    print("res  : ${res}");
    print("token  : $token");
    // print("id  : ${res["data"].length}");


    emit(EditSubscriptionState());

  }


  var dataEditPriceSubscription;
  Future editPriceSubscription({price , password , id}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditPriceSubscription,


      {
        "price": "$price",
        "password": "$password",
        "id": "$id",

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditPriceSubscription = res;
    print("res  : ${res}");
    print("token  : $token");
    // print("id  : ${res["data"].length}");


    emit(EditSubscriptionState());

  }


  var dataEditNumberDaysSubscription;
  Future editNumberDaysSubscription({NumberDays , password , id}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditNumDaysSubscription,


      {
        "numberDays": "${double.parse(NumberDays).toInt()}",
        "password": "$password",
        "id": "$id",

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditNumberDaysSubscription = res;
    print("res  : ${res}");
    print("token  : $token");
    // print("id  : ${res["data"].length}");


    emit(EditSubscriptionState());

  }




  var dataEditNoteSubscription;
  Future editNoteSubscription({note , password , id}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditNoteSubscription,


      {
        "note": "$note",
        "password": "$password",
        "id": "$id",

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditNoteSubscription = res;
    print("res  : ${res}");
    print("token  : $token");
    // print("id  : ${res["data"].length}");


    emit(EditSubscriptionState());

  }








  var dataSuspendMembers = [] ;
  int indexSuspendMembers = 0 ;
  Future getSuspendMembersData({required section_id}) async  {
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkGetSuspendMembersData,
      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },
      {
        "section_id" : "${section_id}"
      }
    );

    //  print("token : $token");
    print("res getSuspendOrganizationData : ${res}");

    dataSuspendMembers = [];
    if(res["status"] == "success"){
      dataSuspendMembers = res["data"];
      indexSuspendMembers = res["data"].length ;
      //  print("index  : $indexDataOrganization");

    }

    getSuspendSubscriptionsData();
    emit(GatSuspendMembersDataState());



  }







  var dataStopSuspendMembers;
  Future stopSuspendMembers({id}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    print("ddddddddddddddddddddddd $id");
    var res = await crud.postReqH(
      linkStopSuspendMembers,

      {
        "id": "$id",

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );
    //
    dataStopSuspendMembers = res;
    print("res  StopSuspendOrganization: ${dataStopSuspendMembers}");
    print("token  : $token");
    // print("id  : ${res["data"].length}");





    emit(StopSuspendMembersState());

  }





  var dataAddSuspendMembers;
  Future addSuspendMembers({members_id , note}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkSuspendOrganization,


      {
        "members_id": "$members_id",
        "note": "$note",

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataAddSuspendMembers = res;
    print("res  : ${res}");
    print("token  : $token");
    // print("id  : ${res["data"].length}");


    emit(AddSuspendMembersState());

  }








  var dataSuspendSubscriptions = [] ;
  int indexSuspendSubscriptions = 0 ;
  Future getSuspendSubscriptionsData() async  {
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.getReqH(
      linkGetSuspendSubscriptionsData,
      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },
    );

    //  print("token : $token");
    print("res dataSuspendSubscriptions : ${res}");

    dataSuspendSubscriptions = [];
    if(res["status"] == "success"){
      dataSuspendSubscriptions = res["data"];
      indexSuspendSubscriptions = res["data"].length ;
      //  print("index  : $indexDataOrganization");

    }

    emit(GatSuspendSubscriptionsDataState());



  }







  var dataStopSuspendSubscriptions;
  Future stopSuspendSubscriptions({id}) async
  {

    print(" id $id");
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkStopSuspendSubscriptions,


      {
        "id": "$id",
      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataStopSuspendSubscriptions = res;
    print("res  : ${res}");
    print("token  : $token");
    // print("id  : ${res["data"].length}");



    emit(StopSuspendSubscriptionsState());

  }





  var dataAddSuspendSubscriptions;
  Future addSuspendSubscriptions({subscriptions_id , note}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkSuspendSubscriptions,


      {
        "subscriptions_id": "$subscriptions_id",
        "note": "$note",

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataAddSuspendSubscriptions = res;
    print("res  : ${res}");
    print("token  : $token");
    // print("id  : ${res["data"].length}");


    emit(AddSuspendSubscriptionsState());

  }





  var dataInfoOrganization ={};
  Future getInfoOrganization() async  {
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.getReqH(
      linkInfoOrganization,
      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },
    );

    //  print("token : $token");

    dataInfoOrganization = {};
    if(res["status"] == "success"){
      dataInfoOrganization = res["data"];
      print("res getInfoOrganization : ${res}");

    }

    emit(GatInfoOrganizationState());



  }












  bool checkSubscriptionsBool = true ;
  Future checkSubscriptions({required context}) async  {
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.getReqH(
      linkCheckSubscriptions,
      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },
    );


   checkSubscriptionsBool = res["status"];
    print("message : ${checkSubscriptionsBool}" );

    if(!checkSubscriptionsBool){
      NavigatorMethod(
          context: context,
          screen: MassageScreens());
    }
    emit(CheckSubscriptionsState());



  }




  var dataSubscriptionsTypeAdmin = [] ;
  int indexSubscriptionsTypeAdmin = 0 ;

  Future getSubscriptionsTypeAdmin() async  {
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.getReqH(
      linkGetSubscriptionsTypeAdmin,
      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },
    );

    //  print("token : $token");
    // print("res  : ${res["data"].length}");
    dataSubscriptionsType = [];
    if(res["status"] == "success"){
      print("type $res");
      dataSubscriptionsTypeAdmin = res["data"];
      indexSubscriptionsTypeAdmin = res["data"].length ;
      //  print("index  : $indexDataOrganization");

    }

    emit(GetSubscriptionsTypeState());



  }







  var dataSection = [] ;
  int indexSection = 0 ;

  Future getSectionData() async  {
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.getReqH(
        linkGetSection,
        headers: {
          'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
          'Accept': 'application/json',
        },

    );

    //  print("token : $token");
    print("res getOrganizationData : ${res}");

    if(res["status"] == "success"){
      dataSection = [];
      dataSection = res["data"];
      indexSection = res["data"].length ;
      //  print("index  : $indexDataOrganization");
      print("res : $res");
    }

    emit(GetSectionDataState());



  }




  var dataAddSection ;
  Future addSectionData({ title , des  , id_managers}) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkAddSection,

      {
       "title" : title,
        "description" : des,
        "id_managers" : id_managers
      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataAddSection = res;
    print("res  : $res");
    print("token  : $token");


    emit(AddSectionDataState());

  }








  var dataManagers = [] ;
  var resManagers  ;
  int indexDataManagers = 0 ;

  Future getManagersData() async  {
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.getReqH(
        linkGetAllManagers,
        headers: {
          'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
          'Accept': 'application/json',
        },
    );

    //  print("token : $token");
    print("res getOrganizationData : ${res}");

    if(res["status"] == "success"){
      dataManagers = [];
      dataManagers = res["data"];
      resManagers = res ;
      indexDataManagers = res["data"].length ;
      //  print("index  : $indexDataOrganization");
      print("res : $res");
    }

    emit(GetManagersDataState());



  }







  var dataAddManagers ;
  Future addManagersData({ name , email , password }) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkAddManagers,

      {
        "name" : name ,
        "email" : email ,
        "password" : password ,
      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataAddManagers = res;
    print("res  : $res");
    print("token  : $token");


    emit(AddManagersDataState());

  }




  var dataDeleteManagers ;
  Future deleteManagersData({ required id_managers }) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkDeleteManagers,

      {
        "id_managers" : id_managers ,

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataDeleteManagers = res;
    print("res  : $res");
    print("token  : $token");


    emit(DeleteManagersDataState());

  }


  var dataDeleteMember ;
  Future deleteMemberData({ required id_member }) async
  {

    print(id_member);
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkDeleteMembers,

      {
        "id_member" : id_member ,
      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataDeleteMember = res;
    print("res  : $res");
    print("token  : $token");


    emit(DeleteMemberDataState());

  }


  var dataDeleteSubscriptionsType ;
  Future deleteSubscriptionsTypeData({ required id_subscriptions_type }) async
  {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkDeleteSubscriptionsType,

      {
        "id_subscriptions_type" : id_subscriptions_type ,

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataDeleteSubscriptionsType = res;
    print("res  : $res");
    print("token  : $token");


    emit(DeleteSubscriptionsTypeDataState());

  }





  var dataEditSectionTitle;
  Future editSectionTitle({required id , required title})  async {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditSectionTitle,

      {
        "section_id" : id ,
        "title" : title ,

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditSectionTitle = res;
    print("res  : $res");
    print("token  : $token");


    emit(EditSectionTitleState());

  }


  var dataEditSectionDescription;
  Future editSectionDescription({required id , required description})  async {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditSectionDescription,

      {
        "section_id" : id ,
        "descrebtion" : description ,

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditSectionDescription = res;
    print("res  : $res");
    print("token  : $token");


    emit(EditSectionDescriptionState());

  }


 var dataEditSectionResponsible;
  Future editSectionResponsible({required id , required id_managers})  async {

    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.postReqH(
      linkEditSectionResponsible,

      {
        "section_id" : id ,
        "id_managers" : id_managers ,

      },



      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );

    dataEditSectionResponsible = res;
    print("res  : $res");
    print("token  : $token");


    emit(EditSectionResponsibleState());

  }








  var dataNotification = [] ;
  int indexDataNotification = 0 ;

  Future getNotificationData() async  {
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.getReqH(
      linkGetNotificationData,
        headers: {
          'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
          'Accept': 'application/json',
        },


    );

    //  print("token : $token");
    print("res getNotificationData : ${res}");

    if(res["status"]){
      indexDataNotification = res["data"].length ;
      dataNotification = [];
      dataNotification = res["data"];
    }

    emit(GetNotificationData());



  }










  bool dataCheckToken = true  ;

  Future checkTokenData() async  {
    var token = await getTokenOrganization();
    Crud  crud = Crud();
    var res = await crud.getReqH(
      linkCheckTokenData,
      headers: {
        'Authorization': 'Bearer $token', // ⚠️ مهم: "Bearer" ومسافة والتوكن
        'Accept': 'application/json',
      },


    );



    if(token != null) {
      dataCheckToken = res["status"];
      emit(TokenValidated());
    }else{
      dataCheckToken = false ;
    }
    print("token : $token");
    print("dataCheckToken : $res");

    emit(CheckTokenState());



  }






}