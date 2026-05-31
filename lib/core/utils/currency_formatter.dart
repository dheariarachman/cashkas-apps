import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String cleanString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanString.isEmpty) {
      return newValue.copyWith(text: '0', selection: const TextSelection.collapsed(offset: 1));
    }

    double value = double.parse(cleanString);
    final formatter = NumberFormat.decimalPattern('id_ID');
    String newText = formatter.format(value);

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
  
  static double parse(String text) {
    return double.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
}
