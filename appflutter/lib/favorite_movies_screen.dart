import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'movie_detail_screen.dart';

class FavoriteMoviesScreen extends StatefulWidget {
  @override
  _FavoriteMoviesScreenState createState() => _FavoriteMoviesScreenState();
}

class _FavoriteMoviesScreenState extends State<FavoriteMoviesScreen> {
  User? _currentUser;
  List<Map<String, dynamic>> _favoriteMovies = [];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchFavoriteMovies();
  }

  Future<void> _fetchFavoriteMovies() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').doc(_currentUser?.uid).collection('favorites').get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _favoriteMovies = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phim Yêu Thích'),
      ),
      body: _favoriteMovies.isEmpty
          ? Center(child: Text('Không có phim yêu thích nào'))
          : ListView.builder(
              itemCount: _favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = _favoriteMovies[index];
                return ListTile(
                  leading: Image.network(movie['posterPath']),
                  title: Text(movie['title']),
                  subtitle: Text(movie['overview']),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(
                          title: movie['title'],
                          posterPath: movie['posterPath'],
                          overview: movie['overview'],
                          videoUrl: movie['videoUrl'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}