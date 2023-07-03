import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pizza_store_delivery/services/firebase_services.dart';
import 'package:pizza_store_delivery/services/order_services.dart';
import 'package:pizza_store_delivery/utils/dimensions.dart';
import 'package:pizza_store_delivery/widgets/small_text.dart';

import '../services/notification_services.dart';

class OrderSummaryCard extends StatefulWidget {
  const OrderSummaryCard({super.key, required this.document});

  final DocumentSnapshot document;

  @override
  State<OrderSummaryCard> createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  OrderServices _orderServices = OrderServices();
  FirebaseServices _firebaseServices = FirebaseServices();
  NotificationServices _notificationServices = NotificationServices();
  showMyDialog(title, status, documentId, context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: SmallText(text: title),
            content: SmallText(text: "Received payment ?"),
            actions: [
              TextButton(
                  onPressed: () {
                    EasyLoading.show();
                    _orderServices
                        .updateOrderStatus(documentId, "Delivered")
                        .then((value) {
                      _notificationServices.sendPushMessage(
                          _customer['deviceToken'],
                          "Tap here to know more",
                          "Your order is $status");
                      EasyLoading.showSuccess("Order status is now Delivered");
                      Navigator.pop(context);
                    });
                  },
                  child: SmallText(
                    text: "Receive",
                    color: Theme.of(context).primaryColor,
                    weight: FontWeight.bold,
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: SmallText(
                      text: "Cancel",
                      color: Theme.of(context).primaryColor,
                      weight: FontWeight.bold))
            ],
          );
        });
  }

  Widget statusContainer(DocumentSnapshot document, context) {
    if (document['deliveryPartner']['name'].length > 1) {
      if (document['orderStatus'] == 'Accepted') {
        return Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey[500],
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 8.0, 40, 8),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: statusColor(document)),
                onPressed: () {
                  EasyLoading.show();
                  _orderServices
                      .updateOrderStatus(document.id, "Picked Up")
                      .then((value) {
                    var status = document['orderStatus'];
                    _notificationServices.sendPushMessage(
                        _customer['deviceToken'],
                        "Tap here to know more",
                        "Your order is $status");
                    EasyLoading.showSuccess("Order Status is now Picked Up");
                  });
                },
                child: SmallText(
                  text: "Update status to PickUp",
                  color: Colors.white,
                )),
          ),
        );
      }
    }

    if (document['orderStatus'] == 'Picked Up') {
      return Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[500],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 8.0, 40, 8),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: statusColor(document)),
              onPressed: () {
                EasyLoading.show();
                _orderServices
                    .updateOrderStatus(document.id, "On the way")
                    .then((value) {
                  var status = document['orderStatus'];
                  _notificationServices.sendPushMessage(
                      _customer['deviceToken'],
                      "Tap here to know more",
                      "Your order is $status");
                  EasyLoading.showSuccess("Order Status is now On the way");
                });
              },
              child: SmallText(
                text: 'Update status to On the way',
                color: Colors.white,
              )),
        ),
      );
    }

    if (document['orderStatus'] == 'On the way') {
      return Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[500],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 8.0, 40, 8),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: statusColor(document)),
              onPressed: () {
                if (document['cod'] == true) {
                  return showMyDialog(
                      "Receive Payment", "Delivered", document.id, context);
                } else {
                  EasyLoading.show();
                  _orderServices
                      .updateOrderStatus(document.id, "Delivered")
                      .then((value) {
                    EasyLoading.showSuccess("Order Status is now Delivered");
                  });
                }
              },
              child: SmallText(
                text: 'Deliver Order',
                color: Colors.white,
              )),
        ),
      );
    }

    return Container(
      height: 30,
      width: MediaQuery.of(context).size.width,
      color: Colors.grey[500],
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.green),
          onPressed: () {},
          child: SmallText(
            text: 'Order Completed',
            color: Colors.white,
          )),
    );
  }

  late DocumentSnapshot _customer;

  @override
  void initState() {
    _firebaseServices
        .getCustomerDetails(widget.document['userId'])
        .then((value) {
      if (value != null) {
        setState(() {
          this._customer = value;
        });
      } else {}
    });
    super.initState();
  }

  Color? statusColor(DocumentSnapshot document) {
    if (document['orderStatus'] == 'Accepted') {
      return Colors.blueGrey[400];
    }

    if (document['orderStatus'] == 'Rejected') {
      return Colors.red;
    }

    if (document['orderStatus'] == 'Picked Up') {
      return Colors.pink[900];
    }

    if (document['orderStatus'] == 'On the Way') {
      return Colors.deepPurpleAccent;
    }

    if (document['orderStatus'] == 'Delivered') {
      return Colors.green;
    }

    return Colors.orange;
  }

  Icon? statusIcon(DocumentSnapshot document) {
    if (document['orderStatus'] == 'Accepted') {
      return Icon(
        Icons.assignment_turned_in_outlined,
        color: statusColor(document),
      );
    }

    if (document['orderStatus'] == 'Picked Up') {
      return Icon(
        Icons.store_mall_directory_outlined,
        color: statusColor(document),
      );
    }

    if (document['orderStatus'] == 'On the Way') {
      return Icon(
        Icons.delivery_dining,
        color: statusColor(document),
      );
    }

    if (document['orderStatus'] == 'Delivered') {
      return Icon(
        Icons.shopping_bag_outlined,
        color: statusColor(document),
      );
    }

    return Icon(
      Icons.assignment_turned_in_outlined,
      color: statusColor(document),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Container(
        color: Colors.white,
        child: Column(children: [
          ListTile(
            horizontalTitleGap: 0,
            leading: CircleAvatar(
              radius: 14,
              child: statusIcon(widget.document),
            ),
            title: SmallText(
              text: widget.document['orderStatus'],
              weight: FontWeight.bold,
              color: statusColor(widget.document),
            ),
            trailing: SmallText(
                weight: FontWeight.bold,
                text:
                    "Amount : \$${widget.document['total'].toStringAsFixed(0)}"),
            subtitle: SmallText(
                text:
                    "On ${DateFormat.yMMMd().format((widget.document['timestamp'] as Timestamp).toDate())}"),
          ),
          _customer != null
              ? ListTile(
                  contentPadding: EdgeInsets.only(left: 10, right: 10),
                  title: Row(
                    children: [
                      SmallText(text: "Customer : "),
                      SmallText(
                        text: '${_customer['name']}',
                        maxLines: 1,
                        overFlow: TextOverflow.ellipsis,
                        weight: FontWeight.bold,
                      ),
                    ],
                  ),
                  subtitle: SmallText(
                    text: _customer['address'],
                    maxLines: 1,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          _orderServices.launchMap(_customer['latitude'],
                              _customer['longitude'], _customer['name']);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(4)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8, top: 2, bottom: 2),
                              child: Icon(
                                Icons.map,
                                color: Colors.white,
                              ),
                            )),
                      ),
                      SizedBox(
                        width: Dimensions.width10,
                      ),
                      InkWell(
                        onTap: () {
                          _orderServices
                              .launchCall('tel:${_customer['number']}');
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(4)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8, top: 2, bottom: 2),
                              child: Icon(
                                Icons.phone_in_talk,
                                color: Colors.white,
                              ),
                            )),
                      ),
                    ],
                  ),
                )
              : Container(),
          ExpansionTile(
            title: SmallText(
              text: "Order details",
              size: 10,
              color: Colors.black,
            ),
            subtitle: SmallText(
              text: "View Order details",
              color: Colors.grey,
            ),
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.document['products'].length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.network(
                            widget.document['products'][index]['productImage']),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SmallText(
                              text: widget.document['products'][index]
                                  ['productName']),
                          SizedBox(height: Dimensions.height10),
                          if (widget.document['products'][index]['itemSize'] !=
                              null)
                            SmallText(
                                text:
                                    "Size : ${widget.document['products'][index]['itemSize']}"),
                          if ((widget.document['products'][index]
                                  as Map<String, dynamic>)
                              .containsKey("toppings"))
                            Column(
                              children: (widget.document['products'][index]
                                      ["toppings"] as List)
                                  .map((topping) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SmallText(
                                      text: topping["name"],
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: Dimensions.width5,
                                    ),
                                    SmallText(
                                      text: (topping["type"] as String)
                                          .capitalize!,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: Dimensions.width5,
                                    ),
                                    SmallText(
                                      text: "\$${topping["price"]}",
                                      weight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                      subtitle: SmallText(
                          color: Colors.grey,
                          text:
                              '${widget.document['products'][index]['qty']} x \$${widget.document['products'][index]['price'].toStringAsFixed(0)}'),
                    );
                  }),
            ],
          ),
          Divider(
            height: 3,
            color: Colors.grey,
          ),
          statusContainer(widget.document, context),
          Divider(
            height: 3,
            color: Colors.grey,
          )
        ]),
      ),
    );
  }
}
