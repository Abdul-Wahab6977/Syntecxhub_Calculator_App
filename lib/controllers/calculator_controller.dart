import 'package:flutter/material.dart';

/// Enum representing the supported arithmetic operators.
/// Using an enum (instead of raw strings) keeps the math engine
/// type-safe and prevents typos like "x" vs "×" from creeping into logic.
enum CalcOperator { add, subtract, multiply, divide }

/// Extension to map an operator to the symbol shown on screen.
extension CalcOperatorSymbol on CalcOperator {
  String get symbol {
    switch (this) {
      case CalcOperator.add:
        return '+';
      case CalcOperator.subtract:
        return '−';
      case CalcOperator.multiply:
        return '×';
      case CalcOperator.divide:
        return '÷';
    }
  }
}

/// CalculatorController
/// ---------------------
/// Pure business-logic layer for the calculator. Contains ZERO widget/UI
/// code, which keeps it fully unit-testable and reusable across any UI
/// (phone, tablet, web, desktop).
///
/// Responsibilities:
///  - Maintains calculator state (current input, stored operand, operator).
///  - Performs high-precision arithmetic (mitigating classic floating point
///    artifacts such as 0.1 + 0.2 != 0.3).
///  - Validates user input (no consecutive operators, single decimal point,
///    max input length).
///  - Handles the divide-by-zero edge case and locks the keypad until the
///    user explicitly clears the error.
class CalculatorController extends ChangeNotifier {
  // ---------------------------------------------------------------------
  // Public state (read by the UI layer)
  // ---------------------------------------------------------------------

  /// The smaller, muted "history" line shown above the main display.
  /// e.g. "12 + 8" while the user is still typing the second operand.
  String _expression = '';
  String get expression => _expression;

  /// The bold, primary value shown on the display. This is either the
  /// value currently being typed, or the result after "=" is pressed.
  String _currentInput = '0';
  String get currentInput => _currentInput;

  /// True when the calculator is in an unrecoverable error state
  /// (e.g. division by zero). All keys except AC are disabled by the UI
  /// while this flag is true.
  bool _hasError = false;
  bool get hasError => _hasError;

  // ---------------------------------------------------------------------
  // Private working state
  // ---------------------------------------------------------------------

  double? _firstOperand;
  CalcOperator? _pendingOperator;

  /// True right after "=" has been pressed. The next digit press should
  /// start a brand-new number instead of appending to the previous result.
  bool _justEvaluated = false;

  /// Hard cap on the number of characters allowed in the visible input,
  /// to avoid text overflow / unreadable displays on small screens.
  static const int _maxInputLength = 15;

  // ---------------------------------------------------------------------
  // Public API — called directly from button widgets
  // ---------------------------------------------------------------------

  /// Handles digit presses ("0"-"9").
  void onDigitPressed(String digit) {
    if (_hasError) return; // Locked until AC is pressed.

    if (_justEvaluated) {
      // Start a fresh calculation after a result was just shown.
      _currentInput = digit == '0' ? '0' : digit;
      _expression = '';
      _firstOperand = null;
      _pendingOperator = null;
      _justEvaluated = false;
      notifyListeners();
      return;
    }

    if (_currentInput.length >= _maxInputLength) return; // Overflow guard.

    if (_currentInput == '0') {
      _currentInput = digit;
    } else {
      _currentInput += digit;
    }
    notifyListeners();
  }

  /// Handles the decimal point button, preventing multiple dots in the
  /// same number (e.g. "3.5.2" is invalid).
  void onDecimalPressed() {
    if (_hasError) return;

    if (_justEvaluated) {
      _currentInput = '0.';
      _expression = '';
      _firstOperand = null;
      _pendingOperator = null;
      _justEvaluated = false;
      notifyListeners();
      return;
    }

    if (!_currentInput.contains('.')) {
      _currentInput += '.';
      notifyListeners();
    }
  }

  /// Handles +, −, ×, ÷ presses.
  void onOperatorPressed(CalcOperator op) {
    if (_hasError) return;

    _justEvaluated = false;

    if (_firstOperand == null) {
      // First operator of the calculation: store the operand and move on.
      _firstOperand = double.tryParse(_currentInput) ?? 0;
      _pendingOperator = op;
      _expression = '${_formatNumber(_firstOperand!)} ${op.symbol}';
      _currentInput = '0';
    } else if (_currentInput == '0' && _expression.endsWith(_pendingOperator!.symbol)) {
      // Guard against consecutive operators (e.g. "+" then "×" with no
      // digits typed in between) — simply swap the pending operator
      // instead of stacking symbols like "5 +×".
      _pendingOperator = op;
      _expression = '${_formatNumber(_firstOperand!)} ${op.symbol}';
    } else {
      // A second operand has been entered — chain the calculation
      // (classic sequential calculator behaviour, e.g. 5 + 3 × ...).
      final result = _calculate(_firstOperand!, _currentInput, _pendingOperator!);
      if (result == null) {
        _triggerDivideByZeroError();
        return;
      }
      _firstOperand = result;
      _pendingOperator = op;
      _expression = '${_formatNumber(result)} ${op.symbol}';
      _currentInput = '0';
    }
    notifyListeners();
  }

