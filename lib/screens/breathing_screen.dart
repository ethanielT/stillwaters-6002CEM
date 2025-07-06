import 'package:flutter/material.dart';
import 'dart:async';

class BreathingScreen extends StatefulWidget {
  final void Function() onComplete;
  final VoidCallback onCancel;
  const BreathingScreen({super.key, required this.onComplete, required this.onCancel});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> phases = [
    {"name": "Inhale", "duration": 4, "color": Color(0xFFE3F2FD)},
    {"name": "Hold", "duration": 7, "color": Color(0xFFCE93D8)},
    {"name": "Exhale", "duration": 8, "color": Color(0xFFB2EBF2)},
  ];

  int currentCycle = 0;
  int currentPhaseIndex = 0;
  int countdown = 0;
  bool _cancelled = false;
  Timer? _timer;

  double circleSize = 200;
  double targetCircleSize = 200;

  @override
  void initState() {
    super.initState();
    final screenWidth = WidgetsBinding.instance.window.physicalSize.width /
        WidgetsBinding.instance.window.devicePixelRatio;
    circleSize = screenWidth;
    targetCircleSize = screenWidth;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startBreathing());
  }

  void _startBreathing() {
    _runPhase();
  }

  void _runPhase() {
    if (_cancelled) return;

    final phase = phases[currentPhaseIndex];
    countdown = phase['duration'];
    _updateAnimation(phase['name']);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cancelled) {
        timer.cancel();
        return;
      }

      setState(() {
        countdown--;
      });

      if (countdown <= 0) {
        timer.cancel();
        _nextPhase();
      }
    });
  }

  void _nextPhase() {
    if (_cancelled) return;

    if (currentPhaseIndex < phases.length - 1) {
      setState(() {
        currentPhaseIndex++;
      });
      _runPhase();
    } else {
      if (currentCycle < 2) {
        setState(() {
          currentCycle++;
          currentPhaseIndex = 0;
        });
        _runPhase();
      } else {
        widget.onComplete();
        Navigator.pop(context);
      }
    }
  }

  void _cancel() {
    setState(() => _cancelled = true);
    _timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Breathing exercise cancelled")),
    );
    widget.onCancel();
    Navigator.pop(context);
  }

  void _testComplete() {
    _timer?.cancel();
    widget.onComplete();
    Navigator.pop(context);
  }

  void _updateAnimation(String phase) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxSize = screenWidth * 1.1;
    final estimatedMinSize = 180.0;

    setState(() {
      if (phase == "Inhale") {
        targetCircleSize = estimatedMinSize;
      } else if (phase == "Exhale") {
        targetCircleSize = maxSize;
      } // Hold stays as-is
    });
  }

  @override
  Widget build(BuildContext context) {
    final phase = phases[currentPhaseIndex];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: phase['color'],
        appBar: AppBar(
          title: const Text("Breathing"),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: _cancel,
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: _testComplete,
              child: const Text("Test Completion", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: circleSize, end: targetCircleSize),
                duration: Duration(seconds: countdown),
                onEnd: () => circleSize = targetCircleSize,
                builder: (_, size, __) {
                  return Container(
                    width: size,
                    height: size,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            phase['name'],
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "$countdown seconds",
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Cycle ${currentCycle + 1} of 3",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
