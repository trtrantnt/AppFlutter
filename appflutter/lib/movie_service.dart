import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieService {
  final String apiKey = 'e6d899a70dd551f01adc329ce1d213e2'; // Thay thế bằng API key của bạn
  final String apiUrl = 'https://api.themoviedb.org/3/movie/popular?api_key=';

  Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse('$apiUrl$apiKey'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['results'];
      return jsonResponse.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }
}

class Movie {
  final String title;
  final String posterPath;

  Movie({required this.title, required this.posterPath});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      posterPath: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
    );
  }
}