import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Komponen Text Field Terstandarisasi RS PKU Gamping
///
/// Menyediakan tampilan input form yang seragam di seluruh aplikasi,
/// mencakup label terintegrasi, prefix icon, hint, validasi, dan
/// dukungan toggle mata password otomatis (`isPassword: true`).
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.obscureText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.autovalidateMode,
    this.fillColor = Colors.white,
    this.borderRadius = 10,
    this.onTap,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool? obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final AutovalidateMode? autovalidateMode;
  final Color fillColor;
  final double borderRadius;
  final VoidCallback? onTap;

  /// Helper untuk mendapatkan [InputDecoration] terstandarisasi
  /// jika ingin diterapkan pada [TextFormField] kustom.
  static InputDecoration decoration({
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    Color fillColor = Colors.white,
    double borderRadius = 10,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textHint,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: AppColors.textHint,
              size: 20,
            )
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText ?? widget.isPassword;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obscureText != null && widget.obscureText != oldWidget.obscureText) {
      _obscure = widget.obscureText!;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? effectiveSuffix = widget.suffixIcon;

    if (widget.isPassword && effectiveSuffix == null) {
      effectiveSuffix = IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textHint,
          size: 20,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    }

    final field = TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      autovalidateMode: widget.autovalidateMode,
      onTap: widget.onTap,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: AppTextField.decoration(
        hint: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: effectiveSuffix,
        fillColor: widget.fillColor,
        borderRadius: widget.borderRadius,
      ),
    );

    if (widget.label == null || widget.label!.isEmpty) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label!,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
