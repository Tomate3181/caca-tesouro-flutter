import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../models/proximity_state.dart';

/// Badge com animação e glassmorphism que indica o estado térmico atual
class ProximityBadge extends StatelessWidget {
  final ProximityState state;

  const ProximityBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: state.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: state.color.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: state.color.withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            state.icon,
            color: state.color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            state.title,
            style: TextStyle(
              color: state.color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
