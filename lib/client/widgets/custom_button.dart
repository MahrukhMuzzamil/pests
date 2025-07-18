import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String tag;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final IconData? icon;
  final double? height;
  final double? borderRadius;
  final double? iconSize;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    this.textStyle,
    this.iconSize,
    this.iconColor,
    this.borderRadius,
    this.height,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.icon,
    this.backgroundColor,
    this.textColor,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final Color finalBackgroundColor =
        backgroundColor ?? Theme.of(context).colorScheme.primary;
    final Color finalTextColor =
        textColor ?? Theme.of(context).colorScheme.onSecondary;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Hero(
        tag: tag,
        child: Container(
          decoration: BoxDecoration(
            color: finalBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius ?? 29),
          ),
          alignment: Alignment.center,
          height: height ?? 50,
          child: isLoading
              ? SizedBox(
                  width: 27,
                  height: 27,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: Text(
                        text,
                        style: textStyle ??
                            TextStyle(
                              color: finalTextColor,
                              fontSize: 18,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 8.0),
                      Icon(
                        icon,
                        size:iconSize ?? 25,
                        color: iconColor ?? Theme.of(context).colorScheme.onSecondary,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