  /// Handles the "=" button.
  void onEqualsPressed() {
    if (_hasError) return;
    if (_pendingOperator == null || _firstOperand == null) return;

    final result = _calculate(_firstOperand!, _currentInput, _pendingOperator!);
    if (result == null) {
      _triggerDivideByZeroError();
      return;
    }

    _expression = '${_formatNumber(_firstOperand!)} ${_pendingOperator!.symbol} $_currentInput =';
    _currentInput = _formatNumber(result);
    _firstOperand = null;
    _pendingOperator = null;
    _justEvaluated = true;
    notifyListeners();
  }

  /// "AC" — All Clear. Fully resets the calculator, including error state.
  void onAllClear() {
    _currentInput = '0';
    _expression = '';
    _firstOperand = null;
    _pendingOperator = null;
    _hasError = false;
    _justEvaluated = false;
    notifyListeners();
  }

  /// "C" — Clears only the current input segment. If there's nothing left
  /// to clear (already "0"), behaves like AC for a smoother UX.
  void onClearEntry() {
    if (_hasError) {
      onAllClear();
      return;
    }
    if (_currentInput == '0') {
      onAllClear();
    } else {
      _currentInput = '0';
      notifyListeners();
    }
  }

  /// Backspace — removes the last character of the current input.
  void onBackspace() {
    if (_hasError) return;
    if (_currentInput.length <= 1 || (_currentInput.length == 2 && _currentInput.startsWith('-'))) {
      _currentInput = '0';
    } else {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    }
    notifyListeners();
  }

  /// "%" — Converts the current input into a percentage of itself (÷100),
  /// matching standard calculator behaviour.
  void onPercentPressed() {
    if (_hasError) return;
    final value = double.tryParse(_currentInput) ?? 0;
    _currentInput = _formatNumber(value / 100);
    notifyListeners();
  }

  /// "+/-" — Toggles the sign of the current input.
  void onToggleSign() {
    if (_hasError) return;
    if (_currentInput == '0') return;
    if (_currentInput.startsWith('-')) {
      _currentInput = _currentInput.substring(1);
    } else {
      _currentInput = '-$_currentInput';
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Internal math engine
  // ---------------------------------------------------------------------

  /// Performs the arithmetic operation. Returns `null` to signal an
  /// unrecoverable error (currently only division by zero).
  double? _calculate(double a, String bRaw, CalcOperator op) {
    final b = double.tryParse(bRaw) ?? 0;
    switch (op) {
      case CalcOperator.add:
        return _roundForPrecision(a + b);
      case CalcOperator.subtract:
        return _roundForPrecision(a - b);
      case CalcOperator.multiply:
        return _roundForPrecision(a * b);
      case CalcOperator.divide:
        if (b == 0) return null; // Signals divide-by-zero to the caller.
        return _roundForPrecision(a / b);
    }
  }

  void _triggerDivideByZeroError() {
    _hasError = true;
    _currentInput = 'Cannot divide by zero';
    _expression = '';
    notifyListeners();
  }

  /// Mitigates classic binary floating-point artifacts (e.g. the famous
  /// 0.1 + 0.2 = 0.30000000000000004 problem) by rounding to a sane
  /// number of decimal places before the value is ever displayed or
  /// re-used in a subsequent calculation.
  double _roundForPrecision(double value) {
    if (value.isNaN || value.isInfinite) return value;
    const precision = 10;
    final factor = 1.0 * _pow10(precision);
    return (value * factor).round() / factor;
  }

  double _pow10(int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= 10;
    }
    return result;
  }

  /// Formats a double for display: strips unnecessary trailing zeros and
  /// avoids showing values in raw scientific/expanded double form.
  String _formatNumber(double value) {
    if (value.isNaN) return 'Undefined';
    if (value.isInfinite) return 'Overflow';

    // Whole numbers display without a decimal point (e.g. "12" not "12.0").
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    String text = value.toStringAsFixed(10);
    // Trim trailing zeros, then a trailing lone decimal point if present.
    text = text.replaceAll(RegExp(r'0+$'), '');
    text = text.replaceAll(RegExp(r'\.$'), '');
    return text;
  }
}
