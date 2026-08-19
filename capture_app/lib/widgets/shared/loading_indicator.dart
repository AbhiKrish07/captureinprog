import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/constants.dart';

class CaptureLoadingIndicator extends StatelessWidget {
  final double size;
  
  const CaptureLoadingIndicator({
    this.size = 32.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: kAccentOrange,
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.4,
          height: size * 0.4,
          decoration: BoxDecoration(
            color: kAccentOrange,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 0.5, end: 1.5, duration: kDurationSlow, curve: Curves.easeInOut),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: Duration(seconds: 2));
  }
}
