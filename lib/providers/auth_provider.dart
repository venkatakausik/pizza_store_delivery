import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pizza_store_delivery/services/firebase_services.dart';

import '../screens/home_screen.dart';

class AuthProvider with ChangeNotifier {
  late double storeLatitude;
  late double storeLongitude;
  late String shopAddress;
  late String placeName;
  String error = '';
  late String email;
  bool loading = false;
  FirebaseServices _firebaseServices = FirebaseServices();

  CollectionReference _boys = FirebaseFirestore.instance.collection('boys');

  getEmail(email) {
    this.email = email;
    notifyListeners();
  }

  Future getCurrentAddress() async {
    bool _serviceEnabled;
    LocationPermission _permissionGranted;
    Position _locationData;

    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      await Geolocator.openLocationSettings();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await Geolocator.checkPermission();
    if (_permissionGranted == LocationPermission.denied) {
      _permissionGranted = await Geolocator.requestPermission();
      if (_permissionGranted == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (_permissionGranted == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _locationData = await Geolocator.getCurrentPosition();
    this.storeLatitude = _locationData.latitude;
    this.storeLongitude = _locationData.longitude;
    notifyListeners();

    List<Placemark> _placemarks = await placemarkFromCoordinates(
        _locationData.latitude, _locationData.longitude);
    var storeAddress = _placemarks.first;
    this.shopAddress = storeAddress.street! +
        ", " +
        storeAddress.subLocality! +
        ", " +
        storeAddress.locality! +
        ", " +
        storeAddress.country! +
        ", " +
        storeAddress.postalCode!;
    this.placeName = storeAddress.name!;
    notifyListeners();
    return storeAddress;
  }

  // register using email address
  Future<UserCredential?> registerDeliveryPartner(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        this.error = 'The password provided is too weak.';
        notifyListeners();
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        this.error = 'The account already exists for that email.';
        notifyListeners();
        print('The account already exists for that email.');
      }
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
    return null;
  }

  // login vendor
  Future<UserCredential?> loginBoys(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
    return null;
  }

  // reset password
  Future<void> resetPassword(email) async {
    this.email = email;
    notifyListeners();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
  }

  // save vendor details in firestore DB
  Future<void> saveBoysDataToDB(
      {String? name,
      String? mobile,
      String? password,
      required BuildContext context}) async {
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference _boys = FirebaseFirestore.instance.collection('boys');
    _boys.doc(email).set({
      'uid': user?.uid,
      'name': name,
      'mobile': mobile,
      'email': email,
      'address': '$placeName: $shopAddress',
      'location': GeoPoint(storeLatitude, storeLongitude),
      'password': password,
    });
    return null;
  }
}
