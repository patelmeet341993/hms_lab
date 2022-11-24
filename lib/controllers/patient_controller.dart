import 'package:hms_models/configs/constants.dart';
import 'package:hms_models/configs/typedefs.dart';
import 'package:hms_models/models/patient/patient_model.dart';
import 'package:hms_models/utils/my_print.dart';
import 'package:provider/provider.dart';

import '../providers/patient_provider.dart';
import 'navigation_controller.dart';

class PatientController {
  Future<List<PatientModel>> getPatientsForMobileNumber({required String mobileNumber}) async {
    MyPrint.printOnConsole("getPatientsForMobileNumber called with mobile number: $mobileNumber");
    List<PatientModel> patients = [];

    PatientProvider patientProvider = Provider.of<PatientProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);

    MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.patientCollectionReference.where("userMobiles", arrayContainsAny: [mobileNumber]).get();
    MyPrint.printOnConsole("Patient Documents Length For Mobile Number '${mobileNumber}' :${querySnapshot.docs.length}");

    for (MyFirestoreQueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      if(documentSnapshot.data().isNotEmpty) {
        PatientModel patientModel = PatientModel.fromMap(documentSnapshot.data());
        patients.add(patientModel);
      }
    }
    patientProvider.setPatientModels(patients, isNotify: false);
    if(patients.isNotEmpty) {
      patientProvider.setCurrentPatient(patients.first, isNotify: false);
    }
    else {
      patientProvider.setCurrentPatient(null, isNotify: false);
    }

    return patients;
  }
}