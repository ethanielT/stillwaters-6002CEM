import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MeditationScreen extends StatefulWidget {
  final void Function() onComplete;
  final void Function() onCancel;
  const MeditationScreen({super.key, required this.onComplete, required this.onCancel});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  late VideoPlayerController _controller;

  int seconds = 60;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/meditation.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.setVolume(0.0); // silent
        _controller.play();
      });

    _startTimer();
  }

  @override
  void dispose() {
    _controller.dispose(); // ← Don't forget to dispose!
    super.dispose();
  }

  Future<void> _startTimer() async {
    for (var i = seconds; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _cancelled) return;
      setState(() {
        seconds = i;
      });
    }

    if (!_cancelled) {
      widget.onComplete();
      if (mounted) Navigator.pop(context);
    }
  }

  void _cancel() {
    setState(() => _cancelled = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Meditation cancelled")),
    );
    widget.onCancel();
    Navigator.pop(context);
  }

  void _testComplete(){
    widget.onComplete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        appBar: AppBar(
          title: const Text("Meditation"),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: _cancel,
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: _testComplete, // calls your onComplete logic
              child: const Text("Test Completion", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            Container(color: Colors.black.withOpacity(0.3)),
            Center(
              child: Text(
                seconds > 0 ? "$seconds seconds" : "Done!",
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

