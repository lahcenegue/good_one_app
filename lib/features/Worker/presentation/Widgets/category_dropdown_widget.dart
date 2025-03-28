import 'package:flutter/material.dart';

import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';

class CategoryDropdownWidget<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const CategoryDropdownWidget({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.subTitle(context),
          ),
          SizedBox(height: context.getHeight(8)),
          DropdownButtonFormField<T>(
            decoration: InputDecoration(
              hintText: value == null ? hint : '',
              labelStyle: AppTextStyles.text(context),
            ),
            elevation: 0,
            isExpanded: true,
            value: value,
            icon: Icon(Icons.arrow_drop_down),
            style: AppTextStyles.text(context),
            dropdownColor: AppColors.dimGray,
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.getAdaptiveSize(4),
                  ),
                  child: Text(
                    item.toString(),
                    style: AppTextStyles.subTitle(context),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
