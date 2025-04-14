import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ProfilePost extends StatefulWidget {
  String media;
  ProfilePost({super.key, required this.media});

  @override
  State<ProfilePost> createState() => _ProfilePostState();
}

class _ProfilePostState extends State<ProfilePost> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();

    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.media))
          ..initialize().then((value) {
            setState(() {
              _videoPlayerController.play();
            });
          })
          ..setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: VideoPlayer(_videoPlayerController),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }
}
