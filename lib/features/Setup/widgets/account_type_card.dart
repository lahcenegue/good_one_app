import 'package:flutter/material.dart';

import '../../../Core/Widgets/custom_buttons.dart';
import '../Models/account_type.dart';

class AccountTypeCard extends StatelessWidget {
  final String title;
  final AccountType type;
  final bool isSelected;
  final VoidCallback onSelect;

  const AccountTypeCard({
    super.key,
    required this.title,
    required this.type,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      text: title,
      onPressed: onSelect,
      isPressed: isSelected,
    );
  }
}
