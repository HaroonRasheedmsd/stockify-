import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isOutlined;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.color,
    this.textColor,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.color ?? theme.primaryColor;
    final contentColor = widget.textColor ?? (widget.isOutlined ? buttonColor : Colors.white);

    Widget buttonBody = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(contentColor),
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, color: contentColor, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            widget.text,
            style: TextStyle(
              color: contentColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ]
      ],
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          if (!widget.isLoading) widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: widget.isOutlined ? Colors.transparent : buttonColor,
            border: widget.isOutlined ? Border.all(color: buttonColor, width: 2) : null,
            boxShadow: widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: buttonColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(child: buttonBody),
        ),
      ),
    );
  }
}
