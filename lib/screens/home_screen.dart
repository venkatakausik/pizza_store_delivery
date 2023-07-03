import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pizza_store_delivery/screens/login_screen.dart';
import 'package:pizza_store_delivery/services/firebase_services.dart';
import 'package:pizza_store_delivery/widgets/small_text.dart';

import '../widgets/big_text.dart';
import '../widgets/order_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String id = "home-screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseServices _firebaseServices = FirebaseServices();
  int tag = 0;
  String? status = null;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<String> options = [
    'All Orders',
    'Accepted',
    'Picked Up',
    'On the way',
    'Delivered'
  ];

  @override
  void initState() {
    _firebaseServices.getToken().then((value) {
      _firebaseServices.updateUserDeviceToken(deviceToken: value);
    });
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialize = const DarwinInitializationSettings();
    final InitializationSettings settings = InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );

    flutterLocalNotificationsPlugin.initialize(settings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    super.initState();
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    if (notificationResponse.payload != null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          message.notification!.body.toString(),
          htmlFormatBigText: true,
          contentTitle: message.notification!.title.toString(),
          htmlFormatContent: true);
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              'piiza_store_delivery', 'piiza_store_delivery',
              importance: Importance.max,
              styleInformation: bigTextStyleInformation,
              priority: Priority.max,
              playSound: false);
      NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails,
          iOS: const DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
          message.notification!.body, notificationDetails,
          payload: message.data['body']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BigText(
                text: "Orders",
                color: Colors.white,
                weight: FontWeight.bold,
              ),
              TextButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, LoginScreen.id);
                  },
                  child: SmallText(
                    text: "LogOut",
                    color: Colors.white,
                  ))
            ],
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(.2),
        body: Column(
          children: [
            Container(
              height: 56,
              width: MediaQuery.of(context).size.width,
              child: ChipsChoice<int>.single(
                choiceStyle: C2ChipStyle(
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                value: tag,
                onChanged: (val) {
                  if (val == 0) {
                    setState(() {
                      status = null;
                    });
                  }
                  setState(() {
                    tag = val;
                    status = options[val];
                  });
                },
                choiceItems: C2Choice.listFrom<int, String>(
                  source: options,
                  value: (i, v) => i,
                  label: (i, v) => v,
                ),
              ),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                  stream: _firebaseServices.orders
                      .where('deliveryPartner.email', isEqualTo: user!.email)
                      .where('orderStatus', isEqualTo: tag == 0 ? null : status)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: SmallText(text: "Something went wrong.."),
                      );
                    }

                    if (!snapshot.hasData) {
                      return Center(
                        child: SmallText(
                            text: status == null
                                ? "No Orders"
                                : "No $status Orders"),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Expanded(
                      child: new ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8, bottom: 8),
                            child: new OrderSummaryCard(document: document),
                          );
                        }).toList(),
                      ),
                    );
                  }),
            ),
          ],
        ));
  }
}
