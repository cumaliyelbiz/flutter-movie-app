// Cart.dart (Sepet Modeli)
class Cart {
  static final List<Map<String, dynamic>> _cartItems = [];

  // Sepete ekle
  static void addToCart(Map<String, dynamic> film) {
    _cartItems.add(film);
  }

  // Sepetteki tüm ürünleri al
  static List<Map<String, dynamic>> getCartItems() {
    return _cartItems;
  }

  // Sepeti temizle
  static void clearCart() {
    _cartItems.clear();
  }
}
