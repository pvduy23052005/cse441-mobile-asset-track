import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SignaturePadWidget extends StatefulWidget {
  final double height;
  final ValueChanged<bool>? onSignatureChanged;
  final Color strokeColor;
  final double strokeWidth;

  const SignaturePadWidget({
    super.key,
    this.height = 160,
    this.onSignatureChanged,
    this.strokeColor = const Color(0xFF0284C7), // Deep blue ink stroke
    this.strokeWidth = 3.0,
  });

  @override
  SignaturePadWidgetState createState() => SignaturePadWidgetState();
}

class SignaturePadWidgetState extends State<SignaturePadWidget> {
  final List<List<Offset>> _paths = [];
  List<Offset>? _currentPath;

  bool get hasSigned => _paths.any((p) => p.length > 1);

  void clear() {
    setState(() {
      _paths.clear();
      _currentPath = null;
    });
    widget.onSignatureChanged?.call(false);
  }

  Future<ui.Image?> exportImage() async {
    if (!hasSigned) return null;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, 380, widget.height),
    );

    // Paint white background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, 380, widget.height), bgPaint);

    // Paint strokes
    final strokePaint = Paint()
      ..color = widget.strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = widget.strokeWidth
      ..style = PaintingStyle.stroke;

    for (final path in _paths) {
      if (path.length > 1) {
        for (int i = 0; i < path.length - 1; i++) {
          canvas.drawLine(path[i], path[i + 1], strokePaint);
        }
      }
    }

    final picture = recorder.endRecording();
    return await picture.toImage(380, widget.height.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
      ),
      child: Stack(
        children: [
          // Canvas for touch gestures
          GestureDetector(
            onPanStart: (details) {
              final RenderBox renderBox = context.findRenderObject() as RenderBox;
              final localPos = renderBox.globalToLocal(details.globalPosition);
              setState(() {
                _currentPath = [localPos];
                _paths.add(_currentPath!);
              });
            },
            onPanUpdate: (details) {
              final RenderBox renderBox = context.findRenderObject() as RenderBox;
              final localPos = renderBox.globalToLocal(details.globalPosition);
              setState(() {
                _currentPath?.add(localPos);
              });
              if (!hasSigned) {
                widget.onSignatureChanged?.call(true);
              }
            },
            onPanEnd: (_) {
              setState(() {
                _currentPath = null;
              });
              widget.onSignatureChanged?.call(hasSigned);
            },
            child: CustomPaint(
              painter: _SignaturePainter(
                paths: _paths,
                strokeColor: widget.strokeColor,
                strokeWidth: widget.strokeWidth,
              ),
              size: Size.infinite,
            ),
          ),

          // Instruction placeholder when empty
          if (!hasSigned)
            const IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 32,
                      color: Color(0xFFF59E0B), // amber-500
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ký tên trực tiếp vào đây để nghiệm thu bàn giao',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Clear button when signed
          if (hasSigned)
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: clear,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restart_alt_rounded, size: 14, color: Color(0xFFD97706)),
                      SizedBox(width: 4),
                      Text(
                        'Xóa chữ ký',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> paths;
  final Color strokeColor;
  final double strokeWidth;

  _SignaturePainter({
    required this.paths,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (final path in paths) {
      if (path.length > 1) {
        for (int i = 0; i < path.length - 1; i++) {
          canvas.drawLine(path[i], path[i + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
