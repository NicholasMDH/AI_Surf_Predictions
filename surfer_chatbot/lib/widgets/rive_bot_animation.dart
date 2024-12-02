import 'package:flutter/material.dart' hide LinearGradient;
import 'package:rive/rive.dart';

class RiveBotAnimation extends StatelessWidget {
  final double height;

  const RiveBotAnimation({
    super.key,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 36, 34, 40),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: const RiveAnimation.asset(
          'assets/animation/bot-animation.riv',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}