import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class SpeedDialAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  SpeedDialAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });
}

class CustomSpeedDial extends StatefulWidget {
  final IconData mainIcon;
  final IconData activeIcon;
  final List<SpeedDialAction> actions;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomSpeedDial({
    super.key,
    this.mainIcon = Icons.add,
    this.activeIcon = Icons.close,
    required this.actions,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<CustomSpeedDial> createState() => _CustomSpeedDialState();
}

class _CustomSpeedDialState extends State<CustomSpeedDial> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Actions
        ...widget.actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Stagger the animation slightly for each item
              final double start = (widget.actions.length - 1 - index) * 0.1;
              final double end = start + 0.5;
              final double itemVal = Curves.fastOutSlowIn.transform(
                ((_controller.value - start) / (end - start)).clamp(0.0, 1.0),
              );

              return Transform.translate(
                offset: Offset(0, 50.0 * (1.0 - itemVal)),
                child: Opacity(
                  opacity: itemVal,
                  child: child,
                ),
              );
            },
            child: _isOpen
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            action.label,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 16),
                        FloatingActionButton.small(
                          heroTag: 'speed_dial_action_$index',
                          backgroundColor: action.backgroundColor ?? Theme.of(context).cardColor,
                          foregroundColor: action.foregroundColor ?? AppColors.primary,
                          onPressed: () {
                            _toggle();
                            action.onTap();
                          },
                          child: Icon(action.icon),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          );
        }),

        // Main FAB
        FloatingActionButton(
          heroTag: 'speed_dial_main',
          backgroundColor: widget.backgroundColor ?? AppColors.primary,
          foregroundColor: widget.foregroundColor ?? Colors.white,
          onPressed: _toggle,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 3.14159 / 4, // Rotate 45 degrees
                child: Icon(_isOpen ? widget.activeIcon : widget.mainIcon),
              );
            },
          ),
        ),
      ],
    );
  }
}
