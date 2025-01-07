import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'movie_service.dart';
import 'movie_detail_screen.dart';
import 'favorite_movies_screen.dart';
import 'TimKiem.dart'; // Thêm dòng này để nhập khẩu SearchWidget

class HomeScreen extends StatefulWidget {
  final User user;

  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> futureMovies;
  List<Movie> _filteredMovies = [];

  @override
  void initState() {
    super.initState();
    futureMovies = MovieService().fetchMovies();
    futureMovies.then((movies) {
      setState(() {
        _filteredMovies = movies;
      });
    });
  }

  void _onSearch(String query) {
    futureMovies.then((movies) {
      setState(() {
        _filteredMovies = movies.where((movie) => movie.title.toLowerCase().contains(query.toLowerCase())).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/1.png',
          height: 50,
          width: 50,
        ),
        actions: [
          SearchWidget(onSearch: _onSearch), // Thêm thanh tìm kiếm vào AppBar
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(context).pushNamed('/favorites');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: futureMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có phim nào'));
          } else {
            return ListView.builder(
              itemCount: _filteredMovies.length,
              itemBuilder: (context, index) {
                final movie = _filteredMovies[index];
                return ListTile(
                  leading: Image.network(movie.posterPath),
                  title: Text(movie.title),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(
                          title: movie.title,
                          posterPath: movie.posterPath,
                          overview: movie.overview,
                          videoUrl: movie.videoUrl ?? '', // Sử dụng URL video từ danh sách
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}