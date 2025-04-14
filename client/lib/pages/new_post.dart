import 'package:client/services/shared_pref.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewPostWidget extends StatefulWidget {
  NewPostWidget({super.key});

  final TextEditingController captionController = TextEditingController();
  PlatformFile? file;

  @override
  State<NewPostWidget> createState() => _NewPostWidgetState();
}

class _NewPostWidgetState extends State<NewPostWidget> {
  @override
  Widget build(BuildContext context) {
    void navigate() {
      Navigator.pop(context);
    }

    void showMessage(String message) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Notice"),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }

    void post() async {
      if (widget.file == null || widget.file!.path == null) {
        showMessage("File not selected");
        return;
      }

      String token = await SharedPref.getToken();
      var client = http.Client();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/post/post'),
      );

      request.headers.addAll({"Authorization": "Bearer $token"});
      request.fields["caption"] = widget.captionController.text;
      request.files.add(
        kIsWeb 
        ? http.MultipartFile.fromBytes("content-media", widget.file?.bytes as List<int>, filename: widget.file?.name)
        : await http.MultipartFile.fromPath('content-media', widget.file!.path!)
      );

      var response = await client.send(request);
      client.close();

      if (response.statusCode == 200) {
        navigate();
      } else {
        showMessage("Upload failed. Status: ${response.statusCode}");
      }
    }

    void getFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          widget.file = result.files[0];
        });
      } else {
        showMessage("No file was selected.");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("create post"),
        actions: [
          IconButton(
            onPressed: () {
              post();
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: widget.captionController,
                  decoration: const InputDecoration(
                    label: Text("captions"),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: MediaQuery.of(context).size.width - 45,
                child: ElevatedButton(
                  onPressed: () {
                    getFile();
                  },
                  child: Text(
                    "select video",
                    style: TextStyle(
                      fontSize: 25,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
