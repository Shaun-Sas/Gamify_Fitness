import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostWidget extends StatefulWidget {
  String authorId;
  String timestamps;
  String media;
  String caption;
  String likes;
  String dislikes;

  PostWidget({
    super.key,
    required this.authorId,
    required this.timestamps,
    required this.media,
    required this.caption,
    required this.likes,
    required this.dislikes,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
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
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      radius: 28,
                      child: const Text("T"),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.authorId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Text(widget.timestamps),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) {
                  return [];
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            child: Text(
              widget.caption,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                label: Text(
                  "28 likes",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                onPressed: () {},
                icon: Icon(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  Icons.favorite,
                  size: 32,
                ),
              ),
              ElevatedButton.icon(
                label: Text(
                  "${widget.dislikes} dislikes",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                onPressed: () {},
                icon: Icon(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  Icons.heart_broken,
                  size: 32,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  Icons.comment,
                  size: 32,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  Icons.share,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
            child: Divider(thickness: 0.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
