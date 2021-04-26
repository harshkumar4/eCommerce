import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/order_item.dart';
import '../widgets/drawer.dart';

import '../providers/orders.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.error != null) {
            return Center(
              child: Text('An error ocurred'),
            );
          } else {
            return Consumer<Orders>(
              builder: (context, orderData, child) => orderData.orders.length <=
                      0
                  ? Center(
                      child: Text('No orders yet!'),
                    )
                  : ListView.builder(
                      itemBuilder: (_, i) => OrderItemWid(orderData.orders[i]),
                      itemCount: orderData.orders.length,
                    ),
            );
          }
        },
      ),
      drawer: DrawerWid(),
    );
  }
}
