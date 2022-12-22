import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/widgets/app_drawer.dart';
import 'package:real_shop/widgets/order_item.dart';
import '../providers/orders.dart' show Orders;

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Order')),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.error != null) {
              return Center(
                child: Text(''),
              );
            } else {
              return Consumer<Orders>(
                  builder: (context, orderValue, child) => ListView.builder(
                      itemCount: orderValue.orders.length,
                      itemBuilder: (context, index) =>
                          OrderItem(orderValue.orders[index])));
            }
          }
        },
      ),
    );
  }
}
