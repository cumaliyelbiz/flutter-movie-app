import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<dynamic> _cartItems = [];

  List<dynamic> get cartItems => _cartItems;

  // Sepete ürün ekle
  void addToCart(dynamic item) {
    // Sepette aynı film olup olmadığını kontrol et
    if (_cartItems.any((film) => film['id'] == item['id'])) {
      // Eğer film zaten sepette varsa, ekleme yapma
      return;
    }
    _cartItems.add(item);
    notifyListeners(); // Durum değiştiği için dinleyicilere bildirim gönder
  }

  // Sepetten ürün çıkar
  void removeFromCart(int index) {
    _cartItems.removeAt(index);
    notifyListeners(); // Durum değiştiği için dinleyicilere bildirim gönder
  }

  // Sepetteki ürünlerin sayısını döndür
  int get itemCount => _cartItems.length;

  // Sepeti temizle
  void clearCart() {
    _cartItems.clear();  // Sepetteki tüm öğeleri sil
    notifyListeners();  // Durum değiştiği için dinleyicilere bildirim gönder
  }
}
