import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostWidget extends StatefulWidget {
  final String authorId;
  final String timestamps;
  final String media;
  final String caption;
  final String likes;

  const PostWidget({
    super.key,
    required this.authorId,
    required this.timestamps,
    required this.media,
    required this.caption,
    required this.likes,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isVideo = false;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _determineMediaTypeAndInitialize();
  }

  void _determineMediaTypeAndInitialize() {
    final ext = widget.media.split(".").last.toLowerCase();
    isVideo = ['mp4', 'mkv', 'mov', 'webm'].contains(ext);

    if (isVideo) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.media))
            ..initialize().then((_) {
              setState(() {
                _videoController?.play();
              });
            })
            ..setLooping(true);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.inversePrimary;

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.authorId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(widget.timestamps),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => print('Selected: $value'),
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(value: "Share", child: Text("Share")),
                      const PopupMenuItem(value: "Save", child: Text("Save")),
                    ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Caption
          Text(
            widget.caption,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),

          const SizedBox(height: 16),

          /// Media content (Image or Video)
          if (isVideo &&
              _videoController != null &&
              _videoController!.value.isInitialized)
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
          else if (!isVideo)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.media,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Text("Failed to load media."),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          const SizedBox(height: 16),

          /// Like and comment section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.favorite, size: 24, color: textColor),
                label: Text(
                  "${widget.likes} likes",
                  style: TextStyle(color: textColor),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.comment, size: 28, color: textColor),
              ),
            ],
          ),

          const Divider(thickness: 0.2, color: Colors.grey),
        ],
      ),
    );
  }
}
