import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int authbuttondurum = 1;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final APIService apiService = APIService();

  void authButton(int durum) async {
    setState(() {
      authbuttondurum = durum == 0 ? 1 : 0;
    });
  }

  void girisYap() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Lütfen tüm alanları doldurun');
      return;
    }

    try {
      final response = await apiService.loginUser(email, password);
      debugPrint("Giriş başarılı: $response");
      goToAuthScreen(response['userId']);
    } catch (e) {
      _showError('Giriş işlemi başarısız: $e');
    }
  }

  void kayitOl() async {
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Lütfen tüm alanları doldurun');
      return;
    }

    if (password != confirmPassword) {
      _showError('Şifreler eşleşmiyor');
      return;
    }

    try {
      // Kayıt işlemi
      final response = await apiService.registerUser(email, password);
      debugPrint("Kayıt başarılı: $response");
      goToAuthScreen(response['userId']);
    } catch (e) {
      _showError('Kayıt işlemi başarısız: $e');
    }
  }

  void goToAuthScreen(int userId)
  {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(
        userId: userId,
      )),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hata'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Üstteki dalgalı tasarım
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 200),
              painter: CurvePainter(),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Hoş Geldiniz',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Lütfen giriş yapın',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Input
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Şifre Input
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tekrar Şifre Input
                  authbuttondurum == 0
                      ? Column(
                    children: [
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Tekrar Şifre',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                      : Container(),

                  // Giriş Yap Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (authbuttondurum == 1) {
                          girisYap();
                        } else {
                          kayitOl();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        authbuttondurum == 1 ? 'Giriş Yap' : 'Kayıt Ol',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kayıt Ol Butonu
                  TextButton(
                    onPressed: () {
                      authButton(authbuttondurum);
                    },
                    child: Text(
                      authbuttondurum == 1
                          ? 'Hesabınız yok mu? Kayıt Olun'
                          : 'Hesabınız var mı? Giriş Yapın',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.orange;
    paint.style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.25, size.height * 0.7, size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.9, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
