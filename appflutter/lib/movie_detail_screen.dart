import 'package:flutter/material.dart';
import 'video_player_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  User? _currentUser;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchComments();
    _checkIfFavorite();
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
        'posterPath': widget.posterPath,
        'overview': widget.overview,
        'videoUrl': widget.videoUrl,
      });
    }
    _checkIfFavorite();
  }

  @override
  void dispose() {
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