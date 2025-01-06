import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String title;
  final String overview;
  final String videoUrl;

  VideoPlayerScreen({
    required this.title,
    required this.overview,
    required this.videoUrl,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            aspectRatio: _videoPlayerController.value.aspectRatio,
            autoPlay: true,
            looping: false,
          );
        });
      }).catchError((error) {
        print('Lỗi khi khởi tạo video: $error');
      });

    _fetchRating();
  }

  Future<void> _fetchRating() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('movies').doc(widget.title).get();
    if (doc.exists) {
      setState(() {
        _rating = doc['rating'];
      });
    }
  }

  Future<void> _updateRating(double rating) async {
    await FirebaseFirestore.instance.collection('movies').doc(widget.title).set({
      'rating': rating,
    });
    setState(() {
      _rating = rating;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

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
            Center(
              child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
                      child: Chewie(
                        controller: _chewieController!,
                      ),
                    )
                  : CircularProgressIndicator(),
            ),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow),
                  SizedBox(width: 8),
                  Text(
                    _rating.toString(),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Đánh giá:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.star, color: _rating >= 1 ? Colors.yellow : Colors.grey),
                    onPressed: () => _updateRating(1),
                  ),
                  IconButton(
                    icon: Icon(Icons.star, color: _rating >= 2 ? Colors.yellow : Colors.grey),
                    onPressed: () => _updateRating(2),
                  ),
                  IconButton(
                    icon: Icon(Icons.star, color: _rating >= 3 ? Colors.yellow : Colors.grey),
                    onPressed: () => _updateRating(3),
                  ),
                  IconButton(
                    icon: Icon(Icons.star, color: _rating >= 4 ? Colors.yellow : Colors.grey),
                    onPressed: () => _updateRating(4),
                  ),
                  IconButton(
                    icon: Icon(Icons.star, color: _rating >= 5 ? Colors.yellow : Colors.grey),
                    onPressed: () => _updateRating(5),
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