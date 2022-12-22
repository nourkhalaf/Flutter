import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:real_shop/model/http_exception.dart';
import 'package:real_shop/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> productsList = [];

  List<Product> _items = [];

  String authToken = '';
  String userId = '';

  getData(String token, String uId, List<Product> products) {
    authToken = token;
    userId = uId;
    _items = products;
    notifyListeners();
  }

  List<Product> get items {
    fetchAndSetProducts();
    return [..._items];
  }

  List<Product> get favoritesItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prodItem) => prodItem.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filteredString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';

    //& to filter data in firebase
    var url =
        'https://fluttershop-77426-default-rtdb.firebaseio.com/Products.json?auth=$authToken&$filteredString';

    try {
      final res = await http.get(Uri.parse(url));
      Map<String, dynamic>? extractedData =
          json.decode(res.body) as Map<String, dynamic>?;
      if (extractedData == null) return;
      url =
          'https://fluttershop-77426-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final favRes = await http.get(Uri.parse(url));
      final favData = json.decode(favRes.body) as Map<String, dynamic>?;
      final List<Product> loadedProducts = [];
      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          //isFavorite: false,
          isFavorite: favData == null ? false : favData[productId] ?? false,
          imageUrl: productData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://fluttershop-77426-default-rtdb.firebaseio.com/Products.json?auth=$authToken';

    try {
      final res = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          }));
      final newProduct = Product(
          id: json.decode(res.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);

    if (prodIndex >= 0) {
      final url =
          'https://fluttershop-77426-default-rtdb.firebaseio.com/Products/$id.json?auth=$authToken';

      final res = await http.patch(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));

      _items[prodIndex] = product;
      notifyListeners();
    } else {
      print("...");
    }
  }

  Future<void> delteProduct(String id) async {
    final url =
        'https://fluttershop-77426-default-rtdb.firebaseio.com/Products/$id.json?auth=$authToken';

    final existingProdIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProdIndex];
    _items.removeAt(existingProdIndex);
    notifyListeners();

    final res = await http.delete(Uri.parse(url));

    if (res.statusCode >= 400) {
      _items.insert(existingProdIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }

  Future<void> fetchData() async {
    const url = "https://flutter-app-568d3.firebaseio.com/product.json";
    try {
      final http.Response res = await http.get(Uri.parse(url));
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      extractedData.forEach((prodId, prodData) {
        final prodIndex =
            productsList.indexWhere((element) => element.id == prodId);
        if (prodIndex >= 0) {
          productsList[prodIndex] = Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
          );
        } else {
          productsList.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
          ));
        }
      });

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateData(String id) async {
    final url = "https://flutter-app-568d3.firebaseio.com/product/$id.json";

    final prodIndex = productsList.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      await http.patch(Uri.parse(url),
          body: json.encode({
            "title": "new title 4",
            "description": "new description 2",
            "price": 199.8,
            "imageUrl":
                "https://cdn.pixabay.com/photo/2015/06/19/21/24/the-road-815297__340.jpg",
          }));

      productsList[prodIndex] = Product(
        id: id,
        title: "new title 4",
        description: "new description 2",
        price: 199.8,
        imageUrl:
            "https://cdn.pixabay.com/photo/2015/06/19/21/24/the-road-815297__340.jpg",
      );

      notifyListeners();
    } else {
      print("...");
    }
  }

  /*Future<void> add(
      {String id,
      String title,
      String description,
      double price,
      String imageUrl}) async {
    const url = "https://flutter-app-568d3.firebaseio.com/product.json";
    try {
      http.Response res = await http.post(Uri.parse(url),
          body: json.encode({
            "title": title,
            "description": description,
            "price": price,
            "imageUrl": imageUrl,
          }));
      print(json.decode(res.body));

      productsList.add(Product(
        id: json.decode(res.body)['name'],
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
      ));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> delete(String id) async {
    final url = "https://flutter-app-568d3.firebaseio.com/product/$id.json";

    final prodIndex = productsList.indexWhere((element) => element.id == id);
     Product? prodItem = productsList[prodIndex];
    productsList.removeAt(prodIndex);
    notifyListeners();

    var res = await http.delete(Uri.parse(url));
    if (res.statusCode >= 400) {
      productsList.insert(prodIndex, prodItem);
      notifyListeners();
      print("Could not deleted item");
    } else {
      prodItem = null;
      print("Item deleted");
    }
  }*/
}
