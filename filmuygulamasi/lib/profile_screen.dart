import 'package:flutter/material.dart';
import 'film_video_detail_screen.dart';
import 'home_screen.dart'; // HomeScreen'i import et
import 'api_service.dart'; // API'den veri çekmek için gerekli

class ProfileScreen extends StatelessWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          } else {
            var userData = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı Bilgileri Bölümü
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['email'] ?? 'user@example.com', // Default name
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Satın Alınan Film Sayısı Burada
                          FutureBuilder<List<dynamic>>(
                            future: _fetchPurchasedFilms(userId),
                            builder: (context, filmsSnapshot) {
                              if (filmsSnapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (filmsSnapshot.hasError) {
                                return Text('Error: ${filmsSnapshot.error}');
                              } else if (!filmsSnapshot.hasData || filmsSnapshot.data!.isEmpty) {
                                return const Text('Satın Alınan Film Sayısı: 0',
                                    style: TextStyle(fontSize: 16, color: Colors.grey));
                              } else {
                                var films = filmsSnapshot.data!;
                                return Text(
                                  'Satın Alınan Film Sayısı: ${films.length}',
                                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 30, color: Colors.grey),

                // Kullanıcının Aldığı Filmler Bölümü
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Purchased Films',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                // Kullanıcının Aldığı Filmleri Listeleme
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _fetchPurchasedFilms(userId),
                    builder: (context, filmsSnapshot) {
                      if (filmsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (filmsSnapshot.hasError) {
                        return Center(child: Text('Error: ${filmsSnapshot.error}'));
                      } else if (!filmsSnapshot.hasData || filmsSnapshot.data!.isEmpty) {
                        return const Center(child: Text('No films found'));
                      } else {
                        var films = filmsSnapshot.data!;
                        return ListView.builder(
                          itemCount: films.length,
                          itemBuilder: (context, index) {
                            var film = films[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                                title: Text(film['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(film['description']),
                                trailing: Text(
                                  '${film['price']} \$',
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  // Film tıklandığında, film detayları sayfasına yönlendirme
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FilmVideoDetailScreen(
                                        videoUrl: film['video_url'], // Film URL'sini geçiyoruz
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(userId: userId)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                // Zaten profil sayfasındasınız, burada başka bir şey yapılmaz
              },
            ),
          ],
        ),
      ),
    );
  }

  // Kullanıcı verilerini çekmek için API servisi
  Future<Map<String, dynamic>> _fetchUserData(int userId) async {
    var response = await APIService().getUserData(userId); // API çağrısını yapıyoruz
    return response;
  }

  // Kullanıcının aldığı filmleri çekmek için API servisi
  Future<List<dynamic>> _fetchPurchasedFilms(int userId) async {
    var response = await APIService().getPurchasedFilms(userId); // API çağrısını yapıyoruz
    return response;
  }
}
