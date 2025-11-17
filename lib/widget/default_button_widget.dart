import 'package:flutter/material.dart';

class DefaultButtonWidget extends StatelessWidget {
  final String text;
  final GestureTapCallback onTap;
  final bool loading;
  final Color color;

  const DefaultButtonWidget({
    super.key,
    required this.text,
    required this.onTap,
    required this.loading,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: loading ? SizedBox(height:30, width: 30, child: CircularProgressIndicator(color: Colors.white,)):
                Text(text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),))));
  }
}