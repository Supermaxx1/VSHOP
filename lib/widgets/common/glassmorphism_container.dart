import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity; // MOVED TO CORRECT POSITION
  final Color? color; // MADE NULLABLE

  const GlassmorphismContainer({
    Key? key,
    required this.child,
    this.borderRadius = 20.0,
    this.blur = 10.0,
    this.opacity = 0.1, // ADDED HERE IN CONSTRUCTOR
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color:
                color ??
                Colors.white.withOpacity(opacity), // FIXED TO USE OPACITY
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
