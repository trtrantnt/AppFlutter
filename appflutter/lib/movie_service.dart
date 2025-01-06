import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class MovieService {
  final String apiKey = 'e6d899a70dd551f01adc329ce1d213e2'; // Thay thế bằng API key của bạn
  final String apiUrl = 'https://api.themoviedb.org/3/movie/popular?api_key=';

  Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse('$apiUrl$apiKey'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['results'];
      List<Movie> movies = jsonResponse.map((movie) => Movie.fromJson(movie)).toList();
      List<String> videoUrls = await fetchVideoUrls();
      for (int i = 0; i < movies.length; i++) {
        movies[i].videoUrl = videoUrls[i % videoUrls.length];
      }
      return movies;
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<List<String>> fetchVideoUrls() async {
    final String response = await rootBundle.loadString('assets/videourls.json');
    List<dynamic> jsonResponse = json.decode(response);
    return jsonResponse.map((video) => video['videoUrl'] as String).toList();
  }
}

class Movie {
  final String title;
  final String posterPath;
  final String overview;
  final double rating;
  String? videoUrl;

  Movie({required this.title, required this.posterPath, required this.overview, required this.rating, this.videoUrl});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      posterPath: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
      overview: json['overview'],
      rating: json['vote_average'].toDouble(),
    );
  }
}