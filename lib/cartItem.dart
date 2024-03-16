import 'package:tespay/product.dart';

class ShoppingCartItem {
  final Product product;
  final int quantity;

  ShoppingCartItem({
    required this.product,
    required this.quantity,
  });

  calculateSubtotalProduct() {
    int totalProduct = int.parse(product.price) * quantity;
    return totalProduct;
  }
}
