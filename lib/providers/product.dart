import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  void _setOldFavVal(bool newVal) {
    isFavourite = newVal;
    notifyListeners();
  }

  Future<void> toggleFavourite(String token, String userId) {
    final oldStatus = isFavourite;
    final url = Uri.parse(
        'https://shop-app-academin-default-rtdb.firebaseio.com/userFav/$userId/$id.json?auth=$token');

    isFavourite = !isFavourite;
    notifyListeners();
    print(id);
    return http
        .put(
      url,
      body: json.encode(
        isFavourite,
      ),
    )
        .then((response) {
      if (response.statusCode >= 400) {
        _setOldFavVal(oldStatus);
      }
    }).catchError((_) {
      _setOldFavVal(oldStatus);
    });
  }
}
