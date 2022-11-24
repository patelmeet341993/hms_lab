import 'package:flutter/material.dart';
import 'package:hms_models/configs/constants.dart';
import 'package:hms_models/configs/typedefs.dart';
import 'package:hms_models/models/admin_user/admin_user_model.dart';
import 'package:hms_models/utils/my_print.dart';
import 'package:hms_models/utils/my_toast.dart';
import 'package:hms_models/utils/my_utils.dart';

import '../configs/app_strings.dart';

class AdminUserController {
  Future<AdminUserModel?> createAdminUserWithUsernameAndPassword({required BuildContext context, required AdminUserModel userModel, String userType = AdminUserType.admin,}) async {
    if(userModel.username.isEmpty || userModel.password.isEmpty) {
      MyToast.showError(context: context, msg: "UserName is empty or password is empty",);
      return null;
    }

    AdminUserModel? adminUserModel;

    MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.adminUsersCollectionReference.where("role", isEqualTo: userType).where("username", isEqualTo: userModel.username).get();
    if(querySnapshot.docs.isNotEmpty) {
      MyFirestoreQueryDocumentSnapshot docSnapshot = querySnapshot.docs.first;
      if(docSnapshot.data().isNotEmpty) {
        AdminUserModel model = AdminUserModel.fromMap(docSnapshot.data());
        if(model.username == userModel.username) {
          adminUserModel = model;
        }
      }
    }

    if(adminUserModel == null) {
      adminUserModel = AdminUserModel(
        id: MyUtils.getUniqueIdFromUuid(),
        name: userModel.name,
        username: userModel.username,
        password: userModel.password,
        role: userType,
        description: userModel.description,
        imageUrl: userModel.imageUrl,
        scannerData: userModel.scannerData,
      );

      bool isCreationSuccess = await FirebaseNodes.adminUserDocumentReference(userId: adminUserModel.id).set(adminUserModel.toMap()).then((value) {
        MyPrint.printOnConsole("Admin User with Id:${adminUserModel!.id} Created Successfully");
        return true;
      })
      .catchError((e, s) {
        MyPrint.printOnConsole("Error in Creating Admin User:$e");
        MyPrint.printOnConsole(s);
        return false;
      });
      MyPrint.printOnConsole("isCreationSuccess:$isCreationSuccess");

      if(isCreationSuccess) {
        return adminUserModel;
      }
      else {
        return null;
      }
    }
    else {
      MyToast.showError(context: context, msg: AppStrings.givenUserAlreadyExist);
      return null;
    }
  }
}