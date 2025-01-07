import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  double _averageRating = 0.0;
  int _ratingCount = 0;
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  User? _currentUser;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
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

    _fetchRatings();
    _fetchComments();
    _checkIfFavorite();
  }

  Future<void> _fetchRatings() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('movies').doc(widget.title).collection('ratings').get();
    if (querySnapshot.docs.isNotEmpty) {
      double totalRating = 0.0;
      int ratingCount = querySnapshot.docs.length;
      for (var doc in querySnapshot.docs) {
        totalRating += doc['rating'];
      }
      setState(() {
        _averageRating = totalRating / ratingCount;
        _ratingCount = ratingCount;
      });
    }
  }

  Future<void> _fetchComments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('movies').doc(widget.title).collection('comments').get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _comments = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    }
  }

  Future<void> _addComment(String comment) async {
    await FirebaseFirestore.instance.collection('movies').doc(widget.title).collection('comments').add({
      'comment': comment,
      'username': _currentUser?.displayName ?? 'Ẩn danh',
      'timestamp': FieldValue.serverTimestamp(),
    });
    _fetchComments(); // Cập nhật danh sách bình luận sau khi thêm bình luận mới
  }

  Future<void> _updateRating(double rating) async {
    await FirebaseFirestore.instance.collection('movies').doc(widget.title).collection('ratings').add({
      'rating': rating,
    });
    _fetchRatings(); // Cập nhật điểm đánh giá trung bình sau khi thêm đánh giá mới
  }

  Future<void> _checkIfFavorite() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(_currentUser?.uid).collection('favorites').doc(widget.title).get();
    setState(() {
      _isFavorite = doc.exists;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser?.uid).collection('favorites').doc(widget.title).delete();
    } else {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser?.uid).collection('favorites').doc(widget.title).set({
        'title': widget.title,
        'overview': widget.overview,
        'videoUrl': widget.videoUrl,
      });
    }
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
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
                    _averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '($_ratingCount đánh giá)',
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
                    icon: Icon(Icons.star, color: _averageRating >= 1 ? Colors.yellow : Colors.grey),
                    onPressed: () => _updateRating(1),
                  ),
                  IconButton(
                    icon: Icon(Icons.star, color: _averageRating >= 2 ? Colors.yellow : Colors.grey),
                    onPressed: () => _updateRating(2),
                  ),
                  IconButton(
                    icon: Icon(Icons.star, color: _averageRating >= 3 ? Colors.yellow : Colors.grey),
                    onPressed: () => _updateRating(3),
                  ),
                  IconButton(
                    icon: Icon(Icons.star, color: _averageRating >= 4 ? Colors.yellow : Colors.grey),
                    onPressed: () => _updateRating(4),
                  ),
                  IconButton(
                    icon: Icon(Icons.star, color: _averageRating >= 5 ? Colors.yellow : Colors.grey),
                    onPressed: () => _updateRating(5),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bình luận:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nhập bình luận của bạn',
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_commentController.text.isNotEmpty) {
                        _addComment(_commentController.text);
                        _commentController.clear();
                      }
                    },
                    child: Text('Gửi'),
                  ),
                  SizedBox(height: 16),
                  ..._comments.map((comment) => ListTile(
                        title: Text(comment['comment']),
                        subtitle: Text(
                          '${comment['username']} - ${comment['timestamp'] != null ? (comment['timestamp'] as Timestamp).toDate().toString() : 'Đang xử lý...'}',
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}