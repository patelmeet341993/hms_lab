import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../configs/constants.dart';
import '../models/patient_model.dart';
import '../providers/patient_provider.dart';
import '../utils/logger_service.dart';
import 'firestore_controller.dart';
import 'navigation_controller.dart';

class PatientController {
  Future<List<PatientModel>> getPatientsForMobileNumber({required String mobileNumber}) async {
    Log().d("getPatientsForMobileNumber called with mobile number: $mobileNumber");
    List<PatientModel> patients = [];

    PatientProvider patientProvider = Provider.of<PatientProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false);

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirestoreController().firestore.collection(FirebaseNodes.patientCollection).where("userMobiles", arrayContainsAny: [mobileNumber]).get();
    Log().i("Patient Documents Length For Mobile Number '${mobileNumber}' :${querySnapshot.docs.length}");

    for (DocumentSnapshot<Map<String, dynamic>> documentSnapshot in querySnapshot.docs) {
      if((documentSnapshot.data() ?? {}).isNotEmpty) {
        PatientModel patientModel = PatientModel.fromMap(documentSnapshot.data()!);
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