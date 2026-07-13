import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/calculator_controller.dart';
import '../widgets/calc_button.dart';

/// CalculatorScreen
/// -----------------
/// Pure UI layer. Reads state from [CalculatorController] via `context.watch`
/// and forwards every user action straight to the controller. Contains no
/// arithmetic logic of its own — a strict separation of concerns.
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  static const Color kBackground = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? _PortraitLayout()
                : _LandscapeLayout();
          },
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Two-stage display: muted expression history + bold auto-scaling result.
/// ---------------------------------------------------------------------
class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({super.key, required this.expanded});

  /// Whether the display should flex-fill remaining space (portrait) or
  /// hug its content tightly (landscape, where the keypad needs more room).
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalculatorController>();

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Muted "history" row — shows the running expression, e.g. "12 +".
          SizedBox(
            height: 28,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                controller.expression,
                style: const TextStyle(
                  color: Color(0xFF8E8E93), // Muted silver-gray
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Bold, prominent, auto-scaling primary value / result / error.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              controller.currentInput,
              style: TextStyle(
                color: controller.hasError ? const Color(0xFFFF453A) : Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );

    return expanded ? Expanded(child: content) : content;
  }
}

/// ---------------------------------------------------------------------
/// Portrait layout: display on top, standard 4-column x 5-row keypad below.
/// ---------------------------------------------------------------------
class _PortraitLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CalculatorDisplay(expanded: true),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: _KeypadGrid(rowHeight: 76),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Landscape layout: display takes the left column (more horizontal room
/// for longer numbers), keypad occupies the right column so nothing looks
/// stretched or gets cut off.
/// ---------------------------------------------------------------------
class _LandscapeLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 4,
          child: CalculatorDisplay(expanded: true),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
            child: _KeypadGrid(rowHeight: 64),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// The button grid itself. Uses LayoutBuilder-friendly fixed-height rows
/// combined with Expanded columns so buttons scale smoothly to any screen
/// width while keeping consistent, comfortable touch targets.
/// ---------------------------------------------------------------------
class _KeypadGrid extends StatelessWidget {
  const _KeypadGrid({required this.rowHeight});

  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<CalculatorController>();

    Widget row(List<Widget> children) => SizedBox(
          height: rowHeight,
          child: Row(children: children),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([
          CalcButton(
            label: 'AC',
            type: CalcButtonType.action,
            onTap: controller.onAllClear,
          ),
          CalcButton(
            label: '⌫',
            type: CalcButtonType.action,
            onTap: controller.onBackspace,
          ),
          CalcButton(
            label: '%',
            type: CalcButtonType.action,
            onTap: controller.onPercentPressed,
          ),
          CalcButton(
            label: '÷',
            type: CalcButtonType.operatorKey,
            onTap: () => controller.onOperatorPressed(CalcOperator.divide),
          ),
        ]),
        row([
          CalcButton(label: '7', onTap: () => controller.onDigitPressed('7')),
          CalcButton(label: '8', onTap: () => controller.onDigitPressed('8')),
          CalcButton(label: '9', onTap: () => controller.onDigitPressed('9')),
          CalcButton(
            label: '×',
            type: CalcButtonType.operatorKey,
            onTap: () => controller.onOperatorPressed(CalcOperator.multiply),
          ),
        ]),
        row([
          CalcButton(label: '4', onTap: () => controller.onDigitPressed('4')),
          CalcButton(label: '5', onTap: () => controller.onDigitPressed('5')),
          CalcButton(label: '6', onTap: () => controller.onDigitPressed('6')),
          CalcButton(
            label: '−',
            type: CalcButtonType.operatorKey,
            onTap: () => controller.onOperatorPressed(CalcOperator.subtract),
          ),
        ]),
        row([
          CalcButton(label: '1', onTap: () => controller.onDigitPressed('1')),
          CalcButton(label: '2', onTap: () => controller.onDigitPressed('2')),
          CalcButton(label: '3', onTap: () => controller.onDigitPressed('3')),
          CalcButton(
            label: '+',
            type: CalcButtonType.operatorKey,
            onTap: () => controller.onOperatorPressed(CalcOperator.add),
          ),
        ]),
        row([
          CalcButton(
            label: '+/-',
            type: CalcButtonType.action,
            onTap: controller.onToggleSign,
          ),
          CalcButton(label: '0', onTap: () => controller.onDigitPressed('0')),
          CalcButton(label: '.', onTap: controller.onDecimalPressed),
          CalcButton(
            label: '=',
            type: CalcButtonType.equals,
            onTap: controller.onEqualsPressed,
          ),
        ]),
      ],
    );
  }
}
