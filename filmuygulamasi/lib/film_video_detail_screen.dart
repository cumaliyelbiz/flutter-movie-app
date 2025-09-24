import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FilmVideoDetailScreen extends StatefulWidget {
  final String videoUrl; // Video URL'sini alıyoruz
  const FilmVideoDetailScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _FilmVideoDetailScreenState createState() => _FilmVideoDetailScreenState();
}

class _FilmVideoDetailScreenState extends State<FilmVideoDetailScreen> {
  late YoutubePlayerController _youtubePlayerController;

  @override
  void initState() {
    super.initState();
    // Video URL'sinden ID'yi ayıklıyoruz
    String videoId = _extractVideoId(widget.videoUrl);

    // YouTubePlayerController'ı başlatıyoruz
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,  // Otomatik oynatma
        mute: false,     // Ses açma
      ),
    );
  }

  // YouTube URL'sinden video ID'sini çıkaran fonksiyon
  String _extractVideoId(String url) {
    // https://www.youtube.com/watch?v=video_id şeklinde URL'den ID'yi ayıklıyoruz
    RegExp regExp = RegExp(r"(?<=watch\?v=)([a-zA-Z0-9_-]+)");
    Match? match = regExp.firstMatch(url);
    return match?.group(0) ?? ''; // ID'yi döndür
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Video Player'),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _youtubePlayerController,
          showVideoProgressIndicator: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _youtubePlayerController.dispose();  // Controller'ı temizliyoruz
  }
}
