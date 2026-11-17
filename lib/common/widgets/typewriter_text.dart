import 'dart:async';
import 'package:flutter/material.dart';

/// Smooth typewriter effect for titles, user names, and greetings.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDuration;
  final bool showCursor;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.charDuration = const Duration(milliseconds: 60),
    this.showCursor = true,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;
  Timer? _pauseTimer;
  int _charIndex = 0;
  bool _cursorVisible = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
    if (widget.showCursor) {
      _cursorTimer = Timer.periodic(const Duration(milliseconds: 480), (_) {
        if (mounted) {
          setState(() => _cursorVisible = !_cursorVisible);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTypewriter();
    }
  }

  void _startTypewriter() {
    _timer?.cancel();
    _pauseTimer?.cancel();
    _charIndex = 0;
    _displayedText = '';
    if (widget.text.isEmpty) return;

    _timer = Timer.periodic(widget.charDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charIndex < widget.text.length) {
        _charIndex++;
        setState(() {
          _displayedText = widget.text.substring(0, _charIndex);
        });
      } else {
        timer.cancel();
        // Keep final text static, stop cursor blinking
        _cursorTimer?.cancel();
        if (mounted) {
          setState(() {
            _cursorVisible = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pauseTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = _charIndex >= widget.text.length;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: _displayedText, style: widget.style),
          if (widget.showCursor && (!isDone || _cursorVisible))
            TextSpan(
              text: '▊',
              style: (widget.style ?? const TextStyle()).copyWith(
                color: (widget.style?.color ?? const Color(0xFF008746)).withValues(alpha: _cursorVisible ? 0.75 : 0.0),
                fontSize: (widget.style?.fontSize ?? 14) * 0.85,
              ),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
