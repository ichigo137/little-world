import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// One tappable location on the world map. Bobs gently up and down
/// forever, glows once completed, and dims with a lock icon while
/// locked. Tapping a locked node triggers a little shake and an
/// optional hint via [onLockedTap].
class HubNode extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool locked;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback? onLockedTap;
  final double bobOffset;

  const HubNode({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.onLockedTap,
    this.locked = false,
    this.done = false,
    this.bobOffset = 0,
  });

  @override
  State<HubNode> createState() => _HubNodeState();
}

class _HubNodeState extends State<HubNode>
    with TickerProviderStateMixin {
  late final AnimationController _bob;
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _bob.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.locked) {
      _shake.forward(from: 0);
      widget.onLockedTap?.call();
    } else {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bob, _shake]),
      builder: (context, child) {
        final bob = (_bob.value - 0.5) * 12;
        final shakeT = _shake.value;
        final shakeDx = _shake.isAnimating
            ? math.sin(shakeT * math.pi * 6) * (1 - shakeT) * 10
            : 0.0;
        return Transform.translate(
          offset: Offset(shakeDx, bob + widget.bobOffset),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.locked
                    ? Colors.white.withValues(alpha: 0.1)
                    : widget.color,
                boxShadow: widget.locked
                    ? []
                    : [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.5),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                border: widget.done
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
              ),
              child: Icon(
                widget.locked ? Icons.lock_rounded : widget.icon,
                color: widget.locked
                    ? Colors.white.withValues(alpha: 0.35)
                    : Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.locked
                    ? Colors.white.withValues(alpha: 0.4)
                    : AppTheme.textLight,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
