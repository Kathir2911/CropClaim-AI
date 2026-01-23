import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInput extends StatefulWidget {
  final Function(String) onCompleted;
  final int length;

  const OTPInput({super.key, required this.onCompleted, this.length = 6});

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Check if all fields are filled
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          List.generate(
            widget.length,
            (index) => SizedBox(
              width: 50,
              height: 65,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF0D47A1),
                      width: 3,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) => _onChanged(value, index),
                onTap: () {
                  // Select all text when tapped for easier editing
                  _controllers[index].selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _controllers[index].text.length,
                  );
                },
                // Handle backspace to move to previous field
                onEditingComplete: () {
                  if (index < widget.length - 1) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
                // Add key listener for backspace
                onSubmitted: (value) {
                  if (index < widget.length - 1) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
              ),
            ),
          ).map((widget) {
            // Wrap each text field with RawKeyboardListener for backspace detection
            final index = _controllers.indexOf(
              _controllers.firstWhere((c) => true),
            );
            return KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace) {
                  final currentIndex = _focusNodes.indexWhere(
                    (node) => node.hasFocus,
                  );
                  if (currentIndex > 0 &&
                      _controllers[currentIndex].text.isEmpty) {
                    _focusNodes[currentIndex - 1].requestFocus();
                    _controllers[currentIndex - 1].clear();
                  }
                }
              },
              child: widget,
            );
          }).toList(),
    );
  }
}
