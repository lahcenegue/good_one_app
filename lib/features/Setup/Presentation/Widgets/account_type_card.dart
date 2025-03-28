import 'package:flutter/material.dart';

import 'package:good_one_app/Core/Presentation/Widgets/Buttons/secondary_button.dart';
import 'package:good_one_app/Features/Setup/Models/account_type.dart';

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
