import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';  // CartProvider'ı import et
import 'api_service.dart';  // APIService'ı import et

class CartPage extends StatelessWidget {
  final int userId; // userId'yi burada tanımlıyoruz

  // Constructor'da userId parametresini alıyoruz
  const CartPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final cartItems = cartProvider.cartItems;
          return cartItems.isEmpty
              ? const Center(child: Text('No items in your cart'))
              : ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final film = cartItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: film['image_url'] != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'http://10.0.2.2:3000/images/${film['image_url']}',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Icon(Icons.image, size: 100),
                  title: Text(
                    film['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(film['description']),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_shopping_cart),
                    onPressed: () {
                      // Sepetten kaldır
                      context.read<CartProvider>().removeFromCart(index);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      // Alışverişi Tamamla butonunu ekliyoruz
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Alışverişi tamamlamak için kullanıcıya onay ver
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Checkout'),
                content: const Text('Do you want to complete your purchase?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // API'ye siparişi gönder
                      final cartItems = context.read<CartProvider>().cartItems;
                      await APIService().placeOrder(cartItems,userId);

                      // Sepeti temizle
                      context.read<CartProvider>().clearCart();

                      Navigator.pop(context); // Dialogu kapat
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Purchase Completed!')),
                      );
                    },
                    child: const Text('Yes'),
                  ),
                ],
              );
            },
          );
        },  // Ödeme simgesi
        tooltip: 'Complete your purchase',
        child: const Icon(Icons.payment),
      ),
    );
  }
}
