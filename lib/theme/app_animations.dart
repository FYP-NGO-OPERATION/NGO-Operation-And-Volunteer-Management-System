import 'package:flutter/material.dart';

/// Premium Animation System
class AppAnimations {
  AppAnimations._();

  // ─── DURATIONS ───
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 700);
  static const Duration splash = Duration(milliseconds: 1500);
  static const Duration stagger = Duration(milliseconds: 50);

  // ─── CURVES ───
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.decelerate;
  static const Curve spring = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve smooth = Cubic(0.4, 0.0, 0.2, 1.0);
  static const Curve premiumSpring = Cubic(0.34, 1.56, 0.64, 1.0);

  // ─── PAGE TRANSITIONS ───
  static Route<T> fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: normal,
    );
  }

  static Route<T> slideUpRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: const Offset(0, 0.1), end: Offset.zero)
            .chain(CurveTween(curve: easeOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: normal,
    );
  }

  static Route<T> slideLeftRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: const Offset(0.2, 0), end: Offset.zero)
            .chain(CurveTween(curve: easeOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: normal,
    );
  }

  static Route<T> scaleRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleTween = Tween(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: easeOut));
        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: normal,
    );
  }
}

/// Staggered fade-in for list items
class StaggeredFadeIn extends StatelessWidget {
  final int index;
  final Widget child;

  const StaggeredFadeIn({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppAnimations.medium,
      curve: AppAnimations.easeOut,
      builder: (context, val, builtChild) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - val)),
            child: builtChild,
          ),
        );
      },
      child: child,
    );
  }
}

/// Animated counter for stats
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;

  const AnimatedCounter({
    super.key, required this.value, this.style,
    this.prefix = '', this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: AppAnimations.slow,
      curve: AppAnimations.easeOut,
      builder: (context, val, child) => Text('$prefix$val$suffix', style: style),
    );
  }
}

/// Shimmer loading placeholder
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({super.key, required this.width, required this.height, this.borderRadius = 8});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width, height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1D1B), const Color(0xFF252926), const Color(0xFF1A1D1B)]
                  : [const Color(0xFFE5E5E5), const Color(0xFFF5F5F5), const Color(0xFFE5E5E5)],
              stops: [0.0, _controller.value, 1.0],
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
            ),
          ),
        );
      },
    );
  }
}
