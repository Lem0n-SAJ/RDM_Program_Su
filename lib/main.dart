import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.setSize(const Size(1920, 1080));
  await windowManager.setMinimumSize(const Size(1920, 1080));
  await windowManager.setMaximumSize(const Size(1920, 1080));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Dot Motion',
      debugShowCheckedModeBanner: false,
      home: const RdmApp(),
    );
  }
}

class RdmApp extends StatefulWidget {
  const RdmApp({Key? key}) : super(key: key);
  @override
  State<RdmApp> createState() => _RdmAppState();
}

class _RdmAppState extends State<RdmApp> with WindowListener {
  final List<Dot> dots = [];
  double speed = 0;
  final double speedStep = 50;
  final double maxSpeed = 1000;
  final double minSpeed = 0;
  bool showSpeedDisplay = false;
  final List<double> savedSpeeds = [];
  Timer? _timer;
  late final FocusNode focusNode;
  late final Offset circleCenter;
  final double circleRadius = 500;
  final double dotRadius = 12;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    circleCenter = const Offset(1920 / 2, 1080 / 2);
    for (int i = 0; i < 200; i++) {
      dots.add(spawnDot());
    }
    _timer = Timer.periodic(const Duration(microseconds: 16667), (timer) {
      updateDots();
    });
    windowManager.addListener(this);
  }

  Dot spawnDot() {
    double x = circleCenter.dx - circleRadius + random.nextDouble() * (2 * circleRadius);
    double dx = (x - circleCenter.dx).abs();
    double lowerBoundary = circleCenter.dy + sqrt(max(0, circleRadius * circleRadius - dx * dx));
    double y = lowerBoundary + 10 + random.nextDouble() * 300;
    return Dot(position: Offset(x, y), entered: false);
  }

  void updateDots() {
    const double dt = 1 / 60;
    setState(() {
      for (var dot in dots) {
        dot.position = dot.position.translate(0, -speed * dt);
        bool inside = isInsideCircle(dot.position);
        if (inside) {
          dot.entered = true;
        } else {
          if (dot.entered) {
            Dot newDot = spawnDot();
            dot.position = newDot.position;
            dot.entered = false;
          }
        }
      }
    });
  }

  bool isInsideCircle(Offset pos) {
    return (pos - circleCenter).distance <= circleRadius;
  }

  void handleKey(RawKeyEvent event) async {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          speed = (speed - speedStep).clamp(minSpeed, maxSpeed);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          speed = (speed + speedStep).clamp(minSpeed, maxSpeed);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.f1) {
        setState(() {
          showSpeedDisplay = !showSpeedDisplay;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        setState(() {
          savedSpeeds.add(speed);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.keyL) {
        exportSpeeds();
      } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
        setState(() {
          speed = 0;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
        setState(() {
          speed = maxSpeed;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.f10) {
        bool isFullScreen = await windowManager.isFullScreen();
        if (!isFullScreen) {
          await windowManager.setMinimumSize(const Size(0, 0));
          await windowManager.setMaximumSize(const Size(10000, 10000));
          await windowManager.setFullScreen(true);
        } else {
          await windowManager.setFullScreen(false);
          await windowManager.setSize(const Size(1920, 1080));
          await windowManager.setMinimumSize(const Size(1920, 1080));
          await windowManager.setMaximumSize(const Size(1920, 1080));
        }
      }
    }
  }

  void exportSpeeds() async {
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < savedSpeeds.length; i++) {
      buffer.writeln("Speed ${i + 1} = ${savedSpeeds[i]}");
    }
    String fileName = "export.txt";
    File file = File(fileName);
    await file.writeAsString(buffer.toString());
    print("Exported speeds to $fileName");
  }

  @override
  void dispose() {
    _timer?.cancel();
    focusNode.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKey: handleKey,
      child: Center(
        child: Container(
          width: 1920,
          height: 1080,
          color: Colors.black,
          child: CustomPaint(
            painter: RdmPainter(
              dots: dots,
              circleCenter: circleCenter,
              circleRadius: circleRadius,
              dotRadius: dotRadius,
              showSpeedDisplay: showSpeedDisplay,
              speed: speed,
            ),
          ),
        ),
      ),
    );
  }
}

class Dot {
  Offset position;
  bool entered;
  Dot({required this.position, this.entered = false});
}

class RdmPainter extends CustomPainter {
  final List<Dot> dots;
  final Offset circleCenter;
  final double circleRadius;
  final double dotRadius;
  final bool showSpeedDisplay;
  final double speed;
  RdmPainter({
    required this.dots,
    required this.circleCenter,
    required this.circleRadius,
    required this.dotRadius,
    required this.showSpeedDisplay,
    required this.speed,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final Paint dotPaint = Paint()..color = const Color.fromARGB(255, 104, 107, 201);
    for (var dot in dots) {
      if ((dot.position - circleCenter).distance <= circleRadius) {
        canvas.drawCircle(dot.position, dotRadius, dotPaint);
      }
    }
    const double armLength = 2;
    const double crossThickness = 2;
    final Paint crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = crossThickness
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(circleCenter.dx, circleCenter.dy - armLength),
      Offset(circleCenter.dx, circleCenter.dy + armLength),
      crossPaint,
    );
    canvas.drawLine(
      Offset(circleCenter.dx - armLength, circleCenter.dy),
      Offset(circleCenter.dx + armLength, circleCenter.dy),
      crossPaint,
    );
    if (showSpeedDisplay) {
      final TextSpan span = TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 24),
        text: "Speed = ${speed.toStringAsFixed(0)}",
      );
      final TextPainter tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, const Offset(10, 10));
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
