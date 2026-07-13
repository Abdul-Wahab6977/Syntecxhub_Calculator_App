import 'package:flutter/material.dart';

/// Visual style variants for a calculator key. Keeping this as an enum
/// (rather than passing raw colors everywhere) keeps the button grid
/// declaration in [CalculatorScreen] short and readable.
enum CalcButtonType { number, operatorKey, action, equals }

/// A single calculator key.
///
/// Wrapped in an [InkWell] inside a [Material] so every key gets a proper
/// ripple/ink-splash touch response, and sized to comfortably clear the
/// 48x48dp minimum touch-target guideline.
class CalcButton extends StatelessWidget {
  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.type = CalcButtonType.number,
    this.flex = 1,
    this.fontSize = 28,
  });

  final String label;
  final VoidCallback onTap;
  final CalcButtonType type;

  /// Allows a button (like "0") to span extra horizontal space in the grid.
  final int flex;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForType(type);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: colors.background,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: colors.foreground.withOpacity(0.15),
            highlightColor: colors.foreground.withOpacity(0.08),
            child: Container(
              constraints: const BoxConstraints(minHeight: 56, minWidth: 56),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: colors.foreground,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ButtonColors _colorsForType(CalcButtonType type) {
    switch (type) {
      case CalcButtonType.number:
        return const _ButtonColors(
          background: Color(0xFF2E2F38), // Dark slate gray
          foreground: Colors.white,
        );
      case CalcButtonType.operatorKey:
        return const _ButtonColors(
          background: Color(0xFFFF9F0A), // Premium amber/orange
          foreground: Colors.white,
        );
      case CalcButtonType.equals:
        return const _ButtonColors(
          background: Color(0xFF007AFF), // Tech blue accent for "="
          foreground: Colors.white,
        );
      case CalcButtonType.action:
        return const _ButtonColors(
          background: Color(0xFFD1D1D6), // Light gray/silver
          foreground: Color(0xFF17171C),
        );
    }
  }
}

class _ButtonColors {
  const _ButtonColors({required this.background, required this.foreground});
  final Color background;
  final Color foreground;
}
