import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider'ı import ediyoruz
import 'cart_provider.dart';  // CartProvider'ı import ediyoruz
import 'package:filmuygulamasi/api_service.dart';

class FilmDetailScreen extends StatefulWidget {
  final int filmId;

  const FilmDetailScreen({super.key, required this.filmId});

  @override
  State<FilmDetailScreen> createState() => _FilmDetailScreenState();
}

class _FilmDetailScreenState extends State<FilmDetailScreen> {
  late Future<Map<String, dynamic>> filmDetails;

  @override
  void initState() {
    super.initState();
    filmDetails = APIService().getFilmDetails(widget.filmId); // Film detaylarını al
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,  // Şeffaf AppBar
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // İkon rengi beyaz
      ),
      extendBodyBehindAppBar: true,  // AppBar arkasındaki içerik gösterilsin
      body: FutureBuilder<Map<String, dynamic>>(
        future: filmDetails, // API'den alınan film detayları
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No details found'));
          } else {
            final film = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Film resmi
                    film['image_url'] != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        'http://10.0.2.2:3000/images/${film['image_url']}',
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(
                      Icons.image,
                      size: 300,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),

                    // Film adı
                    Text(
                      film['name'],
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Film açıklaması
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        film['description'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Fiyat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Price: ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "\$${film['price'].toString()}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Sepete ekle butonu
                    ElevatedButton(
                      onPressed: () {
                        // CartProvider üzerinden addToCart metodunu çağırıyoruz
                        Provider.of<CartProvider>(context, listen: false).addToCart(film);
                        // Sepete ekleme işlemi sonrası kullanıcıya mesaj göster
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${film['name']} has been added to the cart!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent, // Buton rengi
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // Yuvarlatılmış köşeler
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }
        },
      ),
      backgroundColor: Colors.black87, // Koyu arka plan
    );
  }
}
