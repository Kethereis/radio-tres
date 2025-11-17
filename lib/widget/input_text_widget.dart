import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputTextWidget extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final double elevation;
  final TextEditingController? controller;
  final VoidCallback? onPressed;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final bool? obscureText;
  final bool? enabled;
  final TextInputType? keyboard;
  final String label;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLines;

  const InputTextWidget({
    super.key,
    required this.hintText,
    required this.icon,
    required this.elevation,
    this.enabled,
    this.obscureText,
    this.controller,
    this.onTap,
    this.onChanged,
    this.onPressed,
    required this.keyboard,
    required this.label,
    required this.inputFormatters,
    this.validator,
    this.maxLines
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey,   // 👈 aqui define a cor da borda
            width: 0.5,           // 👈 espessura da borda
          ),
        ),
        child: TextFormField(
          maxLines: maxLines ?? 1,
          enabled: enabled,
          inputFormatters: inputFormatters,
          onTap: onTap,
          keyboardType: keyboard,
          obscureText: obscureText ?? false,
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            suffixIcon: obscureText != null
                ? IconButton(
              onPressed: onPressed,
            icon: Icon(
              obscureText! ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            )): null,
            prefixIcon: Icon(icon, color: Colors.grey,),
            hintText: hintText,
            labelText: label,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      ),
    ));
  }
}
