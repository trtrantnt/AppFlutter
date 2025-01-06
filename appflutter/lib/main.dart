import 'package:appflutter/movie_detail_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(user: FirebaseAuth.instance.currentUser!),
        '/movie_detail': (context) => MovieDetailScreen(
          title: '',
          posterPath: '',
          overview: '',
          videoUrl: '', // Thêm thuộc tính videoUrl
        ),
      },
    );
  }
}