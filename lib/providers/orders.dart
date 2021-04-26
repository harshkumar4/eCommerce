import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    print(_orders.length);
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final List<OrderItem> loadedOrders = [];
    final url = Uri.parse(
        'https://shop-app-academin-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final orders = json.decode(response.body) as Map<String, dynamic>;
    if (orders == null) return;
    orders.forEach((orderId, order) {
      loadedOrders.add(
        OrderItem(
            id: orderId,
            amount: order['amount'],
            dateTime: DateTime.parse(order['dateTime']),
            products: (order['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    price: item['price'],
                    quantity: item['quantity'],
                  ),
                )
                .toList()),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) {
    final url = Uri.parse(
        'https://shop-app-academin-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();
    return http
        .post(url,
            body: json.encode({
              'amount': total,
              'dateTime': timestamp.toIso8601String(),
              'products': cartProducts
                  .map((ci) => {
                        'id': ci.id,
                        'title': ci.title,
                        'quantity': ci.quantity,
                        'price': ci.price,
                      })
                  .toList(),
            }))
        .then((response) => {
              _orders.insert(
                0,
                OrderItem(
                  id: json.decode(response.body)['name'],
                  amount: total,
                  products: cartProducts,
                  dateTime: timestamp,
                ),
              ),
              notifyListeners()
            });
  }
}
