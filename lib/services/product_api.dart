import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductApi {
  static const String _url = 'https://dummyjson.com/products?limit=194';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode != 200) {
      throw Exception('Erreur réseau (code ${response.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> productsJson = data['products'];

    return productsJson
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
