import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

class SearchDropdown extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final Function(String) onSubmitted;
  final List<dynamic> searchResults;
  final String hintText;
  final Function(dynamic) onResultTap;

  const SearchDropdown({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onSubmitted,
    required this.searchResults,
    required this.hintText,
    required this.onResultTap,
  });

  @override
  State<SearchDropdown> createState() => _SearchDropdownState();
}

class _SearchDropdownState extends State<SearchDropdown> {
  final FocusNode _focusNode = FocusNode();
  bool _showDropdown = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final text = widget.searchController.text;
    setState(() {
      _isTyping = text.isNotEmpty;
    });

    if (text.isNotEmpty) {
      widget.onSearch(text);
      setState(() {
        _showDropdown = true;
      });
    } else {
      setState(() {
        _showDropdown = false;
      });
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() {
        _showDropdown = _isTyping;
      });
    } else {
      // Delay hiding to allow for tap detection
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showDropdown = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.dimGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: widget.searchController,
            focusNode: _focusNode,
            onSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: Icon(
                Icons.search,
                size: context.getAdaptiveSize(24),
                color: Colors.black,
              ),
              suffixIcon: _isTyping
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        widget.searchController.clear();
                        setState(() {
                          _showDropdown = false;
                          _isTyping = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.getWidth(15),
                vertical: context.getHeight(12),
              ),
            ),
          ),
        ),
        if (_showDropdown && widget.searchResults.isNotEmpty)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.searchResults.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: context.getHeight(5)),
              itemBuilder: (context, index) {
                final result = widget.searchResults[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: context.getWidth(15),
                    vertical: context.getHeight(5),
                  ),
                  leading: result.picture != null
                      ? UserAvatar(
                          picture: result.picture,
                          size: context.getWidth(50),
                        )
                      : CircleAvatar(
                          radius: context.getWidth(20),
                          child: Icon(Icons.person),
                        ),
                  title: Text(
                    result.fullName ?? '',
                    style: AppTextStyles.text(context),
                  ),
                  subtitle: Text(
                    result.service ?? '',
                    style: AppTextStyles.title2(context),
                  ),
                  onTap: () {
                    widget.searchController.clear();
                    setState(() {
                      _showDropdown = false;
                      _isTyping = false;
                    });
                    widget.onResultTap(result);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
