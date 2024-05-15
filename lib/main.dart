import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          child: const Text('navigate'),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (builder) => const SampleScreen())),
        ),
      ),
    );
  }
}

class SampleScreen extends StatelessWidget {
  const SampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Flexible(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: PlayerWidget(),
              ),
            ),
            Container(
              height: 400,
              width: 400,
              color: Colors.red,
              child: AndroidViewContainer(),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    isIos: true,
                    child: Scaffold(
                      body: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: const AndroidViewContainer(),
                      ),
                    ),
                    type: PageTransitionType.bottomToTop,
                    opaque: false,
                  ),
                );
              },
              child: const Text("open"),
            ),
          ],
        ),
      ),
    );
  }
}

class AndroidViewContainer extends StatefulWidget {
  const AndroidViewContainer({super.key});

  @override
  State<AndroidViewContainer> createState() => _AndroidViewContainerState();
}

class _AndroidViewContainerState extends State<AndroidViewContainer> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 500,
        width: 500,
        child: AndroidView(
          viewType: 'my-platform-view',
          creationParams: const {'message': 'Hello from Flutter'},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (int id) {
            // Implement any necessary logic when the platform view is created
          },
        ),
      ),
    );
  }
}

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  VideoPlayerController? videoPlayerController;

  @override
  initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      ),
    );

    setState(() {});
  }

  Future<bool> started() async {
    await videoPlayerController!.initialize();
    await videoPlayerController!.play();
    return true;
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoPlayerController == null) {
      return const Center(
        child: Text('No controller'),
      );
    }
    return FutureBuilder<bool>(
      future: started(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data ?? false) {
          return AspectRatio(
            aspectRatio: videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(videoPlayerController!),
          );
        } else {
          return const Text('waiting for video to load');
        }
      },
    );
  }
}
