import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
  static const String baseUrl = 'http://10.0.2.2:3000'; // API'nizin URL'sini buraya yazın

  // Kayıt Olma İşlemi
  Future<Map<String, dynamic>> registerUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/register'); // Kayıt URL'si

    final response = await http.post(
      url,
      body: json.encode({
        'email': email,
        'password': password,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      return json.decode(response.body); // Başarılı yanıt döner
    } else {
      throw Exception('Kayıt işlemi başarısız!'); // Hata durumunda exception fırlatır
    }
  }

  // Giriş Yapma İşlemi
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/login'); // Giriş URL'si

    final response = await http.post(
      url,
      body: json.encode({
        'email': email,
        'password': password,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Başarılı yanıt döner
    } else {
      throw Exception('Giriş işlemi başarısız!'); // Hata durumunda exception fırlatır
    }
  }

  Future<List<dynamic>> getFilms(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/getfilms/$userId'));

    if (response.statusCode == 200) {
      // JSON verisini parse et
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load films');
    }
  }

  Future<Map<String, dynamic>> getFilmDetails(int filmId) async {
    // API URL'sine filmId parametresini ekliyoruz
    final response = await http.get(Uri.parse('$baseUrl/films/$filmId'));

    if (response.statusCode == 200) {
      // Eğer API çağrısı başarılıysa, JSON verisini döndürüyoruz
      return json.decode(response.body);
    } else {
      // API çağrısı başarısızsa, hata fırlatıyoruz
      throw Exception('Failed to load film details');
    }
  }

  Future<void> placeOrder(List<dynamic> cartItems, int userId) async {
    try {
      final url = Uri.parse('http://10.0.2.2:3000/orders');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'cartItems': cartItems.map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'price': item['price'],
            };
          }).toList(),
        }),
      );

      if (response.statusCode == 201) {
        print("Order placed successfully");
      } else {
        print("Failed to place order: ${response.body}");
      }
    } catch (e) {
      print("Error placing order: $e");
    }
  }


  Future<Map<String, dynamic>> getUserData(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body); // API'den gelen kullanıcı verisini döndürüyoruz
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // Kullanıcının aldığı filmleri almak
  Future<List<dynamic>> getPurchasedFilms(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/purchased_films/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body); // API'den gelen film verilerini döndürüyoruz
    } else {
      throw Exception('Failed to load purchased films');
    }
  }

}
