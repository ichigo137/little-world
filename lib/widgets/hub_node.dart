import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// One tappable location on the world map. Bobs gently up and down
/// forever, glows once completed, and dims with a lock icon while
/// locked.
class HubNode extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool locked;
  final bool done;
  final VoidCallback onTap;
  final double bobOffset;

  const HubNode({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.locked = false,
    this.done = false,
    this.bobOffset = 0,
  });

  @override
  State<HubNode> createState() => _HubNodeState();
}

class _HubNodeState extends State<HubNode> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final bob = (_controller.value - 0.5) * 12;
        return Transform.translate(
          offset: Offset(0, bob + widget.bobOffset),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.locked ? null : widget.onTap,
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
                color: widget.locked ? Colors.grey.shade300 : widget.color,
                boxShadow: widget.locked
                    ? []
                    : [
                        BoxShadow(
                          color: widget.color.withOpacity(0.5),
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
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.locked ? Colors.grey : AppTheme.textDark,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
