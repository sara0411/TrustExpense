import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_design_system.dart';

/// Money display component with large, readable formatting
/// Uses tabular figures for proper alignment
class MoneyDisplay extends StatelessWidget {
  final double amount;
  final MoneyDisplaySize size;
  final Color? color;
  final bool showCurrency;

  const MoneyDisplay({
    super.key,
    required this.amount,
    this.size = MoneyDisplaySize.medium,
    this.color,
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: showCurrency ? '\$' : '',
      decimalDigits: 2,
    );
    
    final formattedAmount = formatter.format(amount);
    
    return Text(
      formattedAmount,
      style: _getTextStyle().copyWith(color: color),
    );
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case MoneyDisplaySize.large:
        return AppDesignSystem.moneyLarge;
      case MoneyDisplaySize.medium:
        return AppDesignSystem.moneyMedium;
      case MoneyDisplaySize.small:
        return AppDesignSystem.moneySmall;
    }
  }
}

enum MoneyDisplaySize {
  large,
  medium,
  small,
}
