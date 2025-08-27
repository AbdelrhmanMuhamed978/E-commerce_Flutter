import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;

  const ResponsiveAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: 0,
      leading: leading,
      actions: actions,
      iconTheme: IconThemeData(
        color: Colors.black,
        size: ResponsiveUtils.getResponsiveIconSize(context, 24),
      ),
      toolbarHeight: ResponsiveUtils.getAppBarHeight(context),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(56.0); // Default AppBar height
}

class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final double? width;

  const ResponsiveButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? ResponsiveUtils.getResponsiveWidth(context, 0.8),
      height: ResponsiveUtils.getResponsiveButtonHeight(context),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.blue,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: ResponsiveUtils.getResponsiveIconSize(context, 20),
                width: ResponsiveUtils.getResponsiveIconSize(context, 20),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2,
      margin: margin ?? ResponsiveUtils.getResponsiveMargin(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
        child: child,
      ),
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText({
    Key? key,
    required this.text,
    required this.baseFontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseFontSize),
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? widthPercentage;
  final double? heightPercentage;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Decoration? decoration;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.widthPercentage,
    this.heightPercentage,
    this.padding,
    this.margin,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthPercentage != null
          ? ResponsiveUtils.getResponsiveWidth(context, widthPercentage!)
          : null,
      height: heightPercentage != null
          ? ResponsiveUtils.getResponsiveHeight(context, heightPercentage!)
          : null,
      padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      margin: margin ?? ResponsiveUtils.getResponsiveMargin(context),
      decoration: decoration,
      child: child,
    );
  }
}
