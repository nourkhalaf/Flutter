import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:real_shop/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders extends ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken = '';
  String userId = '';

  getData(String token, String uId, List<OrderItem> orders) {
    authToken = token;
    userId = uId;
    _orders = orders;
    notifyListeners();
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://fluttershop-77426-default-rtdb.firebaseio.com/Orders/$userId.json?auth=$authToken';

    try {
      final res = await http.get(Uri.parse(url));
      final extractedData = json.decode(res.body) as Map<String, dynamic>?;
      if (extractedData == null) return;

      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price']))
              .toList(),
        ));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    print(userId);
    print('here..........' + authToken);
    final url =
        'https://fluttershop-77426-default-rtdb.firebaseio.com/Orders/$userId.json?auth=$authToken';

    try {
      final timestamp = DateTime.now();
      print(timestamp.toIso8601String());
      final res = await http.post(Uri.parse(url),
          body: json.encode({
            'amount': total,
            'dateTime': timestamp.toIso8601String(),
            'products': cartProducts
                .map((cartProduct) => {
                      'id': cartProduct.id,
                      'title': cartProduct.title,
                      'price': cartProduct.price,
                      'quantity': cartProduct.quantity,
                    })
                .toList(),
          }));
      _orders.insert(
        0,
        OrderItem(
            id: json.decode(res.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timestamp),
      );
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
