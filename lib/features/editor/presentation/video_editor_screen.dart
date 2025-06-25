import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({super.key});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  final ImagePicker _picker = ImagePicker();
  VideoEditorController? _videoEditorController;
  VideoPlayerController? _videoPlayerController;
  bool canShowEditor = false;
  List<String> trimmedVideos = [];
  bool isSeeking = false;

  Future<void> _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      _videoEditorController = VideoEditorController.file(
        File(file.path),
        minDuration: const Duration(seconds: 1),
        maxDuration: const Duration(seconds: 53),
      );
      _videoPlayerController = VideoPlayerController.file(File(file.path))
        ..setLooping(true);

      try {
        await Future.wait([
          _videoEditorController!.initialize(),
          _videoPlayerController!.initialize(),
        ]);
        _videoPlayerController!.addListener(() {
          if (_videoPlayerController!.value.position >=
              _videoEditorController!.endTrim) {
            _videoPlayerController!.pause();
          }
        });
        setState(() {
          canShowEditor = true;
        });
      } catch (e) {
        print("errror: $e");
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Video Editor',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    "Select a video to start editing",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 25),
                child: ElevatedButton(
                  onPressed: _pickVideo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: Text(
                    "Import Video",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
