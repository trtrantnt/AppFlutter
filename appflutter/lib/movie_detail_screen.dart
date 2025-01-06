import 'package:flutter/material.dart';
import 'video_player_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final String title;
  final String posterPath;
  final String overview;
  final String videoUrl;

  MovieDetailScreen({
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.videoUrl,
  });

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.posterPath),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.overview,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        title: widget.title,
                        overview: widget.overview,
                        videoUrl: widget.videoUrl,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.play_arrow),
                label: Text('Xem phim'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Màu nền của nút
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}