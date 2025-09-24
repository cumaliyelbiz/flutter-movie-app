import 'package:filmuygulamasi/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_provider.dart';  // CartProvider'ı import edin
import 'user_model.dart';     // UserModel'i import edin

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()), // Sepet provider'ı
        ChangeNotifierProvider(create: (context) => UserModel()),   // Kullanıcı provider'ı
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film Uygulaması',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthScreen(),  // Giriş ekranı
    );
  }
}
