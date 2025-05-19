import 'package:flutter/material.dart';

class BrandedPrimaryButton extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isUnfocus;
  final Widget? suffixIcon;

  const BrandedPrimaryButton({
    super.key,
    this.isUnfocus = false,
    required this.name,
    required this.onPressed,
    this.isEnabled = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SizedBox(
        height: isEnabled ? 50 : 46,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? (isUnfocus ? colorScheme.surfaceVariant : colorScheme.primary)
                : theme.disabledColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isEnabled ? 10.0 : 6.0),
              side: isEnabled
                  ? BorderSide(
                      color:
                          isUnfocus ? colorScheme.primary : colorScheme.primary,
                    )
                  : BorderSide.none,
            ),
          ),
          child: getButtonText(context),
        ),
      ),
    );
  }

  Widget getButtonText(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isUnfocus ? colorScheme.secondary : colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: (MediaQuery.of(context).size.width < 380) ? 14 : 16,
          ),
        ),
        if (suffixIcon != null) ...[
          const SizedBox(width: 8),
          suffixIcon!,
        ],
      ],
    );
  }
}
