import 'package:client/services/shared_pref.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewPostWidget extends StatefulWidget {
  const NewPostWidget({super.key});

  @override
  State<NewPostWidget> createState() => _NewPostWidgetState();
}

class _NewPostWidgetState extends State<NewPostWidget> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController captionController = TextEditingController();
    PlatformFile? file;

    void navigate() {
      Navigator.pop(context);
    }

    void post() async {
      String token = await SharedPref.getToken();
      var client = http.Client();
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.221.217:5000/post/post'));

      request.headers.addAll({"Authorization": "Bearer $token"});
      request.fields["caption"] = captionController.text;
      request.files.add(
          await http.MultipartFile.fromPath("content-media", file!.path ?? ""));
      var response = await client.send(request);

      client.close();

      if (response.statusCode == 200) {
        navigate();
      } else {
        print(response.stream.toString());
      }
    }

    void getFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        file = result.files[0];
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
              icon: const Icon(Icons.check))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: captionController,
                decoration: const InputDecoration(hintText: "Caption"),
              ),
              const SizedBox(
                height: 18,
              ),
              Text('Selected Files: ${file?.name}'),
              const SizedBox(
                height: 18,
              ),
              ElevatedButton(
                  onPressed: () {
                    getFile();
                  },
                  child: const Text("select video"))
            ],
          ),
        ),
      ),
    );
  }
}
