import 'package:flutter/material.dart';
import 'package:filmuygulamasi/api_service.dart';
import 'package:filmuygulamasi/cart_provider.dart'; // CartProvider'ı import et
import 'package:provider/provider.dart';  // Provider paketini import et
import 'cardpage.dart';
import 'film_detail_screen.dart';
import 'profile_screen.dart'; // Profile ekranı import et

enum Category { all, adventure, horror, animation, comedy }

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> films;
  List<dynamic> allFilms = [];
  List<dynamic> filteredFilms = [];
  Category? selectedCategory = Category.all;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    films = APIService().getFilms(widget.userId);
  }

  void filterFilmsByCategory(Category category) {
    setState(() {
      selectedCategory = category;
      if (category == Category.all) {
        filteredFilms = allFilms;
      } else {
        filteredFilms = allFilms
            .where((film) =>
        film['category'] == category.toString().split('.').last)
            .toList();
      }
    });
  }

  void searchFilms(String query) {
    setState(() {
      filteredFilms = allFilms
          .where((film) =>
      film['name'].toLowerCase().contains(query.toLowerCase()) ||
          film['description']
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Films"),
        actions: [
          Consumer<CartProvider>( // Sepet iconu
            builder: (context, cartProvider, child) {
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cartProvider.itemCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            cartProvider.itemCount.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  // Sepet sayfasına yönlendirme
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartPage(userId: widget.userId,)),
                  );
                },
              );
            },
          ),
          PopupMenuButton<Category>(
            onSelected: filterFilmsByCategory,
            itemBuilder: (BuildContext context) {
              return Category.values.map((Category category) {
                return PopupMenuItem<Category>(
                  value: category,
                  child: Text(category == Category.all
                      ? 'All Categories'
                      : category.toString().split('.').last),
                );
              }).toList();
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: films,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No films found'));
          } else {
            if (allFilms.isEmpty) {
              allFilms = snapshot.data!;
              filteredFilms = allFilms;
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: searchFilms,
                    decoration: InputDecoration(
                      hintText: 'Search for a film...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredFilms.length,
                    itemBuilder: (context, index) {
                      final film = filteredFilms[index];
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
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${film['price']} \$',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: const Icon(Icons.add_shopping_cart),
                                  onPressed: () {
                                    context.read<CartProvider>().addToCart(film);
                                  },
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FilmDetailScreen(filmId: film['id']),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Home butonuna tıklanırsa HomeScreen'e yönlendir
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(userId: widget.userId),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                // Profile butonuna tıklanırsa ProfileScreen'e yönlendir
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: widget.userId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
