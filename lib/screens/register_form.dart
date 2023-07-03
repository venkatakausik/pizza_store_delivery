import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:pizza_store_delivery/providers/auth_provider.dart';
import 'package:pizza_store_delivery/screens/home_screen.dart';
import 'package:pizza_store_delivery/screens/login_screen.dart';
import 'package:pizza_store_delivery/utils/dimensions.dart';
import 'package:pizza_store_delivery/widgets/small_text.dart';
import 'package:provider/provider.dart';

import '../services/firebase_services.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  var _nameTextController = TextEditingController();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  var _cPasswordTextController = TextEditingController();
  var _locationTextController = TextEditingController();
  late String email;
  late String password;
  late String mobile;
  late String name;
  bool _isLoading = false;

  scaffoldMessage(message) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: SmallText(text: message)));
  }

  FirebaseServices _firebaseServices = FirebaseServices();
  bool _visible = false;
  bool _confirmPassVisible = false;

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    setState(() {
      _emailTextController.text = _authData.email;
      email = _authData.email;
    });
    return _isLoading
        ? CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          )
        : Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter name';
                      }
                      setState(() {
                        _nameTextController.text = value;
                      });
                      setState(() {
                        this.name = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_2_outlined),
                        labelText: 'Name',
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Metropolis'),
                        prefixIconColor: Theme.of(context).primaryColor,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Mobile Number';
                      }
                      setState(() {
                        this.mobile = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone_iphone),
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Metropolis'),
                        prefixIconColor: Theme.of(context).primaryColor,
                        labelText: 'Mobile Number',
                        prefixText: "+01 ",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    enabled: false,
                    controller: _emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Metropolis'),
                        prefixIconColor: Theme.of(context).primaryColor,
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _passwordTextController,
                    obscureText: _visible == false ? true : false,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter password';
                      }
                      if (value.length < 6) {
                        return 'Minimum 6 characters';
                      }

                      setState(() {
                        this.password = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _visible = !_visible;
                              });
                            },
                            icon: _visible
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off)),
                        prefixIcon: Icon(Icons.vpn_key_outlined),
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Metropolis'),
                        prefixIconColor: Theme.of(context).primaryColor,
                        labelText: 'New Password',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _cPasswordTextController,
                    obscureText: _confirmPassVisible == false ? true : false,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Confirm password';
                      }

                      if (value.length < 6) {
                        return 'Minimum 6 characters';
                      }

                      if (_passwordTextController.text !=
                          _cPasswordTextController.text) {
                        return 'Password doesn\'t match';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.vpn_key_outlined),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _confirmPassVisible = !_confirmPassVisible;
                              });
                            },
                            icon: _confirmPassVisible
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off)),
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Metropolis'),
                        prefixIconColor: Theme.of(context).primaryColor,
                        labelText: 'Confirm Password',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    maxLines: 6,
                    controller: _locationTextController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please press Navigation button';
                      }
                      if (_authData.storeLatitude == null) {
                        return 'Please press Navigation button ';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.location_on_outlined),
                        suffixIcon: IconButton(
                            onPressed: () {
                              _locationTextController.text =
                                  "Locating...\n Please wait..";
                              _authData.getCurrentAddress().then((address) {
                                if (address != null) {
                                  setState(() {
                                    _locationTextController.text =
                                        '${_authData.placeName}\n${_authData.shopAddress}';
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: SmallText(
                                              text:
                                                  "Couldn't find location !! Please try again")));
                                }
                              });
                            },
                            icon: Icon(Icons.location_searching)),
                        labelText: 'Business Location',
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).primaryColor)),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                SizedBox(
                  height: Dimensions.height20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            _authData
                                .registerDeliveryPartner(email, password)
                                .then((credential) {
                              if (credential?.user?.uid != null) {
                                // _authData.isLoading();
                                _authData
                                    .saveBoysDataToDB(
                                        name: name,
                                        mobile: mobile,
                                        password: password,
                                        context: context)
                                    .then((value) {
                                  Navigator.pushReplacementNamed(
                                      context, HomeScreen.id);
                                });

                                setState(() {
                                  _isLoading = false;
                                });
                              } else {
                                scaffoldMessage(_authData.error);
                              }
                            });
                          }
                        },
                        child: SmallText(
                          text: 'Register',
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, LoginScreen.id);
                        },
                        style:
                            ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                        child: RichText(
                            text: TextSpan(text: '', children: [
                          TextSpan(
                              text: "Already have an account ? ",
                              style: TextStyle(
                                  letterSpacing: 0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Metropolis')),
                          TextSpan(
                              text: "Login",
                              style: TextStyle(
                                  letterSpacing: 0,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Metropolis')),
                        ]))),
                  ],
                )
              ],
            ),
          );
  }
}
