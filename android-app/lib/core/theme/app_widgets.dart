import 'dart:ui';
import 'package:flutter/material.dart';
import 'design_system.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final bool glass;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsets? margin;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.glass = false,
    this.color,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    
    if (glass) {
      content = Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: width,
              height: height,
              padding: padding ?? const EdgeInsets.all(20),
              decoration: DesignSystem.glassDecoration(context: context),
              child: child,
            ),
          ),
        ),
      );
    } else {
      content = Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: DesignSystem.softShadow,
        ),
        child: child,
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: content,
      );
    }

    return content;
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final double? width;
  final double height;
  final bool isLoading;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.width,
    this.height = 56,
    bool? isLoading,
    bool? loading,
    this.icon,
  }) : isLoading = loading ?? isLoading ?? false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? DesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignSystem.premiumShadow,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: DesignSystem.bodyLarge(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool small;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    Color? iconColor,
    Color? color,
    this.onTap,
    this.small = false,
  }) : iconColor = iconColor ?? color ?? Colors.grey;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: PremiumCard(
        padding: EdgeInsets.all(small ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(small ? 6 : 8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(small ? 8 : 10),
              ),
              child: Icon(icon, color: iconColor, size: small ? 16 : 20),
            ),
            SizedBox(height: small ? 8 : 12),
            Text(
              value,
              style: small ? DesignSystem.bodyLarge().copyWith(fontWeight: FontWeight.bold) : DesignSystem.heading3(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: DesignSystem.bodySmall(color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class RewardBadge extends StatelessWidget {
  final String type; // 'silver', 'gold', 'hero'
  final double size;

  const RewardBadge({
    super.key,
    required this.type,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (type.toLowerCase()) {
      case 'gold':
        color = const Color(0xFFFFD700);
        icon = Icons.workspace_premium;
        label = 'Gold';
        break;
      case 'silver':
        color = const Color(0xFFC0C0C0);
        icon = Icons.stars;
        label = 'Silver';
        break;
      case 'hero':
        color = DesignSystem.primary;
        icon = Icons.bolt;
        label = 'Hero';
        break;
      default:
        color = Colors.grey;
        icon = Icons.emoji_events;
        label = 'Bronze';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: size),
          const SizedBox(width: 4),
          Text(
            label,
            style: DesignSystem.caption(color: color).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData prefixIcon;
  final int maxLines;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.maxLines = 1,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignSystem.softShadow,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: DesignSystem.bodyMedium(),
        decoration: DesignSystem.inputDecoration(hintText, prefixIcon),
      ),
    );
  }
}
